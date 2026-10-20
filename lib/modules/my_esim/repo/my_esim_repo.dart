import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nubesim/modules/my_esim/models/all_allocated_esim_input.dart';
import 'package:nubesim/modules/my_esim/models/all_esim_model.dart';
import 'package:nubesim/modules/my_esim/models/esim_details_input.dart';

import '../../../constants/api_endpoints.dart';
import '../../../core/exceptions/api_error.dart';
import '../../../core/network/dio_client.dart';
import '../../../utils/logger/logger.dart';

class MyEsimRepository {
  final DioClient _dioClient;
  final _log = logger(MyEsimRepository);

  MyEsimRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<AllAllocatedEsimResponse> getUsageQuery(
      {required esimTranNoList}) async {
    try {
      var response = await _dioClient.post(Endpoints.getAllAllocatedEsims,
          data: {"esimTranNoList": esimTranNoList});
      AllAllocatedEsimResponse allAllocatedEsimResponse =
          AllAllocatedEsimResponse.fromJson(response.data);
      return allAllocatedEsimResponse;
    } on DioException catch (e, stackTrace) {
      _log.e(e, stackTrace: stackTrace);
      throw ApiError.fromDioException(e);
    } on ApiError catch (e) {
      _log.e(e);
      throw ApiError(message: e.message, code: 0);
    }
  }
Future<AllAllocatedEsimResponse?>  getAllAllocatedEsim({
  required AllAllocatedEsimInput input,
  int retryCount = 0,
}) async {
  try {
    final response = await _dioClient.post(
      Endpoints.getAllAllocatedEsims,
      data: input.toJson(),
    );

    if (response.data["success"] == true) {
      return AllAllocatedEsimResponse.fromJson(response.data);
    }

    /// ✅ Check for "system is busy" and retry
    if (response.data["errorMsg"] != null &&
        response.data["errorMsg"].toString().contains("system is busy")) {
      if (kDebugMode) {
        // print("retryCount $retryCount");
      }
      if (retryCount < 3) {
        await Future.delayed(const Duration(seconds: 1));
        return getAllAllocatedEsim(
          input: input,
          retryCount: retryCount + 1,
        );
      } else {
        // print("❌ Max retries reached.");
        return null;
      }
    }

    return null;

  } on DioException catch (e, stackTrace) {
    _log.e(e, stackTrace: stackTrace);
    throw ApiError.fromDioException(e);

  } on ApiError catch (e) {
    _log.e(e);
    throw ApiError(message: e.message, code: 0);
  }
}

  Future<AllAllocatedEsimResponse> getEsimDetails(
      {required EsimDetailsInput input}) async {
    try {
      var response = await _dioClient.post(Endpoints.getAllAllocatedEsims,
          data: input.toJson());
      AllAllocatedEsimResponse allAllocatedEsimResponse =
          AllAllocatedEsimResponse.fromJson(response.data);
      return allAllocatedEsimResponse;
    } on DioException catch (e, stackTrace) {
      _log.e(e, stackTrace: stackTrace);
      throw ApiError.fromDioException(e);
    } on ApiError catch (e) {
      _log.e(e);
      throw ApiError(message: e.message, code: 0);
    }
  }
}
