import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nubesim/constants/keys.dart';
import 'package:nubesim/core/storage_service/storage_service.dart';
import 'package:nubesim/modules/shop/currency/fx_quote.dart';
import 'package:nubesim/modules/shop/currency/fx_quote_repository.dart';

class CurrencyCubit extends Cubit<FxQuote> {
  CurrencyCubit(this._repository, this._storage)
      : super(_storedQuote(_storage) ?? FxQuote.usd()) {
    load();
  }

  final FxQuoteRepository _repository;
  final StorageService _storage;
  Future<void>? _inFlight;
  bool _resolved = false;

  bool get _ready {
    if (!_resolved) return false;
    if (state.isUsd) return true;
    return state.quoteId != null && !state.isExpired;
  }

  Future<void> load({bool force = false}) {
    if (!force && _ready) return Future.value();
    if (!force && _inFlight != null) return _inFlight!;
    final run = _fetch();
    _inFlight = run;
    run.whenComplete(() {
      if (identical(_inFlight, run)) _inFlight = null;
    });
    return run;
  }

  Future<void> _fetch() async {
    final cached = _storedQuote(_storage);
    if (cached != null) emit(cached);
    try {
      final located = await _currencyCode();
      if (!located.settled) {
        emit(cached ?? state);
        return;
      }
      final currency = located.currency;
      if (currency == 'USD') {
        await _storage.remove(StorageKeys.fxQuote);
        _resolved = true;
        emit(FxQuote.usd());
        return;
      }
      final quote = await _repository.fetch(currency);
      if (quote.isUsd) {
        emit(cached ?? state);
        return;
      }
      await _storage.setString(StorageKeys.fxQuote, quote.encode());
      _resolved = true;
      emit(quote);
    } catch (_) {
      emit(cached ?? state);
    }
  }

  /// GPS wins when the phone already allowed location. Otherwise the website
  /// visitor lookup supplies the currency, so PKR shows without a prompt.
  /// Dollars stay unfinished until that lookup actually returns.
  Future<_ResolvedCurrency> _currencyCode() async {
    final gps = await _gpsCountry();
    if (gps != null) {
      return _ResolvedCurrency(currencyForCountry(gps), settled: true);
    }
    final visitor = await _repository.visitorCurrency();
    if (visitor != null) {
      return _ResolvedCurrency(visitor, settled: true);
    }
    final region = PlatformDispatcher.instance.locale.countryCode?.toUpperCase();
    final regionCurrency = currencyForCountry(region);
    if (regionCurrency != 'USD') {
      return _ResolvedCurrency(regionCurrency, settled: true);
    }
    return const _ResolvedCurrency('USD', settled: false);
  }

  Future<String?> _gpsCountry() async {
    try {
      final permission = await Geolocator.checkPermission();
      final granted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      if (!granted) return null;
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        ),
      );
      final marks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final iso = marks.isEmpty ? null : marks.first.isoCountryCode;
      if (iso == null || iso.isEmpty) return null;
      return iso.toUpperCase();
    } catch (_) {
      return null;
    }
  }
}

class _ResolvedCurrency {
  const _ResolvedCurrency(this.currency, {required this.settled});

  final String currency;
  final bool settled;
}

FxQuote? _storedQuote(StorageService storage) {
  return FxQuote.decode(storage.getString(StorageKeys.fxQuote));
}
