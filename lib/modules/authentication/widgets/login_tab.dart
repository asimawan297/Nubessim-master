import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/common/email_cubit/email_cubit.dart';
import 'package:nubesim/common/model/send_email_input.dart';
import 'package:nubesim/config/config.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/constants/keys.dart';
import 'package:nubesim/core/di/service_locator.dart';
import 'package:nubesim/core/storage_service/storage_service.dart';
import 'package:nubesim/modules/authentication/pages/email_verification_screen.dart';
import 'package:nubesim/modules/authentication/pages/forgot_password_screen.dart';
import 'package:nubesim/modules/authentication/auth_navigation.dart';
import 'package:nubesim/ui/input_fields/input_field.dart';
import 'package:nubesim/ui/password_suffix_widget.dart';
import 'package:nubesim/ui/primary_button.dart';
import 'package:nubesim/utils/display/display_utils.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:nubesim/utils/html_templates.dart';
import '../../../utils/heights_and_widths.dart';
import '../cubits/login_cubit/login_cubit.dart';

class LoginTab extends StatefulWidget {
  const LoginTab({super.key});

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String name = "";
  String email = "";
  final StorageService _storageService = sl<StorageService>();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(LoginCubit cubit) async {
    if (_formKey.currentState!.validate()) {
      try {
        FocusScope.of(context).unfocus();
        // Request location permission before login
        // await getLocation();
        cubit.login();
      } catch (e) {
        DisplayUtils.showToast(
            context, 'Location permission is required to sign in.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      // listener: (context, state) {
      //   if (state.loginStatus == LoginStatus.success) {
      //     _emailController.clear();
      //     _passwordController.clear();
      //
      //     NavRouter.pushAndRemoveUntil(context, BaseScreen());
      //   } else if (state.loginStatus == LoginStatus.error) {
      //     ScaffoldMessenger.of(
      //       context,
      //     ).showSnackBar(SnackBar(content: Text(state.message)));
      //   }
      // },

      listener: (context, state) async {
        if (state.loginStatus == LoginStatus.success &&
            state.message.contains('Password reset')) {
          DisplayUtils.showToast(context, state.message);
        } else if (state.loginStatus == LoginStatus.success) {
          final userDoc = await FirebaseFirestore.instance
              .collection('user_data')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();

          if (userDoc.exists) {
            var data = userDoc.data();
            // print(data);

            bool isDataNotNull = data != null;

            // Check for email verification
            bool isEmailNotVerified = !data!.containsKey('isEmailVerified') ||
                data['isEmailVerified'] == false;

            // Check for login providers
            bool isGoogleUser =
                data.containsKey('isGoogle') && data['isGoogle'] == true;
            bool isAppleUser =
                data.containsKey('isApple') && data['isApple'] == true;

            // print("Data is not null: $isDataNotNull");
            // print("Email not verified (or key missing): $isEmailNotVerified");
            // print("isGoogleUser: $isGoogleUser");
            // print("isAppleUser: $isAppleUser");

            // ✅ Proceed to email verification only if NOT Google/Apple user
            if (isEmailNotVerified && !isGoogleUser && !isAppleUser) {
              NavRouter.navigationKey.currentState!.push(
                MaterialPageRoute(
                  builder: (_) => EmailVerificationScreen(
                    email: state.email,
                  ),
                ),
              );
              return;
            }

            // ✅ Send login success email and continue
            final emailCubit = context.read<EmailCubit>();
            name = _storageService.getString(StorageKeys.userName);
            email = _storageService.getString(StorageKeys.userEmail);
            final location = _storageService.getString(StorageKeys.location);

            // print('@@@@####$name');
            // print('@@@####@$email');

            final htmlContent = await loadEmailTemplate(
              name: name,
              instructionsLink: "https://nubessim.com/help",
              locationDetails: location,
            );

            final input = SendEmailInput(
              senderName: "Nubes",
              senderEmail: "support@nubessim.com",
              receiverName: name,
              receiverEmail: email,
              subject: "Login Success",
              htmlContent: htmlContent,
            );

            await emailCubit.sendEmail(input);
            _emailController.clear();
            _passwordController.clear();

            AuthNavigation.completeAuthentication(context);
          }
        } else if (state.loginStatus == LoginStatus.error) {
          DisplayUtils.showToast(context, state.message);
          context.read<LoginCubit>().clearStatus();
        }
      },
      builder: (context, state) {
        final cubit = context.read<LoginCubit>();
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: ListView(
                  children: [
                    Column(
                      spacing: 12.0,
                      children: [
                        InputField(
                          controller: _emailController,
                          maxLines: 1,
                          label: "Email",
                          fillColor: Colors.grey.shade100,
                          borderRadius: 12.0,
                          labelColor: AppColors.black,
                          textColor: AppColors.black,
                          boxConstraints: 12,
                          borderColor: Colors.transparent,
                          focusBorderColor: Colors.transparent,
                          hintColor: AppColors.black,
                          onChange: cubit.onEmailChanged,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }

                            final emailRegex =
                                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Please enter a valid email address';
                            }

                            return null;
                          },
                        ),
                        InputField(
                          controller: _passwordController,
                          maxLines: 1,
                          boxConstraints: 12,
                          label: "Password",
                          obscureText: state.hidePassword,
                          fillColor: Colors.grey.shade100,
                          borderRadius: 12.0,
                          labelColor: AppColors.black,
                          textColor: AppColors.black,
                          borderColor: Colors.transparent,
                          focusBorderColor: Colors.transparent,
                          hintColor: AppColors.black,
                          // onChange: (p0) {
                          //   cubit.onPasswordChanged(p0);
                          //   setState(() {});
                          // },
                          onChange: cubit.onPasswordChanged,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }

                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }

                            return null;
                          },

                          suffixIcon: PasswordSuffixIcon(
                            isPasswordVisible: state.hidePassword,
                            onTap: cubit.onPasswordVisibilityChanged,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Forgot your password?",
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: AppColors.black,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                    // decoration: TextDecoration.underline,
                                    // decorationColor: AppColors
                                    //     .primaryColor, // custom underline color
                                    // decorationThickness:
                                    //     2, // thickness of the line
                                    // decorationStyle: TextDecorationStyle.solid,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        PrimaryButton(
                          onPressed: () => _submit(cubit),
                          backgroundColor: AppColors.buttonColor,
                          titleColor: AppColors.black,
                          updateColor: true,
                          hMargin: 0,
                          height: 48.0,
                          elevation: 6.0,
                          borderRadius: 100.0,
                          title: state.loginStatus == LoginStatus.loading
                              ? "Signing In..."
                              : "Sign In",
                        ),
                      ],
                    ),
                    h1,
                    Row(
                      spacing: 8.0,
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade200,
                            thickness: 1.5,
                          ),
                        ),
                        Text(
                          "Or sign in with",
                          style: context.textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade200,
                            thickness: 1.5,
                          ),
                        ),
                      ],
                    ),
                    h2,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              cubit.loginWithApple();
                            },
                            child: Container(
                              width: 90,
                              height: 40,
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: AppColors.buttonColor,
                                  borderRadius: BorderRadius.circular(60),
                                  border: Border.all(
                                      color:
                                          AppColors.greyColor.withOpacity(.5))),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/apple (1).png',
                                  height: 60,
                                ),
                              ),
                            )),
                        w2,
                        InkWell(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              cubit.loginWithGoogle();
                            },
                            child: Container(
                              width: 90,
                              height: 40,
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: AppColors.buttonColor,
                                  borderRadius: BorderRadius.circular(60),
                                  border: Border.all(
                                      color:
                                          AppColors.greyColor.withOpacity(.5))),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/google.png',
                                  height: 60,
                                ),
                              ),
                            )),
                      ],
                    ),
                    h2,
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
