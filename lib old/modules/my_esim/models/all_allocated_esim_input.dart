import 'dart:convert';

AllAllocatedEsimInput allAllocatedEsimInputFromJson(String str) =>
    AllAllocatedEsimInput.fromJson(json.decode(str));

String allAllocatedEsimInputToJson(AllAllocatedEsimInput data) =>
    json.encode(data.toJson());

class AllAllocatedEsimInput {
  String orderNo;
  String iccid;
  Pager pager;

  AllAllocatedEsimInput({
    required this.orderNo,
    required this.iccid,
    required this.pager,
  });

  factory AllAllocatedEsimInput.fromJson(Map<String, dynamic> json) =>
      AllAllocatedEsimInput(
        orderNo: json["orderNo"],
        iccid: json["iccid"],
        pager: Pager.fromJson(json["pager"]),
      );

  Map<String, dynamic> toJson() => {
        "orderNo": orderNo,
        "iccid": iccid,
        "pager": pager.toJson(),
      };

  factory AllAllocatedEsimInput.initial() {
    return AllAllocatedEsimInput(
      orderNo: "",
      iccid: "",
      pager: Pager(pageNum: 1, pageSize: 100),
    );
  }

  Map<String, dynamic> defaultJson() => {
        "orderNo": "",
        "iccid": "",
        "pager": {"pageNum": 1, "pageSize": 50}
      };
}

class Pager {
  int pageNum;
  int pageSize;

  Pager({
    required this.pageNum,
    required this.pageSize,
  });

  factory Pager.fromJson(Map<String, dynamic> json) => Pager(
        pageNum: json["pageNum"],
        pageSize: json["pageSize"],
      );

  Map<String, dynamic> toJson() => {
        "pageNum": pageNum,
        "pageSize": pageSize,
      };
}
