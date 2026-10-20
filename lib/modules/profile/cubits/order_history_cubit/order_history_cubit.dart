import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/core/exceptions/api_error.dart';

import '../../../../core/auth_service/firestore_service.dart';
import 'order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  final FireStoreService fireStoreService;

  OrderHistoryCubit({required this.fireStoreService})
      : super(OrderHistoryState.initial());

  Future<void> fetchOrderList(String uid) async {
    emit(state.copyWith(status: OrderHistoryStatus.loading));

    try {
      final orderList = await fireStoreService.fetchOrderHistoryListByUID(uid);
      emit(state.copyWith(
        status: OrderHistoryStatus.success,
        orders: orderList,
      ));
    } on ApiError catch (e) {
      emit(state.copyWith(
        status: OrderHistoryStatus.error,
        message: e.message,
      ));
    }
  }
}
