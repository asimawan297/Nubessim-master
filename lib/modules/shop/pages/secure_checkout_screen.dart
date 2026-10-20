import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/core/auth_service/firestore_service.dart';
import 'package:nubesim/modules/shop/cubits/account_balance_cubit/account_balance_cubit.dart';
import 'package:nubesim/modules/shop/cubits/currency_cubit/currency_cubit.dart';
import 'package:nubesim/modules/shop/cubits/payment_intent/payment_intent_cubit.dart';
import 'package:nubesim/modules/shop/model/stripe_input.dart';
import 'package:nubesim/modules/shop/utils/payment_sheet_config.dart';
import 'package:nubesim/modules/shop/widgets/eSIM_package_tile.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:nubesim/utils/order_utils.dart';
import '../../../utils/discounts.dart';
import '../../../utils/helper_widgets.dart';
import '../model/all_data_packages_model.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class SecureCheckoutScreen extends StatefulWidget {
  const SecureCheckoutScreen(
      {super.key,
      required this.name,
      this.iccid,
      this.routeType,
      this.package});

  final PackageList? package;
  final String? routeType;
  final String? iccid;
  final String name;

  @override
  State<SecureCheckoutScreen> createState() => _SecureCheckoutScreenState();
}

class _SecureCheckoutScreenState extends State<SecureCheckoutScreen> {
  bool confirm = false;
  double? discountPercentage;
  String? appliedPromoCode;
  String? appliedPromoDocId;
  bool promoChecked = false;
  bool isPromoCodeLoad = false;
  bool promoErrorChecked = false;
  String name = "";
  String email = "";
  // Stripe integration additions
  // CardFieldInputDetails? _card; // Not used with PaymentSheet flow
  bool _isLoading = false;
  String? stripeError;

  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController promoController = TextEditingController();
  final TextEditingController coinsController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _whatsappController.dispose();
    promoController.dispose();
    coinsController.dispose();
    super.dispose();
  }

  double getDiscountedPrice({
    required double price,
    required int? dataType,
  }) {
    final double discountPercent = Discounts.percentFor(dataType);

    final double discountedPrice = price * (1 - discountPercent / 100);

    return discountedPrice;
  }

  @override
  Widget build(BuildContext context) {
    final quote = context.watch<CurrencyCubit>().state;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Secure Checkout",
          style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textColor,
              fontSize: 19.0,
              fontFamily: "Inter"),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(66, 121, 121, 121),
              offset: Offset(0, -3), // Top shadow
              blurRadius: 8.0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox and Text
              Text(
                "Before completing this order, please confirm your  device is eSIM compatible and network-unlocked. ",
                style: TextStyle(
                    color: Color(0xfa878787),
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 20),
              // Amount and Button Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side: Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "AMOUNT TO BE PAID",
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            () {
                              double retailPrice = double.parse(
                                  widget.package?.retailPrice.toString() ??
                                      "0");

                              // Step 1: package discount
                              double packagePrice = getDiscountedPrice(
                                price: retailPrice,
                                dataType: widget.package?.dataType,
                              );

                              // Step 2: tax + rounding
                              double priceWithTax = double.parse(calculateTotal(
                                  packagePrice,
                                  isUnlimited: widget.package?.dataType == 2));

                              // Step 3: coupon discount
                              double finalPrice = discountPercentage != null
                                  ? priceWithTax -
                                      (priceWithTax * discountPercentage! / 100)
                                  : priceWithTax;

                              return quote.format(finalPrice);
                            }(),
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontSize: 19.0,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          // : Text(
                          //     () {
                          //       num originalPrice = calculateTotalInt(
                          //               widget.package!.retailPrice) -
                          //           calculateFivePercentCashback(
                          //               widget.package!.retailPrice);
                          //       num discountedPrice =
                          //           discountPercentage != null
                          //               ? originalPrice -
                          //                   (originalPrice *
                          //                       discountPercentage! /
                          //                       100)
                          //               : originalPrice;
                          //       return "\$${discountedPrice.toStringAsFixed(2)} ${widget.package?.currencyCode ?? 'USD'}";
                          //     }(),
                          //     style: context.textTheme.bodyLarge?.copyWith(
                          //       fontSize: 19.0,
                          //       fontWeight: FontWeight.w900,
                          //       color: AppColors.primaryColor,
                          //     ),
                          //   ),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xffCD57B2),
                            size: 24.0,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Right side: Button
                  InkWell(
                    // Your existing onTap logic...
                    onTap: () async {
                      final whatsappNumber = _whatsappController.text.trim();
                      if (whatsappNumber.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'WhatsApp number is required before payment.',
                            ),
                          ),
                        );
                        return;
                      }

                      if (!mounted) return;
                      setState(() {
                        _isLoading = true;
                        stripeError = null;
                      });

                      try {
                        double retailPrice = double.parse(
                            widget.package?.retailPrice.toString() ?? "0");
                        double packagePrice = getDiscountedPrice(
                          price: retailPrice,
                          dataType: widget.package?.dataType,
                        );
                        double priceWithTax = double.parse(calculateTotal(
                            packagePrice,
                            isUnlimited: widget.package?.dataType == 2));
                        double finalPrice = discountPercentage != null
                            ? priceWithTax -
                                (priceWithTax * discountPercentage! / 100)
                            : priceWithTax;
                        final double amountInDollar =
                            double.parse(finalPrice.toStringAsFixed(2));
                        await context.read<CurrencyCubit>().load();
                        final quote = context.read<CurrencyCubit>().state;
                        await FirebaseAnalytics.instance.logEvent(
                          name: 'begin_checkout',
                          parameters: {
                            'currency': quote.currency,
                            'value': quote.localizedAmount(amountInDollar),
                            'plan_name': widget.package?.packageCode ?? '',
                          },
                        );
                        await context
                            .read<PaymentIntentCubit>()
                            .createPaymentIntent(StripeInput(
                              amount: quote
                                  .toMinorUnits(amountInDollar)
                                  .toString(),
                              currency: quote.currency,
                              fxQuoteId: quote.quoteId,
                              whatsappNumber: whatsappNumber,

                              // customerId:
                              // ''
                            ));
                        final clientSecret = context
                            .read<PaymentIntentCubit>()
                            .state
                            .paymentResponse;
                        if (clientSecret == null) {
                          throw Exception('Client secret not returned');
                        }
                        // 2) Initialize PaymentSheet
                        await Stripe.instance.initPaymentSheet(
                          paymentSheetParameters: nubesPaymentSheet(
                            clientSecret: clientSecret,
                            currencyCode: quote.currency,
                            payButtonLabel: nubesPayButtonLabel(
                              currencyCode: quote.currency,
                              localAmount: quote.localizedAmount(amountInDollar),
                            ),
                          ),
                        );
                        var paid = false;
                        try {
                          await Stripe.instance.presentPaymentSheet();
                          paid = true;
                        } catch (_) {
                          paid = await paymentAlreadyTaken(clientSecret);
                        }
                        if (!paid || !mounted) return;
                        await FirebaseAnalytics.instance.logEvent(
                          name: 'add_payment_info',
                          parameters: {
                            'currency': quote.currency,
                            'value': quote.localizedAmount(amountInDollar),
                          },
                        );
                        FocusScope.of(context).unfocus();
                        // 3. Place order (only after payment success)

                        if (widget.routeType == "TOP_UP") {
                          await OrderService(context)
                              .purchaseTopUpData(widget.package!.packageCode,
                                  widget.iccid ?? "",
                                  name: widget.name,
                                  package: widget.package,
                                  orderNumber: "")
                              .then((value) {});
                        } else {
                          await OrderService(context).placeOrder(
                            package: widget.package,
                            name: widget.name,
                            amountInDollar: amountInDollar,
                            balanceState:
                                context.read<AccountBalanceCubit>().state,
                            appliedPromoDocId: appliedPromoDocId,
                            stripeClientSecret: clientSecret,
                            stripeCustomerEmail:
                                email.isNotEmpty ? email : null,
                            whatsappNumber: whatsappNumber,
                          );
                        }
                        await FirebaseAnalytics.instance.logPurchase(
                          currency: quote.currency,
                          value: quote.localizedAmount(amountInDollar),
                          transactionId:
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          items: [
                            AnalyticsEventItem(
                              itemId: widget.package?.packageCode ?? '',
                              itemName: widget.package?.name ?? '',
                              price: quote.localizedAmount(amountInDollar),
                              quantity: 1,
                            ),
                          ],
                        );
                      } catch (_) {
                      } finally {
                        if (!mounted) return;
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    child: Container(
                      width: 150,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        gradient: const LinearGradient(
                          colors: [Color(0xffCD57B2), Color(0xff911b76)],
                        ),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                "Complete Order",
                                style: context.textTheme.bodyLarge?.copyWith(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: EsimPackageTile(
                    name: widget.name,
                    showBuyNow: false,
                    isShowCountryNameImage: false,
                    isShowInstantCashback: true,
                    package: widget.package),
              ),
              const SizedBox(height: 24),
              const Text(
                'WhatsApp Number',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
                onTapOutside: (event) {
                  Focus.of(context).unfocus();
                },
                decoration: InputDecoration(
                  hintText: 'Enter WhatsApp number (e.g. +355672432897)',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Apply section
              const Text(
                'Apply Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Please enter your Promo or Referral code to apply',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: promoController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      onChanged: (value) {
                        setState(() {
                          discountPercentage = null;
                          appliedPromoCode = null;
                          appliedPromoDocId = null;
                          promoChecked = false;
                        });
                      },
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                      ],
                      onTapOutside: (event) {
                        Focus.of(context).unfocus();
                      },
                      decoration: InputDecoration(
                        hintText: 'Code',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5), // light gray
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: promoController.text.isEmpty
                        ? null
                        : () async {
                            setState(() {
                              isPromoCodeLoad = true;
                            });

                            final code = promoController.text.trim();
                            final result = await FireStoreService()
                                .validatePromoCode(code);
                            if (result != null) {
                              final data =
                                  result['data'] as Map<String, dynamic>;

                              final discount =
                                  double.tryParse(data['discount']) ?? 0.0;
                              final docId = result['docId'];

                              // callback trigger karo
                              setState(() {
                                isPromoCodeLoad = false;

                                discountPercentage = discount;
                                appliedPromoCode = code;
                                appliedPromoDocId = docId;
                                promoChecked = true;
                                promoErrorChecked = false;
                              });
                            } else {
                              setState(() {
                                isPromoCodeLoad = false;
                                promoChecked = false;
                                promoErrorChecked = true;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0E0E0), // light gray
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                    child: isPromoCodeLoad
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ))
                        : const Text('Apply'),
                  ),
                ],
              ),
              if (promoChecked) ...[
                SizedBox(height: 10),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: AppColors.green),
                          SizedBox(width: 5),
                          Expanded(
                            child: Text(
                                "Your promo code has been applied successfully! Discount: ${discountPercentage?.toStringAsFixed(0)}%",
                                style: context.textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.green)),
                          ),
                        ]),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        discountPercentage = null;
                        appliedPromoCode = null;
                        promoController.clear();
                        appliedPromoDocId = null;
                        promoChecked = false;
                      });
                    },
                  ),
                ]),
              ] else if (promoErrorChecked) ...[
                SizedBox(height: 10),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.cancel, color: AppColors.red),
                          SizedBox(width: 5),
                          Expanded(
                            child: Text(
                                "Your promo code is invalid or expired. Please try again",
                                style: context.textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.red)),
                          ),
                        ]),
                  ),
                  SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        discountPercentage = null;
                        appliedPromoCode = null;
                        promoController.clear();
                        appliedPromoDocId = null;
                        promoChecked = false;
                      });
                    },
                  ),
                ]),
              ]
            ]),
          )),
    );
  }
}

// Returns 5% cashback for a given price
calculateFivePercentCashback(price, datatype) {
  num result = num.parse(
      (calculateTotalInt(price, isUnlimited: datatype == 2) * 0.05)
          .toStringAsFixed(3));
  return result;
}

num calculateFiveInstantPercentCashback(
    String? discount, dynamic price, int? datatype) {
  if (discount == null || discount.isEmpty) {
    return 0;
  }

  final cleanDiscount = discount.replaceAll('%', '');

  final percent = double.tryParse(cleanDiscount);

  if (percent == null) {
    return 0;
  }

  final discountValue = percent / 100;

  final totalPrice = calculateTotalInt(price, isUnlimited: datatype == 2);

  final result = totalPrice * discountValue;

  return double.parse(result.toStringAsFixed(2));
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
