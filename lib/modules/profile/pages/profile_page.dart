import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nubesim/config/config.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/core/storage_service/storage_service.dart';
import 'package:nubesim/generated/assets.dart';
import 'package:nubesim/modules/authentication/cubits/login_cubit/login_cubit.dart';
import 'package:nubesim/modules/authentication/cubits/signup_cubit/signup_cubit.dart';
import 'package:nubesim/modules/base_view/page/base_view.dart';
import 'package:nubesim/modules/profile/pages/account_information_page.dart';
import 'package:nubesim/modules/profile/pages/contact_us_page.dart';
import 'package:nubesim/modules/profile/pages/more_info_page.dart';
import 'package:nubesim/modules/profile/pages/order_history_screen.dart';
import 'package:nubesim/modules/profile/widgets/profile_tile.dart';
import 'package:nubesim/ui/primary_button.dart';
import 'package:nubesim/utils/display/display_utils.dart';
import 'package:nubesim/utils/heights_and_widths.dart';
import 'package:nubesim/utils/urls_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/keys.dart';
import '../../../core/di/service_locator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.refreshToken = 0});

  /// Incremented by [BaseScreen] after login / tab switch to reload profile.
  final int refreshToken;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storageService =
      sl<StorageService>(); // Injected storage service
  String number = "";
  String name = "Hi Traveler";
  String? image;
  String email = "";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshToken != oldWidget.refreshToken) {
      loadUserProfile();
    }
  }

  Future<void> loadUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      if (mounted) {
        setState(() {
          _applyStoredProfileFallback();
          isLoading = false;
        });
      }
      return;
    }

    // Cached data is written during login before navigation — show it immediately.
    if (mounted) {
      setState(() {
        _applyStoredProfileFallback();
        isLoading =
            _storageService.getString(StorageKeys.userName).isEmpty &&
                _storageService.getString(StorageKeys.userEmail).isEmpty;
      });
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_data')
          .doc(uid)
          .get();

      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          name = data['name'] ?? _storageService.getString(StorageKeys.userName);
          email =
              data['email'] ?? _storageService.getString(StorageKeys.userEmail);
          number = data['phoneNumber'] ?? data['number'] ?? '';
          image = data['image'] ?? data['profileImage'];
          isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _applyStoredProfileFallback();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        DisplayUtils.showToast(context, e.toString());
      }
    }
  }

  void _applyStoredProfileFallback() {
    final storedName = _storageService.getString(StorageKeys.userName);
    name = storedName.isNotEmpty ? storedName : 'Hi Traveler';
    email = _storageService.getString(StorageKeys.userEmail);
    number = _storageService.getString(StorageKeys.userPhone);
    image = _storageService.getString(StorageKeys.userProfileImage);
    if (image != null && image!.isEmpty) image = null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LoginCubit, LoginState>(
          listenWhen: (previous, current) =>
              current.loginStatus == LoginStatus.success &&
              !current.message.contains('Password reset'),
          listener: (_, __) => loadUserProfile(),
        ),
        BlocListener<SignupCubit, SignupState>(
          listenWhen: (_, current) =>
              current.signupStatus == SignupStatus.success,
          listener: (_, __) => loadUserProfile(),
        ),
      ],
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
              color: AppColors.textColor),
        ),
        centerTitle: true,
        actions: [
          PrimaryButton(
            onPressed: () {
              showLogoutDialog(context, () {
                context.read<LoginCubit>().logout();
                StorageService(sharedPreferences: sl<SharedPreferences>())
                    .clear();
                NavRouter.navigationKey.currentState!.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => BaseScreen()),
                  (Route<dynamic> route) => false,
                );
              });
            },
            title: 'LOGOUT',
            backgroundColor: AppColors.purpleColor,
            titleColor: AppColors.white,
            width: 95,
            fontSize: 11,
            shadowColor: AppColors.transparent,
            borderRadius: 90,
            vMargin: 0,
            hMargin: 22,
            height: 30,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(
                        0.2,
                      ), // Yahan opacity ko kam karein
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: Offset(2, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith(
                                    color: AppColors.greyColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 21.0,
                                  ),
                            ),
                            h0P5,
                            if (email.isNotEmpty) ...[
                              Text(
                                email,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium?.copyWith(
                                      color: AppColors.greyColor,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14.0,
                                    ),
                              ),
                              // // SizedBox(height: 4),
                              // Text(
                              //   'Logged in via Email',
                              //   style: Theme.of(
                              //     context,
                              //   ).textTheme.headlineMedium?.copyWith(
                              //         color: AppColors.questionColorColor,
                              //         fontWeight: FontWeight.w400,
                              //         fontSize: 12.0,
                              //       ),
                              // ),
                            ],
                          ]),
                    ),
                    if (image != null) ...[
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(image!),
                        backgroundColor: Colors.transparent,
                      ),
                    ] else ...[
                      SvgPicture.asset(Assets.svgVector, height: 40),
                    ]
                  ],
                ),
              ),
              h3,
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                // decoration: BoxDecoration(
                //   color:AppColors.expansionTileBgColor,
                //   borderRadius: BorderRadius.circular(12),
                // ),
                child: Column(
                  children: [
                    ProfileTile(
                      title: 'Order History',
                      onTap: () {
                        NavRouter.push(context, OrderHistoryScreen());
                      },
                    ),
                    ProfileTile(
                      title: 'Contact Us',
                      onTap: () {
                        NavRouter.push(context, ContactUsPage());
                      },
                    ),
                    ProfileTile(
                      title: 'More Info',
                      onTap: () {
                        NavRouter.push(context, MoreInfoPage());
                      },
                    ),
                    ProfileTile(
                      title: 'Account Information',
                      onTap: () {
                        NavRouter.pushFromRoot(
                          context,
                          AccountInformationScreen(),
                        ).then((v) {
                          name =
                              _storageService.getString(StorageKeys.userName);
                          // email = _storageService.getString(StorageKeys.userEmail);
                          number =
                              _storageService.getString(StorageKeys.userPhone);
                        });
                      },
                    ),
                  ],
                ),
              ),
              h6,
              GestureDetector(
                onTap: () {
                  openStore();
                },
                child: Container(
                  color: Colors.transparent,
                  child: Column(children: [
                    Text('Rate App',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.purpleColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 13.0)),
                    h1,
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            5,
                            (index) => const Icon(
                                  Icons.star,
                                  color: AppColors.purpleColor,
                                  size: 22,
                                ))),
                  ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showLogoutDialog(
    BuildContext context, VoidCallback onConfirm) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure you want to logout?"),
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
              Navigator.pop(context); // close dialog
              onConfirm(); // call logout function
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      );
    },
  );
}
