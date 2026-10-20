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
      final located = await _countryCode();
      final currency = currencyForCountry(located.code);
      if (currency == 'USD') {
        if (located.fromGps) {
          await _storage.remove(StorageKeys.fxQuote);
          _resolved = true;
          emit(FxQuote.usd());
          return;
        }
        _resolved = true;
        emit(cached ?? FxQuote.usd());
        return;
      }
      final quote = await _repository.fetch(currency);
      if (quote.isUsd) {
        _resolved = true;
        emit(cached ?? state);
        return;
      }
      await _storage.setString(StorageKeys.fxQuote, quote.encode());
      _resolved = true;
      emit(quote);
    } catch (_) {
      _resolved = true;
      emit(cached ?? state);
    }
  }

  /// Where the phone is beats a UK or US language setting, so Pakistan
  /// shows PKR. If location is missing, a non-USD region is kept.
  Future<_LocatedCountry> _countryCode() async {
    final region = PlatformDispatcher.instance.locale.countryCode?.toUpperCase();
    final gps = await _gpsCountry();
    if (gps != null && currencyForCountry(gps) != 'USD') {
      return _LocatedCountry(gps, fromGps: true);
    }
    if (currencyForCountry(region) != 'USD') {
      return _LocatedCountry(region, fromGps: false);
    }
    if (gps != null) return _LocatedCountry(gps, fromGps: true);
    return _LocatedCountry(
      region != null && region.isNotEmpty ? region : null,
      fromGps: false,
    );
  }

  Future<String?> _gpsCountry() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
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

class _LocatedCountry {
  const _LocatedCountry(this.code, {required this.fromGps});

  final String? code;
  final bool fromGps;
}

FxQuote? _storedQuote(StorageService storage) {
  return FxQuote.decode(storage.getString(StorageKeys.fxQuote));
}
