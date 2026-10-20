import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class StripeDioClient extends DioForNative {
  StripeDioClient() {
    options = BaseOptions(
      baseUrl: 'https://api.stripe.com/v1',
      responseType: ResponseType.json,
    );

    // Add interceptors
    interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) {
    options.headers['Authorization'] =
              'Basic c2tfdGVzdF81MVJjdzVxTERkTVp3VUR2Q09GS1ZmUnlmU1hQTFEwZk9KdmVLcDZqUmlxVlBVM2hMbTdJSGRMcFFuSnh0Nkg3NDc5c2tnV2IwUXZYbjJYVThxbFJGY1lZNDAwT3dPazFhNng6';
          options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
          return handler.next(options);
        },
      ),
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
      ),
    ]);
  }
}
