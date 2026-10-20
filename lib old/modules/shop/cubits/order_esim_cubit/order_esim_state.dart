import 'package:equatable/equatable.dart';
import 'package:nubesim/modules/shop/model/order_profile_response.dart';

enum OrderEsimStatus {
  initial,
  loading,
  success,
  error,
}

class OrderEsimState extends Equatable {
  final OrderEsimStatus status;
  final String message;

  // Normal order
  final OrderProfileObj? orderProfile;

  // Top-up order
  final TopUpOrderObj? topUpOrder;

  const OrderEsimState({
    required this.status,
    required this.message,
    this.orderProfile,
    this.topUpOrder,
  });

  factory OrderEsimState.initial() {
    return const OrderEsimState(
      status: OrderEsimStatus.initial,
      message: '',
    );
  }

  OrderEsimState copyWith({
    OrderEsimStatus? status,
    String? message,
    OrderProfileObj? orderProfile,
    TopUpOrderObj? topUpOrder,
  }) {
    return OrderEsimState(
      status: status ?? this.status,
      message: message ?? this.message,
      orderProfile: orderProfile ?? this.orderProfile,
      topUpOrder: topUpOrder ?? this.topUpOrder,
    );
  }

  @override
  List<Object?> get props =>
      [status, message, orderProfile, topUpOrder];
}



class TopUpOrderObj extends Equatable {
  final String transactionId;
  final String iccid;
  final DateTime expiredTime;
  final int totalVolume;
  final int totalDuration;
  final int orderUsage;
  final String topUpEsimTranNo;

  const TopUpOrderObj({
    required this.transactionId,
    required this.iccid,
    required this.expiredTime,
    required this.totalVolume,
    required this.totalDuration,
    required this.orderUsage,
    required this.topUpEsimTranNo,
  });

  factory TopUpOrderObj.fromJson(Map<String, dynamic> json) {
    return TopUpOrderObj(
      transactionId: json['transactionId'],
      iccid: json['iccid'],
      expiredTime: DateTime.parse(json['expiredTime']),
      totalVolume: json['totalVolume'],
      totalDuration: json['totalDuration'],
      orderUsage: json['orderUsage'],
      topUpEsimTranNo: json['topUpEsimTranNo'],
    );
  }

  @override
  List<Object?> get props => [
        transactionId,
        iccid,
        expiredTime,
        totalVolume,
        totalDuration,
        orderUsage,
        topUpEsimTranNo,
      ];
}
