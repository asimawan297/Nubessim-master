// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:nubesim/modules/shop/cubits/stripe_payment_cubit/stripe_payment_state.dart';
// import 'package:nubesim/modules/shop/model/create_customer_input_model.dart';
// import 'package:nubesim/modules/shop/model/payment_card_input.dart';
// import 'package:nubesim/modules/shop/repository/stripe_payment_repository.dart';
// class PaymentWithCardCubit extends Cubit<PaymentWithCardState> {
//   final PaymentWithCardRepository repository;

//   PaymentWithCardCubit(this.repository) : super(PaymentWithCardState.initial());

//   Future<void> payWithCard(PaymentWithCardInput input) async {
//     emit(state.copyWith(status: PaymentStatus.loading));
//     try {
//       print('[StripeCubit] payWithCard called with: ${input.toJson()}');
//       final response = await repository.makePaymentWithCard(input);
//       print('[StripeCubit] payWithCard success, client_secret: ${response.clientSecret}');
//       emit(state.copyWith(
//         status: PaymentStatus.success,
//         paymentResponse: response,
//         message: 'Payment successful',
//       ));
//       print("Payment is successful via Stripe");
//     } catch (e) {
//       print('[StripeCubit][Error] payWithCard failed: $e');
//       emit(state.copyWith(status: PaymentStatus.error, message: e.toString()));
//     }
//   }

//   Future<void> payWithNewCard({
//   required String email,
//   required String paymentMethodId,
//   required String amount,
// }) async {
//   emit(state.copyWith(status: PaymentStatus.loading));
//   try {
//     // Step 1: Create customer
//     print('[StripeCubit] payWithNewCard: creating customer for $email');
//     final customerId = await repository.createCustomer(
//       CreateCustomerInput(email: email, name: 'New Customer'),
//     );
//     print('[StripeCubit] payWithNewCard: customer created: $customerId');

//     // Step 2: Make payment
//     final input = PaymentWithCardInput(
//       amount: amount,
//       currency: "usd",
//       customerId: customerId,
//       paymentId: paymentMethodId,
//     );
//     print('[StripeCubit] payWithNewCard: creating payment intent with payload: ${input.toJson()}');

//     final response = await repository.makePaymentWithCard(input);
//     print('[StripeCubit] payWithNewCard: payment intent client_secret: ${response.clientSecret}');

//     emit(state.copyWith(
//       status: PaymentStatus.success,
//       paymentResponse: response,
//       message: 'Payment successful',
//     ));

//     print("Payment is successful via Stripe");
//   } catch (e) {
//     print('[StripeCubit][Error] payWithNewCard failed: $e');
//     emit(state.copyWith(status: PaymentStatus.error, message: e.toString()));
//   }
// }
// }
