import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/modules/profile/cubits/delete_account/delete_account_cubit.dart';
import 'package:nubesim/ui/custom_appbar.dart';
import 'package:nubesim/ui/input_fields/input_field.dart';
import 'package:nubesim/ui/primary_button.dart';
import 'package:nubesim/utils/display/display_utils.dart';
import 'package:nubesim/utils/heights_and_widths.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/routes/nav_router.dart';
import '../../../constants/keys.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/storage_service/storage_service.dart';
import '../../authentication/cubits/login_cubit/login_cubit.dart';
import '../../authentication/pages/auth_page.dart';
import '../../authentication/repository/auth_repository.dart';
import '../cubits/delete_account/delete_account_state.dart';
import '../cubits/update_account/profile_cubit.dart';

class AccountInformationScreen extends StatelessWidget {
  const AccountInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return // Example of wrapping the widget
        BlocProvider(
      create: (context) => ProfileCubit(authRepository: sl<AuthRepository>()),
      // Call this to pre-populate the fields
      child: AccountInformationScreenView(),
    );
  }
}

class AccountInformationScreenView extends StatefulWidget {
  const AccountInformationScreenView({super.key});

  @override
  _AccountInformationScreenViewState createState() =>
      _AccountInformationScreenViewState();
}

class _AccountInformationScreenViewState
    extends State<AccountInformationScreenView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool readOnly = true;
  bool receivePromotions = true;
  bool emailEditable = false;
  final StorageService _storageService =
      sl<StorageService>(); // Injected storage service
  String number = "";
  String name = "";
  String email = "";

  @override
  void initState() {
    name = _storageService.getString(StorageKeys.userName);
    email = _storageService.getString(StorageKeys.userEmail);
    number = _storageService.getString(StorageKeys.userPhone);
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Account information',
        titleColor: AppColors.textColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                return ReadOnlyTextField(
                  labelText: name,
                  label: 'Name',
                  controller: readOnly
                      ? TextEditingController(text: name)
                      : nameController,
                  readOnly: readOnly,
                  onChange: (value) =>
                      context.read<ProfileCubit>().onNameChanged(value),

                  // suffixIcon: Icon(Icons.lock_outline, size: 20),
                );
              },
            ),
            // h1,
            // BlocBuilder<ProfileCubit, ProfileState>(
            //   builder: (context, state) {
            //     return ReadOnlyTextField(
            //       labelText: number,
            //       readOnly: readOnly,
            //       label: 'Phone number',
            //       keyboardType: TextInputType.numberWithOptions(),
            //       onChange: (value) =>
            //           context.read<ProfileCubit>().onPhoneNumberChanged(value),

            //       controller: readOnly
            //           ? TextEditingController(text: number)
            //           : phoneController,
            //       // suffixIcon: Icon(Icons.lock_outline, size: 20),
            //     );
            //   },
            // ),
            h1,
            ReadOnlyTextField(
              labelText: email,
              label: 'Email',
              controller: TextEditingController(text: email),
              suffixIcon: Icon(Icons.lock_outline, size: 20),
            ),
            // h1,
            Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        readOnly = !readOnly;
                        phoneController.clear();
                        nameController.clear();
                      });
                    },
                    child: Text(
                      readOnly ? 'Edit' : "Cancel",
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.purpleColor,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.purpleColor,
                                fontSize: 14.0,
                              ),
                    ))),
            // h2,
            // Row(
            //   children: [
            //     Switch(
            //       value: receivePromotions,
            //       onChanged: (value) {
            //         setState(() {
            //           receivePromotions = value;
            //         });
            //       },
            //       activeColor: AppColors.purpleColor,
            //     ),
            //     Text(
            //       "I'd like to receive promotional emails.",
            //       style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            //             color: AppColors.questionColorColor,
            //             fontWeight: FontWeight.w400,
            //             fontSize: 14.0,
            //           ),
            //     ),
            //   ],
            // ),
            // h3,
            Text(
              "Delete Account",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.0,
                  ),
            ),
            h1,
            Text(
              "You can choose to permanently delete your account. Please",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.greyColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.0,
                  ),
            ),
            h2,
            BlocListener<DeleteAccountCubit, DeleteAccountState>(
              listener: (context, state) {
                if (state.status == DeleteAccountStatus.loading) {
                  DisplayUtils.showLoader();
                } else if (state.status == DeleteAccountStatus.success) {
                  DisplayUtils.showToast(
                      context, "Account Deleted Successfully");
                  DisplayUtils.removeLoader();
                  context.read<LoginCubit>().logout();
                  StorageService(sharedPreferences: sl<SharedPreferences>())
                      .clear();

                  NavRouter.pushAndRemoveUntil(context, AuthPage());
                } else if (state.status == DeleteAccountStatus.error) {
                  DisplayUtils.removeLoader();
                } else {
                  DisplayUtils.removeLoader();
                }
              },
              child: GradientButton(
                fontSize: 12,
                width: 150,
                text: "Delete Account",
                gradientColors: [Color(0xffef5576), Color(0xffca2045)],
                onTap: () {
                  showDeleteAlert(context, () {
                    // Confirm deletion
                    context
                        .read<DeleteAccountCubit>()
                        .deleteUserAccount();
                  });
                },
              ),
            ),
            h2,
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.all(Radius.circular(11))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Important Note",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 16.0,
                        ),
                  ),
                  h1,
                  Text(
                    "This action may take some time and cannot be reversed once completed.",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 14.0,
                        ),
                  ),
                ],
              ),
            ),
            h2,
            BlocListener<ProfileCubit, ProfileState>(
              listener: (context, state) {
                if (state.updateStatus == UpdateStatus.loading) {
                  DisplayUtils.showLoader();
                } else {
                  DisplayUtils.removeLoader();
                }
              },
              child: GradientButton(
                text: !readOnly ? "Save Changes" : "Cancel Changes",
                gradientColors: [Color(0xffCD57B2), Color(0xff911b76)],
                onTap: !readOnly
                    ? () {
                        context
                            .read<ProfileCubit>()
                            .updateProfile()
                            .then((v) async {
                          await _storageService.setString(
                              StorageKeys.userName, nameController.text);

                          await _storageService.setString(
                              StorageKeys.userPhone, phoneController.text);
                          setState(() {});
                        });
                      }
                    : () {
                        NavRouter.pop(context);
                      },
              ),
            )
          ],
        ),
      ),
    );
  }
}


void showDeleteAlert(BuildContext context, VoidCallback onConfirm) {
  showDialog(
    context: context,
    barrierDismissible: false, // user must tap a button
    builder: (context) {
      return AlertDialog(
        title: const Text("Delete"),
        content: const Text("Are you sure you want to delete this account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // close dialog
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red, // red delete button
            ),
            onPressed: () {
              Navigator.pop(context); // close dialog first
              onConfirm(); // perform delete action
            },
            child: const Text("Delete", style: TextStyle(color: AppColors.white)),
          ),
        ],
      );
    },
  );
}
