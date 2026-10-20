// To parse this JSON data, do
//
//     final accountBalanceResponse = accountBalanceResponseFromJson(jsonString);

import 'dart:convert';

AccountBalanceResponse accountBalanceResponseFromJson(String str) =>
    AccountBalanceResponse.fromJson(json.decode(str));

String accountBalanceResponseToJson(AccountBalanceResponse data) =>
    json.encode(data.toJson());

class AccountBalanceResponse {
  bool success;
  String errorCode;
  dynamic errorMsg;
  BalanceObj obj;

  AccountBalanceResponse({
    required this.success,
    required this.errorCode,
    required this.errorMsg,
    required this.obj,
  });

  factory AccountBalanceResponse.fromJson(Map<String, dynamic> json) =>
      AccountBalanceResponse(
        success: json["success"],
        errorCode: json["errorCode"],
        errorMsg: json["errorMsg"],
        obj: BalanceObj.fromJson(json["obj"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "errorCode": errorCode,
        "errorMsg": errorMsg,
        "obj": obj.toJson(),
      };
}

class BalanceObj {
  int balance;

  BalanceObj({
    required this.balance,
  });

  factory BalanceObj.fromJson(Map<String, dynamic> json) => BalanceObj(
        balance: json["balance"],
      );

  Map<String, dynamic> toJson() => {
        "balance": balance,
      };
}
