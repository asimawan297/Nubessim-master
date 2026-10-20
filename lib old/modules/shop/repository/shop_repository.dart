import 'package:dio/dio.dart';
import 'package:nubesim/core/exceptions/api_error.dart';
import 'package:nubesim/core/network/dio_client.dart';
import 'package:nubesim/modules/shop/model/account_balance_response.dart';
import 'package:nubesim/modules/shop/model/order_esim_input.dart';
import 'package:nubesim/modules/my_esim/models/all_esim_model.dart';
import 'package:nubesim/modules/shop/model/order_profile_response.dart';
import 'package:uuid/uuid.dart';
import '../../../constants/api_endpoints.dart';
import '../../../utils/logger/logger.dart';
import '../model/all_data_packages_model.dart';
import '../model/countries_plan_model.dart' hide PackageList;

class ShopRepository {
  final DioClient _dioClient;
  final _log = logger(ShopRepository);

  ShopRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<AllDataPackagesModel> getAllDataPackages(
      {selectedSimType = "",
      iccid = "",
      packageCode = "",
      orderNo = "",
      slug = "",
      dataType}) async {
    try {
      Map<String, dynamic> queryParams = {
        "locationCode": selectedSimType,
        "packageCode": packageCode,
        "iccid": iccid,
        "slug": slug,
        "pageParam": {"pageSize": 10, "pageNum": 1}
      };
      if (dataType != null) {
        queryParams["dataType"] = dataType;
      }
      var response = await _dioClient.post(Endpoints.getAllDataPackages,
          data: queryParams);
      AllDataPackagesModel allDataPackagesModel =
          AllDataPackagesModel.fromJson(response.data);
      return allDataPackagesModel;
    } on DioException catch (e, stackTrace) {
      _log.e(e, stackTrace: stackTrace);
      throw ApiError.fromDioException(e);
    } on ApiError catch (e) {
      _log.e(e);
      throw ApiError(message: e.message, code: 0);
    }
  }

  Future<AllDataPackagesModel> getAllTopUpPackages(packageCode) async {
    try {
      Map<String, dynamic> queryParams = {
        "locationCode": "",
        "type": "TOPUP",
        "packageCode": packageCode,
        "iccid": ""
      };
      var response = await _dioClient.post(Endpoints.getAllDataPackages,
          data: queryParams);
      AllDataPackagesModel allDataPackagesModel =
          AllDataPackagesModel.fromJson(response.data);
      return allDataPackagesModel;
    } on DioException catch (e, stackTrace) {
      _log.e(e, stackTrace: stackTrace);
      throw ApiError.fromDioException(e);
    } on ApiError catch (e) {
      _log.e(e);
      throw ApiError(message: e.message, code: 0);
    }
  }

  Future<CountriesPlanModel> getPlansForCountry() async {
    try {
      // Map<String, dynamic> queryParams = {
      //
      // };
      var response = await _dioClient.post(
        Endpoints.getAllPlansForCuntry,
      );
      CountriesPlanModel countriesPlanModel =
          CountriesPlanModel.fromJson(response.data);
      return countriesPlanModel;
    } on DioException catch (e, stackTrace) {
      _log.e(e, stackTrace: stackTrace);
      throw ApiError.fromDioException(e);
    } on ApiError catch (e) {
      _log.e(e);
      throw ApiError(message: e.message, code: 0);
    }
  }

  Future<OrderProfileResponse> orderEsim({required OrderSimInput input}) async {
    try {
      // debugger();

      var response = await _dioClient.post(
        Endpoints.orderNewEsim,
        data: input.toJson(),
      );
      if (response.data["success"]) {
        OrderProfileResponse orderProfileResponse =
            OrderProfileResponse.fromJson(response.data);
        return orderProfileResponse;
      } else {
        throw ApiError(message: response.data["errorMsg"], code: 0);
      }
    } on DioException catch (e, stackTrace) {

      _log.e(e, stackTrace: stackTrace);
      throw ApiError.fromDioException(e);
    } on ApiError catch (e) {
      _log.e(e);

      throw ApiError(message: e.message, code: 0);
    }
  }

