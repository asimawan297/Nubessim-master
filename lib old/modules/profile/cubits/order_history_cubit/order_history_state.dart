import 'package:equatable/equatable.dart';

import '../../../../core/model/order_history_model.dart';

enum OrderHistoryStatus {
  initial, // Default state before any action
  loading, // When data is being fetched
  success, // When data is successfully fetched
  error, // When an error occurs
}

class OrderHistoryState extends Equatable {
  final OrderHistoryStatus status; // ✅ Correct type
  final String message;
  final List<OrderHistoryModel> orders;

  const OrderHistoryState({
    required this.status,
    required this.message,
    required this.orders,
  });

  factory OrderHistoryState.initial() {
    return const OrderHistoryState(
      status: OrderHistoryStatus.initial,
      message: '',
      orders: [],
    );
  }

  OrderHistoryState copyWith({
    OrderHistoryStatus? status,
    String? message,
    List<OrderHistoryModel>? orders,
  }) {
    return OrderHistoryState(
      status: status ?? this.status,
      message: message ?? this.message,
      orders: orders ?? this.orders,
    );
  }

  @override
  List<Object?> get props => [status, message, orders];
}
