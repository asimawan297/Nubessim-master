class StripeInput {
  final String amount;
  final String currency;
  final String? whatsappNumber;
  final String? fxQuoteId;
  // final String customerId;

  StripeInput({
    required this.amount,
    required this.currency,
    this.whatsappNumber,
    this.fxQuoteId,
    // required this.customerId
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      if (whatsappNumber != null && whatsappNumber!.trim().isNotEmpty)
        'whatsapp_number': whatsappNumber!.trim(),
      if (fxQuoteId != null && fxQuoteId!.trim().isNotEmpty)
        'fx_quote': fxQuoteId!.trim(),
      // 'customer': customerId,
    };
  }
}
