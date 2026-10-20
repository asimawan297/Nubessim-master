import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/ui/custom_appbar.dart';

class NoTopupScreen extends StatelessWidget {
  const NoTopupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Top Up Error',
        titleColor: AppColors.black,
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/no_topup.png",
              height: 400,
              width: 400,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Oops! Something didn’t go as planned",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(
              height: 20,
            ),
            Text("Please note: This eSIM plan does not offer a \ntop-up facility",
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