  Future<AccountBalanceResponse> getAccountBalance() async {
    try {
      var response = await _dioClient.post(
        Endpoints.getAccountBalance,
      );
      AccountBalanceResponse accountBalanceResponse =
          AccountBalanceResponse.fromJson(response.data);
      return accountBalanceResponse;
    } on DioException catch (e, stackTrace) {
      _log.e(e, stackTrace: stackTrace);
      throw ApiError.fromDioException(e);
    } on ApiError catch (e) {
      _log.e(e);
      throw ApiError(message: e.message, code: 0);
    }
  }

  AllDataPackagesModel filterAndSortPackages(AllDataPackagesModel model) {
    Map<String, PackageList> grouped = {};

    // Exclude packages < 1GB in bytes
    int minBytes = 1024 * 1024 * 1024;

    // Get first word
    String firstWord(String name) => name.split(' ')[0].toLowerCase();

    for (var pkg in model.obj.packageList) {
      if (pkg.volume < minBytes) continue; // exclude <1GB
      if (![1, 7, 30].contains(pkg.duration)) {
        continue; // include only 1,7,30 days
      }

      String key =
          "${firstWord(pkg.name)}_${pkg.duration}"; // group by first word + duration

      if (!grouped.containsKey(key) || pkg.price < grouped[key]!.price) {
        // pick the lowest price package for the group
        grouped[key] = pkg;
      }
    }

    // Convert map to list
    List<PackageList> finalList = grouped.values.toList();

    // Sort by volume ascending, then duration 1→7→30
    finalList.sort((a, b) {
      int volCompare = a.volume.compareTo(b.volume);
      if (volCompare != 0) return volCompare;
      List<int> durationOrder = [1, 7, 30];
      return durationOrder
          .indexOf(a.duration)
          .compareTo(durationOrder.indexOf(b.duration));
    });

    model.obj.packageList = finalList;
    return model;
  }

  Future<dynamic> purchaseTopUpData(packageCode, iccid) async {
    var uuid = Uuid();
    String txid = uuid.v4();
    try {
      Map<String, dynamic> queryParams = {
        "packageCode": packageCode,
        "iccid": iccid,
        'transactionId': txid
      };
      var response = await _dioClient.post(Endpoints.getAllTopUpPackages,
          data: queryParams);
      return response.data;
    } on DioException catch (e, stackTrace) {
      _log.e(e, stackTrace: stackTrace);
      throw ApiError.fromDioException(e);
    } on ApiError catch (e) {
      _log.e(e);
      throw ApiError(message: e.message, code: 0);
    }
  }

  /// POST `/api/v1/open/esim/query` with [orderNo] only (other filters empty).
  /// Returns the first eSIM in `esimList`, or null if none / request failed.
  Future<EsimList?> queryEsimByOrderNo(String orderNo) async {
    if (orderNo.isEmpty) return null;
    try {
      final response = await _dioClient.post(
        Endpoints.getAllAllocatedEsims,
        data: {
          'orderNo': orderNo,
          'esimTranNo': '',
          'iccid': '',
          'pager': {'pageNum': 1, 'pageSize': 20},
        },
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) return null;
      if (body['success'] != true) return null;
      final obj = body['obj'];
      if (obj is! Map<String, dynamic>) return null;
      final rawList = obj['esimList'];
      if (rawList is! List || rawList.isEmpty) return null;
      final first = rawList.first;
      if (first is! Map<String, dynamic>) return null;
      return EsimList.fromJson(first);
    } on DioException catch (e, stackTrace) {
      _log.e(e, stackTrace: stackTrace);
      return null;
    } catch (e, stackTrace) {
      _log.e(e, stackTrace: stackTrace);
      return null;
    }
  }
}
