import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/modules/shop/cubits/payment_intent/payment_intent_state.dart';
import 'package:nubesim/modules/shop/model/stripe_input.dart';
import 'package:nubesim/modules/shop/repository/stripe_payment_repository.dart';
import '../../../../core/exceptions/api_error.dart';

class PaymentIntentCubit extends Cubit<PaymentIntentState> {
  final StripePaymentRepository _repository;

  PaymentIntentCubit(this._repository) : super(PaymentIntentState.initial());

  Future<void> createPaymentIntent(StripeInput input) async {
    emit(state.copyWith(status: PaymentIntentStatus.loading));

    try {
      String? response =
          await _repository.createPaymentIntent(input);
      emit(state.copyWith(
          status: PaymentIntentStatus.success,
          message: 'Payment successfully',
          paymentResponse: response));
    } on ApiError catch (e) {
      emit(state.copyWith(
          status: PaymentIntentStatus.error, message: e.message));
    }
  }
}
