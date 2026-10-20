import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/modules/authentication/pages/password_reset_success_screen.dart';
import 'package:nubesim/ui/input_fields/input_field.dart';
import 'package:nubesim/ui/primary_button.dart';
import 'package:nubesim/utils/heights_and_widths.dart';
import 'package:nubesim/utils/validators/validators.dart';

import '../../../generated/assets.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String verificationCode;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.verificationCode,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // TODO: Implement reset password API call
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    setState(() {
      _isLoading = false;
    });

    // Navigate to success screen
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const PasswordResetSuccessScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  h2,
                  // SvgPicture.asset(
                  //   Assets.svgSignInLogo,
                  //   height: 55.0,
                  //   fit: BoxFit.contain,
                  // ),
                  Image.asset(
                    Assets.imagesLogo, // your Figma exported logo
                    height: 100,
                  ),
                  h3,

                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      fontFamily: 'Inter',
                    ),
                  ),
                  h2,

                  SvgPicture.asset('assets/svg/Password1.svg'),
                  h2,

                  // Instructional Text
                  const Text(
                    'Enter your new password below, then retype it to confirm and reset your current password',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: AppColors.greyColor,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  h3,

                  // New Password Field
                  InputField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    boxConstraints: 12,
                    obscureText: !_showNewPassword,
                    validator: Validators.password,
                    fillColor: Colors.grey.shade100,
                    borderRadius: 12.0,
                    labelColor: AppColors.black,
                    textColor: AppColors.black,
                    borderColor: Colors.transparent,
                    focusBorderColor: Colors.transparent,
                    hintColor: AppColors.black,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showNewPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.greyColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _showNewPassword = !_showNewPassword;
                        });
                      },
                    ),
                  ),
                  h2,

                  // Confirm Password Field
                  InputField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    boxConstraints: 12,
                    fillColor: Colors.grey.shade100,
                    borderRadius: 12.0,
                    labelColor: AppColors.primaryColor,
                    textColor: AppColors.primaryColor,
                    borderColor: Colors.transparent,
                    focusBorderColor: Colors.transparent,
                    hintColor: AppColors.primaryColor,
                    obscureText: !_showConfirmPassword,
                    validator: _validateConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.greyColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _showConfirmPassword = !_showConfirmPassword;
                        });
                      },
                    ),
                  ),
                  h4,
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
            ),
          );
        }),
      ),
    );
  }
}
