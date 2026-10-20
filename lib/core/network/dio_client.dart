import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../../config/environment.dart';
import 'api_key_service.dart';

class DioClient extends DioForNative {
  final Environment _environment;

  String? _authToken;

  void setToken(String token) {
    _authToken = token;
  }

  DioClient({required Environment environment}) : _environment = environment {
    options = BaseOptions(
      baseUrl: _environment.baseUrl,
      responseType: ResponseType.json,
      headers: {
        'Accept': 'application/json',
        // 'RT-AccessCode': 'aa3fb635073049da9398fc884b189267',
        'RT-AccessCode':'70b8b206470049bbb9be3f82a718aa8a'
      },
    );
    // A key saved in the website admin replaces the built-in one above.
    interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      final key = ApiKeyService.override;
      if (key != null) options.headers['RT-AccessCode'] = key;
      handler.next(options);
    }));
    interceptors.add(LogInterceptor(
      request: false,
      requestHeader: false,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
    ));
  }
}
