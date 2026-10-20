// ignore_for_file: must_be_immutable

import 'package:esim_compatibility/esim_compatibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nubesim/config/config.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/generated/assets.dart';
import 'package:nubesim/modules/authentication/widgets/auth_required_wrapper.dart';
import 'package:nubesim/modules/shop/cubits/account_balance_cubit/account_balance_cubit.dart';
import 'package:nubesim/modules/shop/cubits/currency_cubit/currency_cubit.dart';
import 'package:nubesim/modules/shop/cubits/payment_intent/payment_intent_cubit.dart';
import 'package:nubesim/modules/shop/model/stripe_input.dart';
import 'package:nubesim/modules/shop/utils/payment_sheet_config.dart';
import 'package:nubesim/modules/shop/pages/additional_information.dart';
import 'package:nubesim/modules/shop/pages/coverage_screen.dart';
import 'package:nubesim/modules/shop/pages/device_not_supported.dart';
import 'package:nubesim/modules/shop/pages/secure_checkout_screen.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:nubesim/utils/extensions/padding_extension.dart';
import 'package:nubesim/utils/discounts.dart';
import 'package:nubesim/utils/helper_widgets.dart';
import 'package:nubesim/utils/order_utils.dart';
import 'package:sizer/sizer.dart';
import '../model/all_data_packages_model.dart';

class EsimPackageTile extends StatefulWidget {
  const EsimPackageTile(
      {super.key,
      required this.name,
      this.eSimStatus,
      this.dataType = 1,
      this.countryName,
      this.showBuyNow = true,
      this.package,
      this.dataDisplayOverride,
      this.iccid,
      this.myEsims = false,
      this.validityDisplayOverride,
      this.detailButton,
      this.topUpButton,
      this.stripeTopUp = false,
      this.isSingleSIM = false,
      this.isShowInstantCashback = false,
      this.isShowCountryNameImage = true});

  final String name;
  final String? eSimStatus;
  final String? countryName;
  final PackageList? package;
  final bool showBuyNow;
  final bool myEsims;
  final int dataType;
  final String? dataDisplayOverride;
  final String? iccid;
  final String? validityDisplayOverride;
  final VoidCallback? detailButton;
  final VoidCallback? topUpButton;
  final bool stripeTopUp;
  final bool isSingleSIM;
  final bool? isShowInstantCashback;
  final bool? isShowCountryNameImage;

  @override
  State<EsimPackageTile> createState() => _EsimPackageTileState();
}

