// To parse this JSON data, do
//
//     final orderProfileResponse = orderProfileResponseFromJson(jsonString);

import 'dart:convert';

OrderProfileResponse orderProfileResponseFromJson(String str) =>
    OrderProfileResponse.fromJson(json.decode(str));

String orderProfileResponseToJson(OrderProfileResponse data) =>
    json.encode(data.toJson());

class OrderProfileResponse {
  dynamic errorCode;
  dynamic errorMsg;
  bool success;
  OrderProfileObj obj;

  OrderProfileResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.success,
    required this.obj,
  });

  factory OrderProfileResponse.fromJson(Map<String, dynamic> json) =>
      OrderProfileResponse(
        errorCode: json["errorCode"],
        errorMsg: json["errorMsg"],
        success: json["success"],
        obj: OrderProfileObj.fromJson(json["obj"]),
      );

  Map<String, dynamic> toJson() => {
        "errorCode": errorCode,
        "errorMsg": errorMsg,
        "success": success,
        "obj": obj.toJson(),
      };
}

class OrderProfileObj {
  String orderNo;
  String transactionId;

  OrderProfileObj({
    required this.orderNo,
    required this.transactionId,
  });

  factory OrderProfileObj.fromJson(Map<String, dynamic> json) =>
      OrderProfileObj(
        orderNo: json["orderNo"]?.toString() ?? '',
        transactionId: json["transactionId"]?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        "orderNo": orderNo,
        "transactionId": transactionId,
      };
}
