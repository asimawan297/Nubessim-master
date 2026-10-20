// To parse this JSON data, do
//
//     final allAllocatedEsimResponse = allAllocatedEsimResponseFromJson(jsonString);

import 'dart:convert';

import 'package:nubesim/modules/shop/model/all_data_packages_model.dart';

AllAllocatedEsimResponse allAllocatedEsimResponseFromJson(String str) =>
    AllAllocatedEsimResponse.fromJson(json.decode(str));

String allAllocatedEsimResponseToJson(AllAllocatedEsimResponse data) =>
    json.encode(data.toJson());

class AllAllocatedEsimResponse {
  bool success;
  String errorCode;
  dynamic errorMsg;
  Obj? obj;

  AllAllocatedEsimResponse({
    required this.success,
    required this.errorCode,
    required this.errorMsg,
    required this.obj,
  });

  factory AllAllocatedEsimResponse.fromJson(Map<String, dynamic> json) =>
      AllAllocatedEsimResponse(
        success: json["success"],
        errorCode: json["errorCode"],
        errorMsg: json["errorMsg"],
        obj: json["obj"] == null ? null : Obj.fromJson(json["obj"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "errorCode": errorCode,
        "errorMsg": errorMsg,
        "obj": obj?.toJson(),
      };
}

class Obj {
  List<EsimList>? esimList;
  Pager? pager;

  Obj({
    required this.esimList,
    required this.pager,
  });

  factory Obj.fromJson(Map<String, dynamic> json) => Obj(
        esimList: List<EsimList>.from(
            json["esimList"].map((x) => EsimList.fromJson(x))),
        pager: Pager.fromJson(json["pager"]),
      );

  Map<String, dynamic> toJson() => {
        "esimList": List<dynamic>.from(esimList!.map((x) => x.toJson())),
        "pager": pager?.toJson(),
      };
}

class EsimList {
  List? operatorList;
  String esimTranNo;
  String orderNo;
  String transactionId;
  String imsi;
  String iccid;
  int smsStatus;
  String msisdn;
  String ac;
  String qrCodeUrl;
  String shortUrl;
  String smdpStatus;
  String eid;
  int activeType;
  int dataType;
  dynamic activateTime;
  String expiredTime;
  dynamic installationTime;
  int totalVolume;
  int totalDuration;
  String durationUnit;
  int orderUsage;
  String esimStatus;
  String pin;
  String puk;
  String apn;
  String ipExport;
  int supportTopUpType;
  String fupPolicy;
  List<LocationNetworkList>? coverage;
  List<AllAllocatedEsimPackageList> packageList;

  EsimList(
      {required this.esimTranNo,
      required this.operatorList,
      required this.orderNo,
      required this.transactionId,
      required this.imsi,
      required this.iccid,
      required this.smsStatus,
      required this.msisdn,
      required this.ac,
      required this.qrCodeUrl,
      required this.shortUrl,
      required this.smdpStatus,
      required this.eid,
      required this.activeType,
      required this.dataType,
      required this.activateTime,
      required this.expiredTime,
      required this.installationTime,
      required this.totalVolume,
      required this.totalDuration,
      required this.durationUnit,
      required this.orderUsage,
      required this.esimStatus,
      required this.pin,
      required this.puk,
      required this.apn,
      required this.ipExport,
      required this.supportTopUpType,
      required this.fupPolicy,
      required this.packageList,
      required this.coverage});

  factory EsimList.fromJson(Map<String, dynamic> json) => EsimList(
        esimTranNo: json["esimTranNo"],
        orderNo: json["orderNo"],
        operatorList: json["operatorList"],
        transactionId: json["transactionId"],
        imsi: json["imsi"],
        iccid: json["iccid"],
        smsStatus: json["smsStatus"],
        msisdn: json["msisdn"],
        ac: json["ac"],
        qrCodeUrl: json["qrCodeUrl"],
        shortUrl: json["shortUrl"],
        smdpStatus: json["smdpStatus"],
        eid: json["eid"],
        activeType: json["activeType"],
        dataType: json["dataType"],
        activateTime: json["activateTime"],
        expiredTime: json["expiredTime"],
        installationTime: json["installationTime"],
        totalVolume: json["totalVolume"],
        totalDuration: json["totalDuration"],
        durationUnit: json["durationUnit"],
        orderUsage: json["orderUsage"],
        esimStatus: json["esimStatus"],
        pin: json["pin"],
        puk: json["puk"],
        apn: json["apn"],
        ipExport: json["ipExport"],
        supportTopUpType: json["supportTopUpType"],
        fupPolicy: json["fupPolicy"],
        coverage: json["coverage"],
        packageList: List<AllAllocatedEsimPackageList>.from(json["packageList"]
            .map((x) => AllAllocatedEsimPackageList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "esimTranNo": esimTranNo,
        "orderNo": orderNo,
        "operatorList": operatorList,
        "transactionId": transactionId,
        "imsi": imsi,
        "iccid": iccid,
        "smsStatus": smsStatus,
        "msisdn": msisdn,
        "ac": ac,
        "qrCodeUrl": qrCodeUrl,
        "shortUrl": shortUrl,
        "smdpStatus": smdpStatus,
        "eid": eid,
        "activeType": activeType,
        "dataType": dataType,
        "activateTime": activateTime,
        "expiredTime": expiredTime,
        "installationTime": installationTime,
        "totalVolume": totalVolume,
        "totalDuration": totalDuration,
        "durationUnit": durationUnit,
        "orderUsage": orderUsage,
        "esimStatus": esimStatus,
        "pin": pin,
        "puk": puk,
        "apn": apn,
        "ipExport": ipExport,
        "supportTopUpType": supportTopUpType,
        "fupPolicy": fupPolicy,
        "coverage": coverage,
        "packageList": List<dynamic>.from(packageList.map((x) => x.toJson())),
      };
}

class AllAllocatedEsimPackageList {
  String packageName;
  String? packageCode;
  String? slug;
  String? esimTranNo;
  int duration;
  int volume;
  String? locationCode;
  String? createTime;

  AllAllocatedEsimPackageList({
    required this.packageName,
    required this.packageCode,
    required this.slug,
    required this.esimTranNo,
    required this.duration,
    required this.volume,
    required this.locationCode,
    required this.createTime,
  });

  factory AllAllocatedEsimPackageList.fromJson(Map<String, dynamic> json) =>
      AllAllocatedEsimPackageList(
        packageName: json["packageName"],
        packageCode: json["packageCode"],
        slug: json["slug"],
        esimTranNo: json["esimTranNo"],
        duration: json["duration"],
        volume: json["volume"],
        locationCode: json["locationCode"],
        createTime: json["createTime"],
      );

  Map<String, dynamic> toJson() => {
        "packageName": packageName,
        "packageCode": packageCode,
        "slug": slug,
        "esimTranNo": esimTranNo,
        "duration": duration,
        "volume": volume,
        "locationCode": locationCode,
        "createTime": createTime,
      };
}

class Pager {
  int pageSize;
  int pageNum;
  int total;

  Pager({
    required this.pageSize,
    required this.pageNum,
    required this.total,
  });

  factory Pager.fromJson(Map<String, dynamic> json) => Pager(
        pageSize: json["pageSize"],
        pageNum: json["pageNum"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "pageSize": pageSize,
        "pageNum": pageNum,
        "total": total,
      };
}
