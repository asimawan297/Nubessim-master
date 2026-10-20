import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/core/di/service_locator.dart';
import 'package:nubesim/core/exceptions/api_error.dart';
import 'package:nubesim/modules/authentication/pages/password_reset_success_screen.dart';
import 'package:nubesim/modules/authentication/repository/auth_repository.dart';
import 'package:nubesim/ui/input_fields/input_field.dart';
import 'package:nubesim/ui/primary_button.dart';
import 'package:nubesim/utils/display/display_utils.dart';
import 'package:nubesim/utils/heights_and_widths.dart';
import '../../../generated/assets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleContinue() async {
    // debugger();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();

    try {
      // Use Firebase password reset instead of custom OTP
      final authRepository = sl<AuthRepository>();
      await authRepository.sendPasswordResetEmail(email);

      // Show success message and navigate to confirmation screen
      if (mounted) {
        DisplayUtils.showToast(context, "Password reset email sent to $email");

        // Navigate to "Check your email" screen
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const PasswordResetSuccessScreen())
        );
      }
    } on ApiError catch (e) {
      if (mounted) {
        DisplayUtils.showToast(
            context,
            e.message ??
                "Something went wrong, please try again after some time.");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
                          'Forgot Password',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                            fontFamily: 'Inter',
                          ),
                        ),
                        h2,

                        SvgPicture.asset('assets/svg/Password.svg'),
                        h2,

                        const Text(
                          "You can reset your password by entering your email down below. We'll then send you an email with a link to reset your password.",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: AppColors.greyColor,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        h3,

                        // Email Input Field
                        InputField(
                          maxLines: 1,
                          label: "Email",
                          fillColor: Colors.grey.shade100,
                          borderRadius: 12.0,
                          labelColor: AppColors.primaryFieldTextColor,
                          controller: _emailController,
                          textColor: AppColors.black,
                          boxConstraints: 12,
                          borderColor: Colors.transparent,
                          focusBorderColor: Colors.transparent,
                          hintColor: AppColors.primaryFieldTextColor,
                          keyboardType: TextInputType.emailAddress,
                          onChange: (p0) {
                            setState(() {});
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            } else if (!RegExp(
                              r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                            ).hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        h3,
                        PrimaryButton(
                          onPressed: _isLoading ? () {} : _handleContinue,
                          backgroundColor:
                              _formKey.currentState?.validate() == null ||
                                      _formKey.currentState!.validate() == false
                                  ? AppColors.buttonColor
                                  : AppColors.buttonSelectedColor,
                          titleColor:
                              _formKey.currentState?.validate() == null ||
                                      _formKey.currentState!.validate() == false
                                  ? AppColors.black
                                  : AppColors.white,
                          updateColor: true,
                          hMargin: 0,
                          height: 48.0,
                          elevation: 6.0,
                          borderRadius: 12.0,
                          title: _isLoading ? 'Sending...' : 'Send Reset Link',
                        ),
                        h3,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
