// import 'package:nubesim/modules/shop/model/stripe_response.dart';

// enum PaymentStatus { initial, loading, success, error }

// class PaymentWithCardState {
//   final PaymentStatus status;
//   final String message;
//   final StripePaymentResponse? paymentResponse;

//   PaymentWithCardState({
//     required this.status,
//     required this.message,
//     required this.paymentResponse,
//   });

//   factory PaymentWithCardState.initial() => PaymentWithCardState(
//         status: PaymentStatus.initial,
//         message: '',
//         paymentResponse: null,
//       );

//   PaymentWithCardState copyWith({
//     PaymentStatus? status,
//     String? message,
//     StripePaymentResponse? paymentResponse,
//   }) {
//     return PaymentWithCardState(
//       status: status ?? this.status,
//       message: message ?? this.message,
//       paymentResponse: paymentResponse ?? this.paymentResponse,
//     );
//   }
// }
