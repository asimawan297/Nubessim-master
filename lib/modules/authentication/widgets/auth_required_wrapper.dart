import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/core/di/service_locator.dart';
import 'package:nubesim/modules/authentication/auth_navigation.dart';
import 'package:nubesim/modules/authentication/pages/auth_page.dart';
import 'package:nubesim/modules/common/repo/session_repo.dart';
import 'package:nubesim/modules/shop/model/all_data_packages_model.dart';

class AuthRequiredWrapper extends StatelessWidget {
  final Widget child;
  final String? redirectMessage;

  const AuthRequiredWrapper({
    super.key,
    required this.child,
    this.redirectMessage,
  });

  @override
  Widget build(BuildContext context) {
    final sessionRepo = sl<SessionRepository>();
    final isUserLoggedIn = sessionRepo.isLoggedIn();

    if (isUserLoggedIn) {
      return child;
    } else {
      // Show popup dialog first
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AuthNavigation.markReturnToPreviousScreen();
        _showLoginDialog(context);
      });

      // Return a placeholder while showing dialog
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: Colors.orange,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Login Required',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                redirectMessage ?? "Please login to continue",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Would you like to login or create an account?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                AuthNavigation.markReturnToPreviousScreen();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuthPage(
                      message: redirectMessage ?? "Please login to continue",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Login / Sign Up'),
            ),
          ],
        );
      },
    );
  }

  // Static method to show login dialog from anywhere
  // static void showLoginDialog(BuildContext context, {String? message}) {
  //   final sessionRepo = sl<SessionRepository>();
  //   final isUserLoggedIn = sessionRepo.isLoggedIn();

  //   if (isUserLoggedIn) {
  //     return; // User is already logged in
  //   }

  //   showDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16.0),
  //         ),
  //         title: Row(
  //           children: [
  //             Icon(
  //               Icons.lock_outline,
  //               color: Colors.orange,
  //               size: 24,
  //             ),
  //             SizedBox(width: 8),
  //             Text(
  //               'Login Required',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ],
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               message ?? "Please login to continue",
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 color: Colors.grey[600],
  //               ),
  //             ),
  //             SizedBox(height: 16),
  //             Text(
  //               'Would you like to login or create an account?',
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close dialog
  //             },
  //             child: Text(
  //               'Cancel',
  //               style: TextStyle(
  //                 color: Colors.grey[600],
  //               ),
  //             ),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close dialog
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => AuthPage(
  //                     message: message ?? "Please login to continue",
  //                   ),
  //                 ),
  //               );
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.orange,
  //               foregroundColor: Colors.white,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //             ),
  //             child: Text('Login / Sign Up'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  static void showLoginDialog(
    BuildContext context, {
    String? message,
    bool isBottomBar = false,
    String? checkoutName,
    PackageList? checkoutPackage,
    String? checkoutRouteType,
    String? checkoutIccid,
    int? pendingTabIndex,
    VoidCallback? onAuthSuccess,
  }) {
    final sessionRepo = sl<SessionRepository>();
    final alreadyLoggedIn = sessionRepo.isLoggedIn();

    if (alreadyLoggedIn) {
      onAuthSuccess?.call();
      return;
    }

    if (checkoutPackage != null) {
      AuthNavigation.markPendingCheckout(
        name: checkoutName ?? checkoutPackage.name,
        package: checkoutPackage,
        routeType: checkoutRouteType,
        iccid: checkoutIccid,
      );
    } else if (pendingTabIndex != null) {
      AuthNavigation.markReturnToTab(pendingTabIndex);
    } else {
      AuthNavigation.markReturnToPreviousScreen();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        final height = MediaQuery.of(context).size.height * (isBottomBar ? 0.75 : 0.85); // 80% height

        return SizedBox(
          height: height,
          child: Column(
            children: [
              // Header with close button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                  
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.primaryColor, size: 30),
                      onPressed: () {
                        AuthNavigation.clearReturnToPreviousScreen();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              // Expanded AuthPage
              Expanded(
                child: AuthPage(
                  message: message ?? "Please login to continue",
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      if (AuthRequiredWrapper.isUserLoggedIn()) {
        onAuthSuccess?.call();
      }
      AuthNavigation.clearReturnToPreviousScreen();
    });
  }

  // Static method to check if user is logged in
  static bool isUserLoggedIn() {
    final sessionRepo = sl<SessionRepository>();
    return sessionRepo.isLoggedIn();
  }
}
