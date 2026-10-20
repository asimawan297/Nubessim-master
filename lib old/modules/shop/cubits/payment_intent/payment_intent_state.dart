
enum PaymentIntentStatus {
  initial,
  loading,
  success,
  error,
}

class PaymentIntentState {
  final PaymentIntentStatus status;
  final String message;
  final String? paymentResponse;

  PaymentIntentState({
    required this.status,
    required this.message,
    required this.paymentResponse,
  });

  factory PaymentIntentState.initial() {
    return PaymentIntentState(
        status: PaymentIntentStatus.initial,
        message: '',
        paymentResponse: null);
  }

  PaymentIntentState copyWith({
    PaymentIntentStatus? status,
    String? message,
    String? paymentResponse,
  }) {
    return PaymentIntentState(
      status: status ?? this.status,
      message: message ?? this.message,
      paymentResponse: paymentResponse ?? this.paymentResponse,
    );
  }
}
