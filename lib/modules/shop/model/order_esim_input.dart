class OrderSimInput {
  String transactionId;
  /// Optional total amount in minor units (e.g. cents) when required by `/esim/order`.
  int? amount;
  List<PackageInfoList> packageInfoList;

  OrderSimInput({
    required this.transactionId,
    this.amount,
    required this.packageInfoList,
  });

  factory OrderSimInput.fromJson(Map<String, dynamic> json) => OrderSimInput(
        transactionId: json["transactionId"],
        amount: json["amount"] == null ? null : (json["amount"] as num).toInt(),
        packageInfoList: List<PackageInfoList>.from(
            json["packageInfoList"].map((x) => PackageInfoList.fromJson(x))),
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "transactionId": transactionId,
      "packageInfoList":
          List<dynamic>.from(packageInfoList.map((x) => x.toJson())),
    };
    if (amount != null) {
      map["amount"] = amount;
    }
    return map;
  }
}

class PackageInfoList {
  String packageCode;
  int count;
  int periodNum;
  /// Optional line price in minor units when required by `/esim/order`.
  int? price;

  PackageInfoList({
    required this.packageCode,
    required this.count,
    required this.periodNum,
    this.price,
  });

  factory PackageInfoList.fromJson(Map<String, dynamic> json) =>
      PackageInfoList(
        packageCode: json["packageCode"],
        periodNum: json["periodNum"],
        count: json["count"],
        price: json["price"] == null ? null : (json["price"] as num).toInt(),
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "packageCode": packageCode,
      "count": count,
      "periodNum": periodNum,
    };
    if (price != null) {
      map["price"] = price;
    }
    return map;
  }
}
