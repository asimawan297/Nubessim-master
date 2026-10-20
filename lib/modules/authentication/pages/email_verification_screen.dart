import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nubesim/common/email_cubit/email_cubit.dart';
import 'package:nubesim/common/model/send_email_input.dart';
import 'package:nubesim/config/routes/nav_router.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/constants/keys.dart';
import 'package:nubesim/core/di/service_locator.dart';
import 'package:nubesim/core/storage_service/storage_service.dart';
import 'package:nubesim/modules/authentication/pages/reset_password_screen.dart';
import 'package:nubesim/modules/authentication/repository/auth_repository.dart';
import 'package:nubesim/modules/authentication/auth_navigation.dart';
import 'package:nubesim/ui/primary_button.dart';
import 'package:nubesim/utils/display/display_utils.dart';
import 'package:nubesim/utils/heights_and_widths.dart';
import 'package:nubesim/utils/html_templates.dart';
import '../../../generated/assets.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String get _verificationCode {
    return _controllers.map((controller) => controller.text).join();
  }

  void _handleContinue() async {
    if (_verificationCode.length != 4) {    
      DisplayUtils.showToast(context, 'Please enter the complete 4-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get AuthRepository from service locator
      final userOTP = _verificationCode.toUpperCase();
      if (userOTP == OTPSent) {
        await FirebaseFirestore.instance
            .collection('user_data')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'isEmailVerified': true,
        });
        

        DisplayUtils.showToast(context, "OTP Verified Successfully");

      

        AuthNavigation.completeAuthentication(context);
      } else {        

                DisplayUtils.showToast(context, "Invalid OTP, Please try again");

        // Navigate to reset password screen
      }
    } catch (e) {
        DisplayUtils.showToast(context, "Something went wrong: $e");      
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleResendCode() async {
    setState(() {
      _isResending = true;
    });

    try {
      // Get AuthRepository from service locator
      await sendOTP();

      if (mounted) {
        DisplayUtils.showToast(context, "Verification code has been resent to your email");        
      }
    } catch (e) {
      DisplayUtils.showToast(context, "Something went wrong: $e");
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    sendOTP();
    super.initState();
  }

  String generateRandomAlphabets(int length) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    Random random = Random();

    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
  }

  String? OTPSent;

  sendOTP() async {
    final StorageService storageService = sl<StorageService>();
    final emailCubit = context.read<EmailCubit>();
    final name = storageService.getString(StorageKeys.userName);
    final email = storageService.getString(StorageKeys.userEmail);
    // print('@@@@####$name');
    // print('@@@####@$email');
    final OTP = generateRandomAlphabets(4);
    OTPSent = OTP;
    // print(OTP);
    final htmlContent = await loadOTPTemplate(
      name: name,
      OTP: OTP,
    );
    final input = SendEmailInput(
      senderName: "Nubes",
      senderEmail: "support@nubessim.com",
      receiverName: name,
      receiverEmail: email,
      subject: "OTP Verification Code",
      htmlContent: htmlContent,
    );
    // debugger();
    await emailCubit.sendEmail(input);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                h2,
                // SvgPicture.asset(
                //   Assets.svgSignInLogo,
                //   height: 55.0,
                // ),
                Image.asset(
                  Assets.imagesLogo, // your Figma exported logo
                  height: 100,
                ),
                h3,

                const Text(
                  'Enter Verification Code',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    fontFamily: 'Inter',
                  ),
                ),
                h2,

                SvgPicture.asset('assets/svg/Phone.svg'),
                h2,

                // Instructional Text
                const Text(
                  'A 4-character verification code has been sent to\nyour email. Enter it below to proceed',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: AppColors.greyColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                h3,

                // Code Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4,
                    (index) => SizedBox(
                      width: 60.0,
                      height: 60.0,
                      child: TextFormField(
                        inputFormatters: [
                          UpperCaseTextFormatter()
                        ],
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        // inputFormatters: [
                        //   FilteringTextInputFormatter.digitsOnly,
                        // ],
                        onChanged: (value) => _onCodeChanged(value, index),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide:
                                const BorderSide(color: AppColors.lightGrey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide:
                                const BorderSide(color: AppColors.lightGrey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide:
                                const BorderSide(color: AppColors.primaryColor),
                          ),
                          filled: true,
                          fillColor: AppColors.lightGrey,
                        ),
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                h3,

                // Resend Code Button
                TextButton(
                  onPressed: _isResending ? null : _handleResendCode,
                  child: _isResending
                      ? const SizedBox(
                          height: 16.0,
                          width: 16.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: AppColors.primaryColor,
                          ),
                        )
                      : const Text(
                          'Resend Code',
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                ),
                h3,
                PrimaryButton(
                  onPressed: _isLoading ? () {} : _handleContinue,
                  backgroundColor: AppColors.primaryColor,
                  borderColor: AppColors.primaryColor,
                  hMargin: 0,
                  height: 48.0,
                  elevation: 6.0,
                  borderRadius: 12.0,
                  title: 'Continue',
                ),
                h3,
              ],
            ),
          );
        }),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}