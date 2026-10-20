import 'package:dio/dio.dart';

import '../../utils/logger/logger.dart';

class ApiError implements Exception {
  final int? code;
  final String? message;

  ApiError({
    this.code,
    required this.message,
  });

  factory ApiError.fromDioException(DioException dioException) {
    final log = logger(ApiError);
    if (dioException.response != null) {
  log.e('ApiError.fromDioException: ${dioException.response?.data}');

  final status = dioException.response?.statusCode;

  switch (status) {
    case 401:
      return ApiError(
        code: status,
        message: "Unauthorized access, please login again.",
      );

    case 404:
      return ApiError(
        code: status,
        message: "Requested resource not found.",
      );

    case 405:
      return ApiError(
        code: status,
        message: "Method not allowed.",
      );

    case 500:
      return ApiError(
        code: status,
        message: "Internal server error.",
      );

    case 503:
      return ApiError(
        code: status,
        message: "Service unavailable, please try again later.",
      );

    case 422:
      return ApiError(
        code: status,
        message: "Validation failed, please check your input.",
      );

    default:
      return ApiError(
        code: status ?? 0,
        message: "Something went wrong, please try again after some time.",
      );
  }
}


    /// Exception on socket/no internet
    else if (dioException.type == DioExceptionType.unknown) {
      return ApiError(
        code: 503,
        message: 'No internet',
      );
    } else if (dioException.type == DioExceptionType.connectionError) {
      if (dioException.error.toString().contains("Failed host lookup")) {
        return ApiError(
          code: 503,
          message: 'No internet',
        );
      } else {
        return ApiError(
          code: 500,
          message: 'Internal server error',
        );
      }
    }

    /// Exceptions on timeout
    else if (dioException.type == DioExceptionType.connectionTimeout ||
        dioException.type == DioExceptionType.sendTimeout ||
        dioException.type == DioExceptionType.receiveTimeout) {
      return ApiError(
        code: 0,
        message: 'Time out, try again!',
      );
    }

    return ApiError(
      code: dioException.response?.statusCode ?? 0,
      message: "Something went wrong, please try again after some time."
    );
  }

  @override
  String toString() {
    return 'ApiError(code: $code, message: $message)';
  }
}
