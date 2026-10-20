import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:nubesim/core/exceptions/api_error.dart';
import 'package:nubesim/core/network/dio_client.dart';
import 'package:nubesim/utils/logger/logger.dart';
import '../model/send_email_input.dart';
import '../model/send_email_response.dart';
import '../../../constants/api_endpoints.dart';

class EmailRepository {
  final DioClient _dioClient;
  final _log = logger(EmailRepository);

  EmailRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<SendEmailResponse> sendEmail({
    required SendEmailInput input,
  }) async {
    try {
      final response = await _dioClient.post(
        Endpoints.sendEmail,
        data: input.toJson(),
        options: Options(
          headers: {
            "accept": "application/json",
            "content-type": "application/json",
            "api-key": "",
          },
        ),
      );
      // debugger();
      DelayedMultiDragGestureRecognizer(delay: Duration(seconds: 2));
      return SendEmailResponse.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      _log.e(e, stackTrace: stackTrace);
      throw ApiError.fromDioException(e);
    } on ApiError catch (e) {
      _log.e(e);
      throw ApiError(message: "Something went wrong, please try again after some time.", code: 0);
    }
  }
}
