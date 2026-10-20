import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/ui/primary_button.dart';
import 'package:nubesim/utils/heights_and_widths.dart';

import '../../../generated/assets.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  void _handleSignIn(BuildContext context) {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              h3,
              // App Logo
              // SvgPicture.asset(
              //   Assets.svgSignInLogo,
              //   height: 55.0,
              // ),
              Image.asset(
                Assets.imagesLogo, // your Figma exported logo
                height: 100,
              ),
              h3,

              // Title
              const Text(
                'Check Your Email',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  fontFamily: 'Inter',
                ),
              ),
              h2,

              // Success Checkmark Icon
              SvgPicture.asset('assets/svg/success.svg'),
              h2,

              // Success Message
              const Text(
                'Password reset link sent!',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              h2,

              // Instructional Text
              const Text(
                'Check your email and click the reset link to create a new password. Then you can sign in with your new password.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: AppColors.greyColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              h4,
              PrimaryButton(
                onPressed: () => _handleSignIn(context),
                backgroundColor: AppColors.primaryColor,
                borderColor: AppColors.primaryColor,
                hMargin: 0,
                height: 48.0,
                elevation: 6.0,
                borderRadius: 12.0,
                title: 'Continue',
              ),
              // SizedBox(
              //   width: double.infinity,
              //   height: 56.0,
              //   child: ElevatedButton(
              //     onPressed: () => _handleSignIn(context),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.transparent,
              //       shadowColor: Colors.transparent,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12.0),
              //       ),
              //     ).copyWith(
              //       backgroundColor:
              //           MaterialStateProperty.all(Colors.transparent),
              //     ),
              //     child: Container(
              //       decoration: BoxDecoration(
              //         gradient: const LinearGradient(
              //           colors: [AppColors.purple, AppColors.primaryColor],
              //           begin: Alignment.centerLeft,
              //           end: Alignment.centerRight,
              //         ),
              //         borderRadius: BorderRadius.circular(12.0),
              //       ),
              //       child: const Center(
              //         child: Text(
              //           'Sign In',
              //           style: TextStyle(
              //             color: Colors.white,
              //             fontSize: 18.0,
              //             fontWeight: FontWeight.bold,
              //             fontFamily: 'Inter',
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

              h3,
            ],
          ),
        ),
      ),
    );
  }
}
