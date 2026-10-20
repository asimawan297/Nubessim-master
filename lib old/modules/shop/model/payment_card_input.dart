class PaymentWithCardInput {
  final String amount;
  final String currency;
  final String customerId;
  final String paymentId; // legacy, not used in toJson for PaymentSheet flow

  PaymentWithCardInput(
      {required this.amount,
      required this.currency,
      required this.customerId,
      required this.paymentId});

  Map<String, dynamic> toJson() {
    // Create an unconfirmed PaymentIntent suitable for client-side confirmation
    // and PaymentSheet presentation. Do not include payment_method or confirm here.
    return {
      'amount': amount,
      'currency': currency,
      if (customerId.isNotEmpty) 'customer': customerId,
      // Enable automatic payment methods so Stripe figures out the best flow
      'automatic_payment_methods[enabled]': 'true',
    };
  }
}
