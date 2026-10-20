import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/ui/primary_button.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:sizer/sizer.dart';

import '../../../generated/assets.dart';
import '../../../utils/heights_and_widths.dart';

class NubesCoins extends StatefulWidget {
  const NubesCoins({super.key});

  @override
  State<NubesCoins> createState() => _NubesCoinsState();
}

class _NubesCoinsState extends State<NubesCoins> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nubes Coins",
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textColor,
            fontSize: 19.0,
            fontFamily: "Inter",
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 30.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.0),
                  image: DecorationImage(
                    image: AssetImage(Assets.imagesPackageTileBg),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 18.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Traveller Card",
                            style: context.textTheme.titleMedium?.copyWith(
                              fontFamily: "Inter",
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          Row(
                            spacing: 8.0,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "5% Cashback",
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontFamily: "Inter",
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15.0,
                                ),
                              ),
                              Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 18.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Image.asset(
                              Assets.imagesCoinsGroup2,
                              height: 20.h,
                            ),
                          ),
                          Expanded(
                            child: Image.asset(
                              Assets.imagesCoinsGroup3,
                              height: 20.h,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Nubes Coins Balance",
                            style: context.textTheme.titleMedium?.copyWith(
                              fontFamily: "Inter",
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 15.0,
                            ),
                          ),
                          Text(
                            "\$150.00",
                            style: context.textTheme.titleMedium?.copyWith(
                              fontFamily: "Inter",
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              h2,
              Text(
                "Do you have a Nubes Coins or Promo Code?",
                style: context.textTheme.titleMedium?.copyWith(
                  fontFamily: "Inter",
                  color: Color(0xff606A71),
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                ),
              ),
              h0P5,
              Text(
                "You can redeem your promo code to add Nubes coins or an eSIM to your account. ",
                style: context.textTheme.titleMedium?.copyWith(
                  fontFamily: "Inter",
                  color: Color(0xff606A71),
                  fontWeight: FontWeight.normal,
                  fontSize: 12.0,
                ),
              ),
              h2,
              GradientButton(
                text: "Redeem voucher",
                gradientColors: [Color(0xffCD57B2), Color(0xff911b76)],
                onTap: () => print("Submit tapped"),
              ),
              h3,
              Text(
                "Transaction History",
                style: context.textTheme.titleMedium?.copyWith(
                  fontFamily: "Inter",
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
              h0P5,
              Text(
                "You don't have any Nubes Coins transactions yet.",
                style: context.textTheme.titleMedium?.copyWith(
                  fontFamily: "Inter",
                  color: Color(0xff606A71),
                  fontWeight: FontWeight.normal,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
