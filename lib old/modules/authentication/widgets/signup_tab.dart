import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/config/routes/nav_router.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/modules/authentication/pages/email_verification_screen.dart';
import 'package:nubesim/modules/profile/pages/terms_and_conditions.dart';
import 'package:nubesim/ui/custom_check_box.dart';
import 'package:nubesim/ui/input_fields/input_field.dart';
import 'package:nubesim/ui/password_suffix_widget.dart';
import 'package:nubesim/ui/primary_button.dart';
import 'package:nubesim/utils/display/display_utils.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:nubesim/utils/heights_and_widths.dart';
import '../auth_navigation.dart';
import '../cubits/signup_cubit/signup_cubit.dart';

class SignupTab extends StatefulWidget {
  const SignupTab({super.key});

  @override
  State<SignupTab> createState() => _SignupTabState();
}

class _SignupTabState extends State<SignupTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController(),
      nameController = TextEditingController(),
      emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignupCubit, SignupState>(
      listener: (context, state) async {
        if (state.signupStatus == SignupStatus.success) {
          final user = await FirebaseFirestore.instance
              .collection('user_data')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();
          if (user.exists) {
            var data = user.data();
            // print(data);
            bool isDataNotNull = data != null;
            bool isEmailNotVerified = !data!.containsKey('isEmailVerified') ||
                data['isEmailVerified'] == false;
            bool isNotGoogleUser =
                !data.containsKey('isGoogle') || data['isGoogle'] == "false";

            // print("Data is not null: $isDataNotNull");
            // print(
            //     "Email is not verified (or key missing): $isEmailNotVerified");
            // print("User is not Google (or key missing): $isNotGoogleUser");
            // print(((data != null) &&
            //     (!data.containsKey('isEmailVerified') ||
            //         data['isEmailVerified'] == false) &&
            //     (!data.containsKey('isGoogle') ||
            //         data['isGoogle'] == "false")));
            if ((data != null) &&
                (!data.containsKey('isEmailVerified') ||
                    data['isEmailVerified'] == false) &&
                (!data.containsKey('isGoogle') ||
                    data['isGoogle'] == "false")) {
              NavRouter.navigationKey.currentState!.push(
                MaterialPageRoute(
                    builder: (_) => EmailVerificationScreen(
                          email: state.email,
                        )),
              );
              return;
            }

            AuthNavigation.completeAuthentication(context);
          }
        } else if (state.signupStatus == SignupStatus.error) {
          DisplayUtils.showToast(context, state.message);          
          context.read<SignupCubit>().clearStatus();
        }
      },
      builder: (context, state) {
        final cubit = context.read<SignupCubit>();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              children: [
                // Text(
                //   "New here?",
                //   style: context.textTheme.headlineMedium?.copyWith(
                //     color: AppColors.primaryColor,
                //     fontWeight: FontWeight.w500,
                //     fontSize: 19.0,
                //   ),
                // ),
                // h1,
                // Text(
                //   "Create New account",
                //   style: context.textTheme.headlineMedium?.copyWith(
                //     color: AppColors.black,
                //     fontWeight: FontWeight.w900,
                //     fontSize: 32.0,
                //   ),
                // ),

                Column(
                  spacing: 12.0,
                  children: [
                    InputField(
                      maxLines: 1,
                      label: "Name",
                      fillColor: Colors.grey.shade100,
                      borderRadius: 12.0,
                      controller: nameController,
                      labelColor: AppColors.black,
                      textColor: AppColors.black,
                      boxConstraints: 12,
                      borderColor: Colors.transparent,
                      focusBorderColor: Colors.transparent,
                      hintColor: AppColors.black,
                      onChange: cubit.onNameChanged,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Name is required'
                              : null,
                    ),
                    InputField(
                      maxLines: 1,
                      label: "Email",
                      fillColor: Colors.grey.shade100,
                      borderRadius: 12.0,
                      labelColor: AppColors.black,
                      controller: emailController,
                      textColor: AppColors.black,
                      boxConstraints: 12,
                      borderColor: Colors.transparent,
                      focusBorderColor: Colors.transparent,
                      hintColor: AppColors.black,
                      onChange: cubit.onEmailChanged,
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
                    InputField(
                      maxLines: 1,
                      boxConstraints: 12,
                      label: "Password",
                      controller: passwordController,
                      obscureText: state.hidePassword,
                      fillColor: Colors.grey.shade100,
                      borderRadius: 12.0,
                      labelColor: AppColors.black,
                      textColor: AppColors.black,
                      borderColor: Colors.transparent,
                      focusBorderColor: Colors.transparent,
                      hintColor: AppColors.black,
                      onChange: cubit.onPasswordChanged,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Password is required';
                        } else if (value.length < 6) {
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
                        spacing: 6.0,
                        children: [
                          CustomCheckBox(
                            onChange: (v) {
                              // handle if needed
                            },
                            size: 16.0,
                            value: true,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TermsAndConditions(),
                                ),
                              );
                            },
                            child: Text(
                              "Agree with " "Terms & Conditions",
                              style: context.textTheme.bodySmall?.copyWith(
                                  color: AppColors.black,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ],
                      ),
                    ),
                    h1,
                    PrimaryButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          cubit.signup();
                        }
                      },
                      backgroundColor: AppColors.buttonColor,
                      titleColor: AppColors.black,
                      updateColor: true,
                      hMargin: 0,
                      vMargin: 0,
                      height: 48.0,
                      elevation: 6.0,
                      borderRadius: 100.0,
                      title: state.signupStatus == SignupStatus.loading
                          ? "Signing Up..."
                          : "Sign Up",
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
                      "Or sign up with",
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
                        onTap: () => cubit.loginWithApple(),
                        child: Container(
                          width: 90,
                          height: 40,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: AppColors.buttonColor,
                              borderRadius: BorderRadius.circular(60),
                              border: Border.all(
                                  color: AppColors.greyColor.withOpacity(.5))),
                          child: Center(
                            child: Image.asset(
                              'assets/images/apple (1).png',
                              height: 60,
                            ),
                          ),
                        )),
                    w2,
                    InkWell(
                        onTap: () => cubit.signupWithGoogle(),
                        child: Container(
                          width: 90,
                          height: 40,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: AppColors.buttonColor,
                              borderRadius: BorderRadius.circular(60),
                              border: Border.all(
                                  color: AppColors.greyColor.withOpacity(.5))),
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
        );
      },
    );
  }
}
