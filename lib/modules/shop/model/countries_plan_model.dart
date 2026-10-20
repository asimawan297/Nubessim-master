// To parse this JSON data, do
//
//     final countriesPlanModel = countriesPlanModelFromJson(jsonString);

import 'dart:convert';

CountriesPlanModel countriesPlanModelFromJson(String str) =>
    CountriesPlanModel.fromJson(json.decode(str));

String countriesPlanModelToJson(CountriesPlanModel data) =>
    json.encode(data.toJson());

class CountriesPlanModel {
  dynamic errorCode;
  dynamic errorMsg;
  bool success;
  Obj obj;

  CountriesPlanModel({
    required this.errorCode,
    required this.errorMsg,
    required this.success,
    required this.obj,
  });

  factory CountriesPlanModel.fromJson(Map<String, dynamic> json) =>
      CountriesPlanModel(
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
  String name;
  int price;
  CurrencyCode currencyCode;
  int volume;
  int unusedValidTime;
  int duration;
  DurationUnit durationUnit;
  String location;
  String description;
  int activeType;

  PackageList({
    required this.packageCode,
    required this.name,
    required this.price,
    required this.currencyCode,
    required this.volume,
    required this.unusedValidTime,
    required this.duration,
    required this.durationUnit,
    required this.location,
    required this.description,
    required this.activeType,
  });

  factory PackageList.fromJson(Map<String, dynamic> json) => PackageList(
        packageCode: json["packageCode"],
        name: json["name"],
        price: json["price"],
        currencyCode: currencyCodeValues.map[json["currencyCode"]]!,
        volume: json["volume"],
        unusedValidTime: json["unusedValidTime"],
        duration: json["duration"],
        durationUnit: durationUnitValues.map[json["durationUnit"]]!,
        location: json["location"],
        description: json["description"],
        activeType: json["activeType"],
      );

  Map<String, dynamic> toJson() => {
        "packageCode": packageCode,
        "name": name,
        "price": price,
        "currencyCode": currencyCodeValues.reverse[currencyCode],
        "volume": volume,
        "unusedValidTime": unusedValidTime,
        "duration": duration,
        "durationUnit": durationUnitValues.reverse[durationUnit],
        "location": location,
        "description": description,
        "activeType": activeType,
      };
}

enum CurrencyCode { USD }

final currencyCodeValues = EnumValues({"USD": CurrencyCode.USD});

enum DurationUnit { DAY }

final durationUnitValues = EnumValues({"DAY": DurationUnit.DAY});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
