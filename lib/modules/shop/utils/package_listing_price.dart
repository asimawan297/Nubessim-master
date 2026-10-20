import 'package:nubesim/modules/shop/currency/fx_quote.dart';
import 'package:nubesim/modules/shop/model/all_data_packages_model.dart';
import 'package:nubesim/modules/shop/services/package_controls_service.dart';
import 'package:nubesim/utils/helper_widgets.dart';

/// Same duration options as [PackagesSelectionScreen] unlimited tab.
const List<int> unlimitedListingDayOptions = [1, 3, 5, 7, 10, 15, 30];

bool isStandardListingPackage(PackageList pkg) {
  return pkg.dataType == 1 &&
      formatBytesToGB(pkg.volume) >= 1 &&
      (pkg.duration == 1 ||
          pkg.duration == 7 ||
          pkg.duration == 15 ||
          pkg.duration == 30 ||
          // Europe (31 areas) plans are sold as 31 days, not 30.
          pkg.duration == 31);
}

bool isUnlimitedSourcePackage(PackageList pkg) {
  return pkg.dataType == 2 && formatBytesToGB(pkg.volume) >= 1;
}

/// Collapses rate cards that share the same data amount and validity (or,
/// for Unlimited packages where the data amount isn't meaningful, just the
/// same validity) into a single card. When more than one candidate exists
/// for a given data/validity combo, the one with 5G network support wins;
/// if that's still tied, the cheaper one wins.
List<PackageList> dedupeRateCards(List<PackageList> packages) {
  final Map<String, PackageList> bestByKey = {};
  for (final pkg in packages) {
    final key = pkg.dataType == 2
        ? 'unlimited_${pkg.duration}'
        : '${formatBytesToGB(pkg.volume)}_${pkg.duration}';
    final current = bestByKey[key];
    if (current == null || _isPreferredRateCard(pkg, current)) {
      bestByKey[key] = pkg;
    }
  }

  return bestByKey.values.toList()
    ..sort((a, b) {
      final volCompare =
          formatBytesToGB(a.volume).compareTo(formatBytesToGB(b.volume));
      if (volCompare != 0) return volCompare;
      return a.duration.compareTo(b.duration);
    });
}

/// Pick the same 1GB / 7-day card shown first on each single-country page.
Map<String, PackageList> singleCountryStartingPackages(
    List<PackageList> packages) {
  final byCountry = <String, PackageList>{};
  final oneGB = RegExp(r'\b1\s?gb\b', caseSensitive: false);
  final sevenDays = RegExp(r'\b7\s?day', caseSensitive: false);
  for (final pkg in packages) {
    if (!oneGB.hasMatch(pkg.name) || !sevenDays.hasMatch(pkg.name)) continue;
    final current = byCountry[pkg.location];
    if (current == null || _isPreferredRateCard(pkg, current)) {
      byCountry[pkg.location] = pkg;
    }
  }
  return byCountry;
}

bool _isPreferredRateCard(PackageList candidate, PackageList current) {
  if (candidate.dataType == 2 && current.dataType == 2) {
    // Unlimited: 2GB high-speed data over 1GB, then 1Mbps FUP speed over
    // 512Kbps, then cheapest.
    final dataCompare =
        _dataPriority(candidate).compareTo(_dataPriority(current));
    if (dataCompare != 0) return dataCompare < 0;

    final speedCompare = _unlimitedSpeedPriority(candidate)
        .compareTo(_unlimitedSpeedPriority(current));
    if (speedCompare != 0) return speedCompare < 0;

    return candidate.retailPrice < current.retailPrice;
  }

  final candidateGeneration =
      _getMaxGenerationFromLocations(candidate.locationNetworkList);
  final currentGeneration =
      _getMaxGenerationFromLocations(current.locationNetworkList);
  if (candidateGeneration != currentGeneration) {
    return candidateGeneration > currentGeneration;
  }
  return PackageControls.instance.selectionRetailPrice(candidate) <
      PackageControls.instance.selectionRetailPrice(current);
}

/// Picks the unlimited base plan (1-day equivalent): 2GB high-speed data
/// first, falling back to 1GB; then 1Mbps FUP speed first, falling back to
/// 512Kbps; then cheapest. Longer-duration cards multiply this base
/// package's price (and, in spirit, its high-speed allowance) by the
/// number of days.
PackageList? selectUnlimitedBasePackage(List<PackageList> packageList) {
  if (packageList.isEmpty) return null;
  final sorted = [...packageList]..sort((a, b) {
      final dataCompare = _dataPriority(a).compareTo(_dataPriority(b));
      if (dataCompare != 0) return dataCompare;

      final speedCompare =
          _unlimitedSpeedPriority(a).compareTo(_unlimitedSpeedPriority(b));
      if (speedCompare != 0) return speedCompare;

      return a.retailPrice.compareTo(b.retailPrice);
    });
  return sorted.first;
}

