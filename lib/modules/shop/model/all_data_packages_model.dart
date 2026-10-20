// To parse this JSON data, do
//
//     final allDataPackagesModel = allDataPackagesModelFromJson(jsonString);

import 'dart:convert';

AllDataPackagesModel allDataPackagesModelFromJson(String str) =>
    AllDataPackagesModel.fromJson(json.decode(str));

String allDataPackagesModelToJson(AllDataPackagesModel data) =>
    json.encode(data.toJson());

class AllDataPackagesModel {
  dynamic errorCode;
  dynamic errorMsg;
  bool success;
  Obj obj;

  AllDataPackagesModel({
    required this.errorCode,
    required this.errorMsg,
    required this.success,
    required this.obj,
  });

  factory AllDataPackagesModel.fromJson(Map<String, dynamic> json) =>
      AllDataPackagesModel(
        errorCode: json["errorCode"],
        errorMsg: json["errorMsg"],
        success: json["success"],
        obj: Obj.fromJson(json["obj"]),
      );

  Map<String, dynamic> toJson() => {
        "errorCode": errorCode,
        "errorMsg": errorMsg,
        "success": success,
        "obj": obj.toJson(),
      };
}

class Obj {
  List<PackageList> packageList;

  Obj({
    required this.packageList,
  });

  factory Obj.fromJson(Map<String, dynamic> json) => Obj(
        packageList: List<PackageList>.from(
            json["packageList"].map((x) => PackageList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "packageList": List<dynamic>.from(packageList.map((x) => x.toJson())),
      };
}

class PackageList {
  String packageCode;
  String slug;
  String name;
  int price;
  String currencyCode;
  int volume;
  int? unusedValidTime;
  int duration;
  String durationUnit;
  String location;
  String description;
  int activeType;
  int supportTopUpType;
  String ipExport;
  bool favorite;
  int retailPrice;
  int? dataType;
  String speed;
  String fupPolicy;
  List<LocationNetworkList> locationNetworkList;

  PackageList({
    required this.packageCode,
    required this.name,
    required this.price,
    required this.slug,
    required this.currencyCode,
    required this.volume,
    required this.dataType,
    required this.unusedValidTime,
    required this.supportTopUpType,
    required this.ipExport,
    required this.duration,
    required this.durationUnit,
    required this.location,
    required this.description,
    required this.activeType,
    required this.favorite,
    required this.retailPrice,
    required this.speed,
    required this.fupPolicy,
    required this.locationNetworkList,
  });

  factory PackageList.fromJson(Map<String, dynamic> json) => PackageList(
        packageCode: json["packageCode"]??"",
        name: json["name"]??'',
        price: json["price"],
        currencyCode: json["currencyCode"]??"",
        volume: json["volume"],
        slug: json["slug"],
        ipExport: json["ipExport"],
        supportTopUpType: json["supportTopUpType"],
        unusedValidTime: json["unusedValidTime"],
        duration: json["duration"],
        durationUnit: json["durationUnit"]??"",
        location: json["location"]??"",
        description: json["description"]??"",
        activeType: json["activeType"],
        dataType: json["dataType"],
        favorite: json["favorite"],
        retailPrice: json["retailPrice"] ?? 0,
        speed: json["speed"]??"",
        fupPolicy: json["fupPolicy"] ?? "",
        locationNetworkList: List<LocationNetworkList>.from(
            json["locationNetworkList"]
                .map((x) => LocationNetworkList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "packageCode": packageCode,
        "name": name,
        "price": price,
        "currencyCode": currencyCode,
        "volume": volume,
        "ipExport": ipExport,
        "supportTopUpType": supportTopUpType,
        "unusedValidTime": unusedValidTime,
        "duration": duration,
        "durationUnit": durationUnit,
        "location": location,
        "slug": slug,
        "description": description,
        "activeType": activeType,
        "favorite": favorite,
        "retailPrice": retailPrice,
        "speed": speed,
        "fupPolicy": fupPolicy,
        "locationNetworkList":
            List<dynamic>.from(locationNetworkList.map((x) => x.toJson())),
      };
}

class LocationNetworkList {
  String locationName;
  String locationLogo;
  List<dynamic> operatorList;
  String? locationCode;

  LocationNetworkList({
    required this.locationName,
    required this.locationLogo,
    required this.operatorList,
    this.locationCode,
  });

  factory LocationNetworkList.fromJson(Map<String, dynamic> json) =>
      LocationNetworkList(
        locationName: json["locationName"],
        locationLogo: json["locationLogo"],
        operatorList: List<dynamic>.from(json["operatorList"].map((x) => x)),
        locationCode: json["locationCode"]?.toString(),
      );

  Map<String, dynamic> toJson() {
    final code = locationCode;
    return {
      "locationName": locationName,
      "locationLogo": locationLogo,
      "operatorList": List<dynamic>.from(operatorList.map((x) => x)),
      if (code != null && code.isNotEmpty) "locationCode": code,
    };
  }
}
