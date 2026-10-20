import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:nubesim/modules/shop/services/package_controls_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lets the eSIM provider API key (RT-AccessCode) be changed from the website
/// admin ("eSIM App Settings") without releasing a new app version.
///
/// The app asks `esim-app-config.php` for the key, sending [_appToken], and
/// remembers the last value. The key that is built into [DioClient] stays as
/// the fallback: if the server can't be reached or nothing is saved there,
/// [override] is null (or the last saved value) and the app works as before.
class ApiKeyService {
  ApiKeyService._();

  static const String endpoint = '${PackageControls.adminBase}/esim-app-config.php';

  /// Must be the same value as "App token" on the admin settings page.
  static const String _appToken = '3ef0452557f23a28d2fd66433724fe5e8b5cd67e';

  static const String _cacheKey = 'esim_api_key_cache_v1';

  /// The key saved in the admin, or null to keep the built-in one.
  /// Read on every request by the Dio client.
  static String? override;

  static final RegExp _valid = RegExp(r'^[A-Za-z0-9]{16,64}$');

  /// Loads the last saved key, then asks the server for a newer one (short
  /// timeout). Never throws.
  static Future<void> load() async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null && _valid.hasMatch(cached)) override = cached;
    } catch (_) {}

    try {
      final response = await Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
        responseType: ResponseType.plain,
        // The host's firewall returns an HTML block page (403) to requests
        // with no User-Agent, which isn't set by default on every platform.
        headers: {'X-App-Token': _appToken, 'User-Agent': 'NubeSIM-App'},
      )).get<String>(endpoint);

      final body = jsonDecode(response.data ?? '');
      final key = body is Map ? body['apiKey'] : null;
      if (body is Map &&
          body['success'] == true &&
          key is String &&
          _valid.hasMatch(key)) {
        override = key;
        await prefs?.setString(_cacheKey, key);
      }
    } catch (_) {
      // keep the saved / built-in key
    }
  }
}
