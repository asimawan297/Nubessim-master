class EsimDetailsInput {
  String? orderNo;
  String? esimTranNo;
  String? iccid;
  Pager? pager;

  EsimDetailsInput({
    this.orderNo,
    this.esimTranNo,
    this.iccid,
    this.pager,
  });

  factory EsimDetailsInput.fromJson(Map<String, dynamic> json) {
    return EsimDetailsInput(
      orderNo: json['orderNo'],
      esimTranNo: json['esimTranNo'],
      iccid: json['iccid'],
      pager: json['pager'] != null ? Pager.fromJson(json['pager']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderNo': orderNo,
      'esimTranNo': esimTranNo,
      'iccid': iccid,
      'pager': pager?.toJson(),
    };
  }
}

class Pager {
  int? pageNum;
  int? pageSize;

  Pager({
    this.pageNum,
    this.pageSize,
  });

  factory Pager.fromJson(Map<String, dynamic> json) {
    return Pager(
      pageNum: json['pageNum'],
      pageSize: json['pageSize'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageNum': pageNum,
      'pageSize': pageSize,
    };
  }
}
