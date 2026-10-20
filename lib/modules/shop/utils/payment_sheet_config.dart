import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

/// Stripe account country. Apple Pay and Google Pay both require it.
const String kMerchantCountryCode = 'CA';

/// `Pay CAD 12.50`, so a dollar sign is not the only currency cue.
String nubesPayButtonLabel({
  required String currencyCode,
  required num localAmount,
}) {
  final code = currencyCode.toUpperCase();
  final amount = code == 'PKR'
      ? localAmount.round().toString()
      : localAmount.toStringAsFixed(2);
  return 'Pay $code $amount';
}

/// True when Stripe has already taken the money, even if the sheet threw.
Future<bool> paymentAlreadyTaken(String clientSecret) async {
  try {
    final intent = await Stripe.instance.retrievePaymentIntent(clientSecret);
    return intent.status == PaymentIntentsStatus.Succeeded ||
        intent.status == PaymentIntentsStatus.RequiresCapture;
  } catch (_) {
    return false;
  }
}

SetupPaymentSheetParameters nubesPaymentSheet({
  required String clientSecret,
  required String currencyCode,
  required String payButtonLabel,
}) {
  return SetupPaymentSheetParameters(
    paymentIntentClientSecret: clientSecret,
    primaryButtonLabel: payButtonLabel,
    merchantDisplayName: 'Nubes',
    returnURL: 'nubesim://payment-success',
    style: ThemeMode.system,
    applePay: const PaymentSheetApplePay(
      merchantCountryCode: kMerchantCountryCode,
    ),
    googlePay: PaymentSheetGooglePay(
      merchantCountryCode: kMerchantCountryCode,
      currencyCode: currencyCode.toUpperCase(),
      testEnv: false,
    ),
  );
}
