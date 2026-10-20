import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/core/exceptions/api_error.dart';
import 'package:nubesim/modules/shop/model/order_esim_input.dart';
import 'package:nubesim/modules/shop/repository/shop_repository.dart';

import '../../../../core/auth_service/firestore_service.dart';
import '../../../../core/model/order_history_model.dart';
import 'order_esim_state.dart';

class OrderEsimCubit extends Cubit<OrderEsimState> {
  final ShopRepository shopRepository;

  OrderEsimCubit({required this.shopRepository})
      : super(OrderEsimState.initial());

  Future<void> orderEsim(OrderSimInput input) async {
    emit(state.copyWith(status: OrderEsimStatus.loading));
    try {
      // debugger();
      final response = await shopRepository.orderEsim(input: input);

      emit(state.copyWith(
        status: OrderEsimStatus.success,
        message: "Order Successful",
        orderProfile: response.obj,
      ));
    } on ApiError catch (e) {
      emit(state.copyWith(
        status: OrderEsimStatus.error,
        message: e.message,
      ));
    }
  }

  Future<void> orderTopUpPlan(packageCode, iccid) async {
    emit(state.copyWith(status: OrderEsimStatus.loading));
    try {
      // debugger();
      final response =
          await shopRepository.purchaseTopUpData(packageCode, iccid);
      final topUpObj = TopUpOrderObj.fromJson(response['obj']);

      emit(state.copyWith(
        status: OrderEsimStatus.success,
        message: "Top-up successful",
        topUpOrder: topUpObj,
      ));
    } on ApiError catch (e) {
      emit(state.copyWith(
        status: OrderEsimStatus.error,
        message: e.message,
      ));
    }
  }

  // Function to store order history
  Future<void> storeOrderHistory(OrderHistoryModel orderHistory) async {
    try {
      await FireStoreService().storeOrderHistory(
          orderHistory); // Call the FireStoreService method to store data
      // print('Order history stored successfully.');
    } catch (e) {
      // print('Error storing order history: $e');
    }
  }
}
