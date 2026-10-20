import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/ui/custom_appbar.dart';

class AfterInstallationTopupScreen extends StatelessWidget {
  const AfterInstallationTopupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Top-Ups',
        titleColor: AppColors.black,
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/available_topup.png"),
            SizedBox(
              height: 30,
            ),
            Text(
              "Top-ups are available Anytime",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
                "You can add more data or extend validity after you Start using your basic eSIM service",
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
