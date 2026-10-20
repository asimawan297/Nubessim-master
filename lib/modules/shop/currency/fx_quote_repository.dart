import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nubesim/modules/shop/currency/fx_quote.dart';

class FxQuoteRepository {
  FxQuoteRepository({Dio? dio}) : _dio = dio ?? Dio();

  /// Deployed with `firebase deploy --only functions:fxQuote`.
  static const cloudQuoteUrl = 'https://fxquote-to3676ta5a-uc.a.run.app';

  /// Website visitor lookup. Returns the currency for the caller's address.
  static const visitorRateUrl = 'https://www.nubessim.com/esim/get-rate.php';

  /// Set at build time so a debug APK on a phone can reach this computer.
  static const debugHost = String.fromEnvironment('FX_DEBUG_HOST');

  final Dio _dio;

  /// Currency code from the website lookup, or null when the request fails.
  Future<String?> visitorCurrency() async {
    try {
      final response = await _dio.get(
        visitorRateUrl,
        options: Options(
          sendTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 12),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      final json = _asMap(response.data);
      if (response.statusCode != 200 || json == null) return null;
      if (json['result']?.toString() != 'success') return null;
      final currency = json['currency']?.toString().trim().toUpperCase();
      if (currency == null || currency.isEmpty) return null;
      return currency;
    } catch (_) {
      return null;
    }
  }

  Future<FxQuote> fetch(String currency) async {
    if (currency.toUpperCase() == 'USD') return FxQuote.usd();
    final cloud = await _post(cloudQuoteUrl, currency);
    if (cloud != null) return cloud;
    if (!kDebugMode) return FxQuote.usd();
    final host = debugHost.isEmpty ? '127.0.0.1' : debugHost;
    final localQuoteUrl =
        'http://$host:5001/nubesim-7267b/us-central1/fxQuote';
    return await _post(localQuoteUrl, currency) ?? FxQuote.usd();
  }

  Future<FxQuote?> _post(String url, String currency) async {
    try {
      final response = await _dio.post(
        url,
        data: {'currency': currency},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 12),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      final data = response.data;
      if (response.statusCode != 200 || data is! Map) return null;
      return FxQuote.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }
}

Map<String, dynamic>? _asMap(dynamic data) {
  if (data is Map) return Map<String, dynamic>.from(data);
  if (data is! String || data.isEmpty) return null;
  try {
    final decoded = jsonDecode(data);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  } catch (_) {}
  return null;
}
