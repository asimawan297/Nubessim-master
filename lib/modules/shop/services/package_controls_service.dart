import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:nubesim/modules/shop/model/all_data_packages_model.dart';
import 'package:nubesim/utils/discounts.dart';
import 'package:nubesim/utils/helper_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Price overrides and Show/Hide flags managed on the website admin
/// ("eSIM Package Control" page), served by `esim-controls-api.php`.
///
/// - "price" is the API (struck-through) price in USD, *before* the 25% /
///   50% discount, exactly like the "Our Price Override" field in the admin.
///   It is applied by rewriting `retailPrice`, so the card, the checkout
///   amount and the "From $x" labels all stay consistent.
/// - Hidden packages are removed from the lists.
/// - The discount percentages (default 25% / 50%) come with it, see [Discounts].
/// - If the server can't be reached, the last saved copy is used, and if
///   there is none the normal API prices are shown (nothing breaks).
class PackageControls {
  PackageControls._();
  static final PackageControls instance = PackageControls._();

  /// Admin folder on the website. Can be pointed at a local test server with
  /// `--dart-define=ESIM_ADMIN_BASE=http://127.0.0.1:8899`.
  static const String adminBase = String.fromEnvironment('ESIM_ADMIN_BASE',
      defaultValue: 'https://www.nubessim.com/admin');
  static const String endpoint = '$adminBase/esim-controls-api.php';
  static const String _cacheKey = 'package_controls_cache_v1';

  Map<String, _Control> _standard = {};
  Map<String, Map<int, _Control>> _unlimited = {};
  final Expando<int> _providerRetailPrices = Expando<int>();
  DateTime? _loadedAt;
  Future<void>? _inFlight;

  /// Loads the controls (once per [maxAge]). Never throws.
  Future<void> ensureLoaded({Duration maxAge = const Duration(minutes: 5)}) {
    final loadedAt = _loadedAt;
    if (loadedAt != null && DateTime.now().difference(loadedAt) < maxAge) {
      return Future.value();
    }
    return _inFlight ??= _load().whenComplete(() => _inFlight = null);
  }

  Future<void> _load() async {
    try {
      final response = await Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
        responseType: ResponseType.plain,
        // The host's firewall returns an HTML block page (403) to requests
        // with no User-Agent, which isn't set by default on every platform.
        headers: {'User-Agent': 'NubeSIM-App'},
      )).get<String>(endpoint);

      final body = jsonDecode(response.data ?? '');
      if (body is Map<String, dynamic> && body['success'] == true) {
        updateFromJson(body);
        _saveCache(response.data!);
        return;
      }
    } catch (_) {
      // fall through to the cached copy
    }
    await _loadCache();
  }

  Future<void> _saveCache(String raw) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, raw);
    } catch (_) {}
  }

  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return;
      final body = jsonDecode(raw);
      if (body is Map<String, dynamic>) updateFromJson(body);
    } catch (_) {}
  }

  /// Parses the endpoint JSON (also used by the tests).
  void updateFromJson(Map<String, dynamic> json) {
    final settings = json['settings'];
    if (settings is Map) {
      Discounts.update(
        standardPercent: settings['standardDiscount'],
        unlimitedPercent: settings['unlimitedDiscount'],
      );
    }

    final standard = <String, _Control>{};
    final rawStandard = json['standard'];
    if (rawStandard is Map) {
      rawStandard.forEach((code, value) {
        if (value is Map) standard['$code'] = _Control.fromJson(value);
      });
    }

    final unlimited = <String, Map<int, _Control>>{};
    final rawUnlimited = json['unlimited'];
    if (rawUnlimited is Map) {
      rawUnlimited.forEach((code, days) {
        if (days is! Map) return;
        final byDays = <int, _Control>{};
        days.forEach((d, value) {
          final n = int.tryParse('$d');
          if (n != null && value is Map) byDays[n] = _Control.fromJson(value);
        });
        unlimited['$code'] = byDays;
      });
    }

    _standard = standard;
    _unlimited = unlimited;
    _loadedAt = DateTime.now();
  }

  /// Drops hidden packages and applies price overrides by package code.
  /// Keep the provider price for choosing between equivalent rate cards:
  /// an admin override must not make the app switch to another package code.
  int selectionRetailPrice(PackageList pkg) =>
      _providerRetailPrices[pkg] ?? pkg.retailPrice;

  List<PackageList> applyStandard(List<PackageList> packages) {
    if (_standard.isEmpty) return packages;
    final result = <PackageList>[];
    for (final pkg in packages) {
      final control = _standard[pkg.packageCode];
      if (control == null) {
        result.add(pkg);
        continue;
      }
      if (!control.visible) continue;
      final price = control.priceUsd;
      if (price != null) {
        _providerRetailPrices[pkg] ??= pkg.retailPrice;
        pkg.retailPrice = retailPriceForUsd(price);
      }
      result.add(pkg);
    }
    return result;
  }

  /// Applies the Unlimited controls to the day cards ([plans], e.g. 1/3/5/
  /// 7/10/15/30 days) built from one base package.
  ///
  /// The admin stores Unlimited prices per (source package, days). The
  /// source package the admin picked can differ from the one the app builds
  /// its cards from, so we look for whichever package in [sourceCandidates]
  /// (all Unlimited packages of that country/region) has saved controls and
  /// use the most recently edited one.
  List<PackageList> applyUnlimited(
      List<PackageList> plans, List<PackageList> sourceCandidates) {
    if (_unlimited.isEmpty) return plans;

    final candidateCodes = sourceCandidates.map((p) => p.packageCode).toSet();
    String? bestCode;
    String bestUpdated = '';
    _unlimited.forEach((code, byDays) {
      if (!candidateCodes.contains(code)) return;
      final updated = byDays.values
          .map((c) => c.updated)
          .fold<String>('', (a, b) => a.compareTo(b) >= 0 ? a : b);
      if (bestCode == null || updated.compareTo(bestUpdated) > 0) {
        bestCode = code;
        bestUpdated = updated;
      }
    });
    if (bestCode == null) return plans;

    final byDays = _unlimited[bestCode]!;
    final result = <PackageList>[];
    for (final plan in plans) {
      final control = byDays[plan.duration];
      if (control == null) {
        result.add(plan);
        continue;
      }
      if (!control.visible) continue;
      final price = control.priceUsd;
      if (price != null) plan.retailPrice = retailPriceForUsd(price);
      result.add(plan);
    }
    return result;
  }
}

class _Control {
  final double? priceUsd;
  final bool visible;
  final String updated;

  const _Control(
      {required this.priceUsd, required this.visible, required this.updated});

  factory _Control.fromJson(Map value) {
    final price = value['price'];
    return _Control(
      // 0 or negative would mean a free package, so it counts as "no override".
      priceUsd: price is num && price > 0 ? price.toDouble() : null,
      visible: value['visible'] != false,
      updated: '${value['updated'] ?? ''}',
    );
  }
}