class _EsimPackageTileState extends State<EsimPackageTile> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!widget.package: ${widget.package?.toJson()}");
    final double originalPrice = (widget.package?.retailPrice ?? 0).toDouble();

    final double discountPercent =
        Discounts.percentFor(widget.package?.dataType);

    final double discountedPrice =
        originalPrice - (originalPrice * discountPercent / 100);

    final String percentage = "${Discounts.format(discountPercent)}%";
    final quote = context.watch<CurrencyCubit>().state;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        gradient: LinearGradient(
            colors: [Color(0xffFF668B).withOpacity(.7), Color(0xffCA2045)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
      ),
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(widget.package?.packageCode ?? ''),
          if (widget.isShowCountryNameImage == true) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 0, 8),
              child: Row(children: [
                Flexible(
                  child: Row(children: [
                    Container(
                      height: 17.w,
                      width: 17.w,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(Assets.imagesCardIcon),
                        ),
                      ),
                    ),
                    Text(
                      extractCountry(
                          widget.countryName ?? extractCountry(widget.name)),
                      style: context.textTheme.displayLarge?.copyWith(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w900,
                          fontFamily: "Inter",
                          color: Colors.white,
                          overflow: TextOverflow.ellipsis),
                    ).paddingLeft(12.0),
                  ]),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.horizontal(left: Radius.circular(20)),
                      color: Color(0xffF9E4AC)),
                  child: Text(
                    "$percentage \nOff",
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                )
              ]),
            ),
            Divider(color: Colors.white.withOpacity(.1), thickness: 1.5)
          ],
          _rowBuilder(context,
              type: "COVERAGE",
              iconPath: Assets.svgCoverageIcon,
              isSingleSIM: widget.isSingleSIM,
              name: extractCountryCoverage(widget.name),
              locationNetworkList: (widget.package != null)
                  ? widget.package!.locationNetworkList
                  : null),
          Divider(color: Colors.white.withOpacity(.1), thickness: 1.5),
          if (widget.package != null) ...[
            _rowBuilder(
              context,
              type: "DATA",
              iconPath: Assets.svgDataTransferBoth,
              name: widget.package!.dataType == 2
                  ? "Unlimited"
                  : widget.dataDisplayOverride ??
                      (widget.package != null
                          ? formatBytes(widget.package!.volume)
                          : "25 GB"),
            ),
            Divider(color: Colors.white.withOpacity(.1), thickness: 1.5)
          ],
          _rowBuilder(
            context,
            type: "VALIDITY",
            iconPath: Assets.svgCalendarIcon,
            name: widget.validityDisplayOverride ??
                (widget.package != null
                    ? "${widget.package!.duration} Days"
                    : "30 Days"),
          ),
          if (widget.isShowInstantCashback == true) ...[
            Divider(color: Colors.white.withOpacity(.1), thickness: 1.5),
            _rowBuilder(
              context,
              type: "PRICE",
              iconPath: Assets.svgPriceIcon,
              nameWidget: Text(
                quote.format(double.parse(calculateTotal(
                    originalPrice,
                    isUnlimited: widget.package!.dataType == 2))),
                style: context.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          ] else ...[
            if (widget.package != null) ...[
              Divider(color: Colors.white.withOpacity(.1), thickness: 1.5),
              _rowBuilder(context,
                  type: "PRICE",
                  iconPath: Assets.svgPriceIcon,
                  nameWidget: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "${quote.format(double.parse(calculateTotal(discountedPrice, isUnlimited: widget.package!.dataType == 2)))} ",
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text:
                              quote.format(double.parse(calculateTotal(
                                  originalPrice,
                                  isUnlimited:
                                      widget.package!.dataType == 2))),
                          style: context.textTheme.bodyMedium?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Color(0xffD1D5DB),
                              color: Color(0xffD1D5DB),
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  )
                  // : Text(
                  //     "\$${calculateTotal(originalPrice)} ${widget.package!.currencyCode}",
                  //     style: context.textTheme.bodyLarge?.copyWith(
                  //       color: Colors.white,
                  //       fontWeight: FontWeight.w700,
                  //     ),
                  //   ),
                  )
            ]
          ],
          if (widget.isShowInstantCashback == true) ...[
            Divider(color: Colors.white.withOpacity(.1), thickness: 1.5),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Image.asset('assets/images/piggy_bank.png',
                        width: 24, height: 24, color: AppColors.textColor1),
                    const SizedBox(width: 8),
                    Text('Instant Cashback  $percentage',
                        style: context.textTheme.bodyMedium?.copyWith(
                            fontFamily: "Inter",
                            color: AppColors.textColor1,
                            fontWeight: FontWeight.bold)),
                  ]),
                  Expanded(
                    child: Text(
                      //  "-\$${calculateTotal(discountedPrice)} ${widget.package?.currencyCode}",
                      "-${quote.format(calculateFiveInstantPercentCashback(percentage, widget.package?.retailPrice, widget.package?.dataType))}",
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: context.textTheme.bodyMedium?.copyWith(
                          fontFamily: "Inter",
                          color: AppColors.textColor1,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(height: 10)
          ],
          widget.iccid != null
              ? _rowBuilder(
                  context,
                  type: "ICCID",
                  iconPath: Assets.svgCoverageIcon,
                  name: widget.iccid ?? '',
                )
              : SizedBox(),
          widget.iccid != null
              ? Divider(color: Colors.white.withOpacity(.1), thickness: 1.5)
              : SizedBox(),
          widget.myEsims ? SizedBox(height: 10) : SizedBox(),
          widget.myEsims
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.eSimStatus != "NEW")
                      GestureDetector(
                          onTap: widget.topUpButton ?? () {},
                          child: Container(
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Center(
                              child: Text(
                                "TOP UP",
                                textAlign: TextAlign.center,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                        onTap: widget.detailButton ?? () {},
                        child: Container(
                          width: 120,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              // border: Border.all(color: Colors.white),
                              color: Colors.white),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Center(
                            child: Text(
                              "DETAIL",
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: Color(0xfa878787),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )),
                  ],
                )
              : SizedBox(),
          if (widget.showBuyNow == true) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      // widget.package.
                      _showAdditionalInfoBottomSheet(
                        context,
                        AdditionalInfoCard(
                          locationNetworkList:
                              widget.package!.locationNetworkList,
                          volumn: formatBytes(widget.package!.volume),
                          dataType: widget.package!.dataType!,
                          ipExport: widget.package!.ipExport,
                          supportTopUpType: widget.package!.supportTopUpType,
                          description: widget.package!.name,
                          speed: widget.package!.speed,
                          fupPolicy: widget.package!.fupPolicy,
                          price: double.parse(calculateTotal(
                              widget.package!.retailPrice,
                              isUnlimited: widget.package!.dataType == 2)),
                          name: widget.package!.name,
                        ),
                      );
                    },
                    child: Container(
                      width: 120,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          // border: Border.all(color: Colors.white),
                          color: Colors.white),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Center(
                        child: Text(
                          "DETAIL",
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    // Check if user is logged in before proceeding to checkout
                    if (AuthRequiredWrapper.isUserLoggedIn()) {
                      final isCompatible =
                          await EsimCompatibility.isEsimCompatible();

                      if (isCompatible) {
                        if (widget.stripeTopUp) {
                          stripVoiceCallAction(widget.package!);
                        } else {
                          NavRouter.push(
                              context,
                              SecureCheckoutScreen(
                                name: widget.name,
                                package: widget.package,
                              ));
                        }
                      } else {
                        final result =
                            await NavRouter.push(context, DeviceNotSupported());
                        if (result != null && result == true) {
                          if (widget.stripeTopUp) {
                            stripVoiceCallAction(widget.package!);
                          } else {
                            NavRouter.push(
                                context,
                                SecureCheckoutScreen(
                                  name: widget.name,
                                  package: widget.package,
                                ));
                          }
                        }
                      }
                    } else if (widget.package != null && !widget.stripeTopUp) {
                      AuthRequiredWrapper.showLoginDialog(
                        context,
                        message:
                            "Please login to purchase this eSIM package",
                        isBottomBar: true,
                        checkoutName: widget.name,
                        checkoutPackage: widget.package,
                      );
                    } else {
                      AuthRequiredWrapper.showLoginDialog(
                        context,
                        message:
                            "Please login to purchase this eSIM package",
                        isBottomBar: true,
                      );
                    }
                  },
                  child: Container(
                    width: 120,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                            colors: [Color(0xffffe375), Color(0xfff9b400)])),
                    child: Text(
                      "Buy Now",
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  void _showAdditionalInfoBottomSheet(
      BuildContext context, Widget packageWidget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // for full height scrollable
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title + close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Additional Information",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),

              // Your Card widget
              Flexible(
                child: SingleChildScrollView(
                  child: packageWidget,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _rowBuilder(
    BuildContext context, {
    required String iconPath,
    required String type,
    String? name,
    Widget? nameWidget, // 👈 added
    bool isSingleSIM = false,
    locationNetworkList,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(iconPath),
              const SizedBox(width: 8),
              Text(
                type,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontFamily: "Inter",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          /// RIGHT SIDE
          (!isSingleSIM) && (locationNetworkList != null)
              ? InkWell(
                  onTap: () {
                    NavRouter.push(
                      context,
                      CoverageScreen(locations: locationNetworkList),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.white),
                    ),
                    child: Text(
                      "${locationNetworkList.length} COUNTRIES",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: nameWidget ?? // 👈 priority
                        Text(
                          name ?? "",
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
        ],
      ),
    );
  }

  bool confirm = false;
  double? discountPercentage;
  String? appliedPromoCode;
  String? appliedPromoDocId;
  bool promoChecked = false;
  String? stripeError;

  stripVoiceCallAction(
    PackageList package,
  ) async {
    // if (!confirm) {
    //   DisplayUtils.showSnackBar(context,
    //       "Please confirm your device is eSIM compatible.");
    //   return;
    // }

    // if (_selectedPaymentMethod != 'stripe')
    //   return;

    if (!mounted) return;
    setState(() {
      isLoading = true;
      stripeError = null;
    });

    try {
      num amountInCents = discountPercentage != null
          ? widget.package!.retailPrice -
              (widget.package!.retailPrice * discountPercentage! / 100)
          : widget.package!.retailPrice;
      amountInCents = (amountInCents / 100).round();
      final amountInDollar = amountInCents / 100;
      await context.read<CurrencyCubit>().load();
      final quote = context.read<CurrencyCubit>().state;
      // 1) Create PaymentIntent server-side (returns client_secret)
      await context.read<PaymentIntentCubit>().createPaymentIntent(StripeInput(
            amount: quote.toMinorUnits(amountInDollar).toString(),
            currency: quote.currency,
            fxQuoteId: quote.quoteId,
            // customerId:
            // ''
          ));

      final clientSecret =
          context.read<PaymentIntentCubit>().state.paymentResponse;

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

      await OrderService(context).placeOrder(
        package: widget.package!,
        name: widget.name,
        amountInDollar: amountInDollar,
        balanceState: context.read<AccountBalanceCubit>().state,
        appliedPromoDocId: appliedPromoDocId,
        stripeClientSecret: clientSecret,
      );
    } catch (e) {
      // print(e);
      // debugger();
      // if (!mounted) return;
      // setState(() {
      //   _stripeError = e.toString();
      // });
      // DisplayUtils.showSnackBar(
      //     context, "Error: $_stripeError");
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }
}

String extractCountryCoverage(String input) {
  // Extract country (everything before first digit). The provider/network
  // tag (e.g. "usip") used to be appended as "Country (usip)" — the client
  // asked for that to be hidden, so we just return the plain country name.
  final beforeDigits = input.split(RegExp(r'\d')).first;

  return beforeDigits.replaceAll(RegExp(r'[^A-Za-zÀ-ÖØ-öø-ÿ\s]'), '').trim();
}

String extractCountry(String input) {
  final beforeDigits = input.split(RegExp(r'\d')).first;

  final cleaned =
      beforeDigits.replaceAll(RegExp(r'[^A-Za-zÀ-ÖØ-öø-ÿ\s\-]'), '').trim();
  return cleaned;
}
