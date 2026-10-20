import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/generated/assets.dart';
import 'package:nubesim/ui/custom_appbar.dart';
import 'package:nubesim/ui/primary_button.dart';
import 'package:nubesim/utils/heights_and_widths.dart';

class ReferAndEarnScreen extends StatelessWidget {
  const ReferAndEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Refer and Earn',
        titleColor: AppColors.textColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            h6,
            Image.asset(Assets.imagesReferandearn),
            h2,
            SizedBox(
              width: 260,
              child: Text(
                textAlign: TextAlign.center,
                "Refer more, Earn More",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 21.0,
                    ),
              ),
            ),
            h1,
            Align(
              alignment: Alignment.center,
              child: PrimaryButton(
                onPressed: () {},
                title: "How To Reffer",
                backgroundColor: AppColors.lightGrey,
                borderColor: AppColors.transparent,
                shadowColor: AppColors.transparent,
                borderRadius: 100,
                titleColor: AppColors.black,
                width: 160,
                fontSize: 12,
              ),
            ),
            Spacer(),
            GradientButton(
              height: 50,
              width: 250,
              text: 'Share Your Referral Code',
              gradientColors: [Color(0xffcd57b2), Color(0xff911b76)],
              suffixIcon: SvgPicture.asset(Assets.svgSend2),
              fontSize: 12,
              iconSize: 12,
              fontWeight: FontWeight.w700,
              onTap: () => print("Tapped"),
            ),
            h8,
          ],
        ),
      ),
    );
  }
}