/// Builds the 1/3/5/7/10/15/30-day Unlimited cards from [basePackage]'s
/// 1-day price, then applies the website-admin Show/Hide and price
/// overrides (looked up through [sources], the Unlimited packages of that
/// destination).
List<PackageList> buildUnlimitedDayPlans(
    PackageList basePackage, List<PackageList> sources) {
  final plans = <PackageList>[];
  for (final day in unlimitedListingDayOptions) {
    final plan = PackageList.fromJson(basePackage.toJson());
    plan.duration = day;
    plan.retailPrice = basePackage.retailPrice * day;
    plan.dataType = 2;
    plans.add(plan);
  }
  return PackageControls.instance.applyUnlimited(plans, sources);
}

/// Lowest displayed price across packages visible on the regional/global detail page.
double? lowestDisplayedPriceForRegionalGlobalPlans(List<PackageList> plans) {
  double? lowest;

  for (final pkg in plans.where(isStandardListingPackage)) {
    final price = displayedStartingPrice(
      pkg.retailPrice,
      dataType: pkg.dataType,
    );
    if (price != null && price > 0 && (lowest == null || price < lowest)) {
      lowest = price;
    }
  }

  final unlimitedSources =
      plans.where(isUnlimitedSourcePackage).toList(growable: false);
  final basePackage = selectUnlimitedBasePackage(unlimitedSources);
  if (basePackage != null) {
    for (final plan in buildUnlimitedDayPlans(basePackage, unlimitedSources)) {
      final price = displayedStartingPrice(
        plan.retailPrice,
        dataType: 2,
      );
      if (price != null && price > 0 && (lowest == null || price < lowest)) {
        lowest = price;
      }
    }
  }

  return lowest;
}

String startingPriceLabelForRegionalGlobalPlans(
  List<PackageList> plans, {
  required FxQuote quote,
}) {
  final lowest = lowestDisplayedPriceForRegionalGlobalPlans(plans);
  if (lowest == null) return '';
  return 'From ${quote.format(lowest)}';
}

/// Preferred high-speed data tier for an Unlimited plan's 1-day base
/// package: 2GB first, then 1GB, anything else is a last resort.
int _dataPriority(PackageList pkg) {
  final gb = formatBytesToGB(pkg.volume);
  if (gb == 2) return 0;
  if (gb == 1) return 1;
  return 10 + gb.round();
}

/// Preferred FUP (post-allowance) speed for an Unlimited plan: 1Mbps
/// first, then 512Kbps, anything else is a last resort.
int _unlimitedSpeedPriority(PackageList pkg) {
  final fup = _extractFupMbpsFromPackage(pkg);
  if (fup == null) return 1000;
  if (fup == 1.0) return 0;
  if (fup == 0.512) return 1;
  return 2 + (fup * 1000).round();
}

/// Reads a throttle speed like "1 Mbps" / "512 Kbps" and returns it in Mbps.
/// A unit is required (so "3GB/Day FUP1Mbps" reads as 1 Mbps, not 3), except
/// in the dedicated `fupPolicy` field where a bare number means Mbps.
double? _extractFupMbps(String? text, {bool allowBareNumber = false}) {
  if (text == null || text.trim().isEmpty) return null;
  final normalized = text.toLowerCase().replaceAll(' ', '');
  final withUnit = RegExp(r'(\d+(?:\.\d+)?)(kbps|mbps)').firstMatch(normalized);
  if (withUnit != null) {
    final value = double.tryParse(withUnit.group(1)!);
    if (value == null) return null;
    return withUnit.group(2) == 'kbps' ? value / 1000 : value;
  }
  if (allowBareNumber) {
    final bare = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(normalized);
    return bare == null ? null : double.tryParse(bare.group(1)!);
  }
  return null;
}

double? _extractFupMbpsFromPackage(PackageList pkg) {
  return _extractFupMbps(pkg.fupPolicy, allowBareNumber: true) ??
      _extractFupMbps(pkg.name) ??
      _extractFupMbps(pkg.description);
}

int _extractGeneration(String networkType) {
  final type = networkType.toUpperCase();
  final match = RegExp(r'(\d+)G').firstMatch(type);
  if (match != null) return int.parse(match.group(1)!);
  if (type.contains('5G')) return 5;
  if (type.contains('4G')) return 4;
  if (type.contains('3G')) return 3;
  if (type.contains('2G')) return 2;
  return 0;
}

int _getMaxGenerationFromLocations(List<LocationNetworkList> locations) {
  return locations
      .expand((location) => location.operatorList)
      .map((operator) =>
          _extractGeneration(operator['networkType']?.toString() ?? ''))
      .fold(0, (max, current) => current > max ? current : max);
}
