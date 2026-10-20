// To parse this JSON data, do
//
//     final esimDetailModel = esimDetailModelFromJson(jsonString);

import 'dart:convert';

import 'all_esim_model.dart';

EsimDetailModel esimDetailModelFromJson(String str) => EsimDetailModel.fromJson(json.decode(str));

String esimDetailModelToJson(EsimDetailModel data) => json.encode(data.toJson());

class EsimDetailModel {
    bool success;
    String errorCode;
    dynamic errorMsg;
    Obj? obj;

    EsimDetailModel({
        required this.success,
        required this.errorCode,
        required this.errorMsg,
        required this.obj,
    });

    factory EsimDetailModel.fromJson(Map<String, dynamic> json) => EsimDetailModel(
        success: json["success"],
        errorCode: json["errorCode"],
        errorMsg: json["errorMsg"],
        obj: Obj.fromJson(json["obj"]),
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
        esimList: List<EsimList>.from(json["esimList"].map((x) => EsimList.fromJson(x))),
        pager: Pager.fromJson(json["pager"]),
    );

    Map<String, dynamic> toJson() => {
        "esimList": List<dynamic>.from(esimList!.map((x) => x.toJson())),
        "pager": pager?.toJson(),
    };
}

class PackageList {
    String packageName;
    String packageCode;
    String slug;
    int duration;
    int volume;
    String locationCode;
    String createTime;

    PackageList({
        required this.packageName,
        required this.packageCode,
        required this.slug,
        required this.duration,
        required this.volume,
        required this.locationCode,
        required this.createTime,
    });

    factory PackageList.fromJson(Map<String, dynamic> json) => PackageList(
        packageName: json["packageName"],
        packageCode: json["packageCode"],
        slug: json["slug"],
        duration: json["duration"],
        volume: json["volume"],
        locationCode: json["locationCode"],
        createTime: json["createTime"],
    );

    Map<String, dynamic> toJson() => {
        "packageName": packageName,
        "packageCode": packageCode,
        "slug": slug,
        "duration": duration,
        "volume": volume,
        "locationCode": locationCode,
        "createTime": createTime,
    };
}

