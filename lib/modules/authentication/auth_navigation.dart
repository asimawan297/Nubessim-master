import 'package:esim_compatibility/esim_compatibility.dart';
import 'package:flutter/material.dart';
import 'package:nubesim/config/routes/nav_router.dart';
import 'package:nubesim/modules/base_view/page/base_view.dart';
import 'package:nubesim/modules/shop/model/all_data_packages_model.dart';
import 'package:nubesim/modules/shop/pages/device_not_supported.dart';
import 'package:nubesim/modules/shop/pages/secure_checkout_screen.dart';

/// Checkout the user tried to open before logging in.
class PendingCheckout {
  const PendingCheckout({
    required this.name,
    required this.package,
    this.routeType,
    this.iccid,
  });

  final String name;
  final PackageList package;
  final String? routeType;
  final String? iccid;
}

/// When set, successful login/signup returns to the screen the user was on
/// (e.g. USA package list) instead of resetting to [BaseScreen].
/// If [PendingCheckout] is set, navigates to [SecureCheckoutScreen] for that package.
class AuthNavigation {
  AuthNavigation._();

  static bool _returnToPreviousScreen = false;
  static PendingCheckout? _pendingCheckout;
  static int? _pendingTabIndex;

  static void markReturnToPreviousScreen() {
    _returnToPreviousScreen = true;
    _pendingCheckout = null;
    _pendingTabIndex = null;
  }

  /// After login from a bottom-nav tab (My eSIM / Profile), switch to this tab.
  static void markReturnToTab(int tabIndex) {
    _returnToPreviousScreen = true;
    _pendingTabIndex = tabIndex;
    _pendingCheckout = null;
  }

  static int? takePendingTabIndex() {
    final tab = _pendingTabIndex;
    _pendingTabIndex = null;
    return tab;
  }

  static void markPendingCheckout({
    required String name,
    required PackageList package,
    String? routeType,
    String? iccid,
  }) {
    _returnToPreviousScreen = true;
    _pendingCheckout = PendingCheckout(
      name: name,
      package: package,
      routeType: routeType,
      iccid: iccid,
    );
  }

  static void clearReturnToPreviousScreen() {
    _returnToPreviousScreen = false;
    _pendingCheckout = null;
    _pendingTabIndex = null;
  }

  static void completeAuthentication(BuildContext context) {
    final pendingCheckout = _pendingCheckout;

    if (_returnToPreviousScreen) {
      _returnToPreviousScreen = false;
      _pendingCheckout = null;
      _dismissAuthOverlay(context);

      if (pendingCheckout != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _openPendingCheckout(pendingCheckout);
        });
      }
      return;
    }

    NavRouter.navigationKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const BaseScreen()),
      (route) => false,
    );
  }

  static Future<void> _openPendingCheckout(PendingCheckout pending) async {
    final rootContext = NavRouter.navigationKey.currentContext;
    if (rootContext == null) return;

    final isCompatible = await EsimCompatibility.isEsimCompatible();
    if (!isCompatible) {
      final result = await NavRouter.push(rootContext, DeviceNotSupported());
      if (result != true) return;
    }

    await NavRouter.pushFromRoot(
      rootContext,
      SecureCheckoutScreen(
        name: pending.name,
        package: pending.package,
        routeType: pending.routeType,
        iccid: pending.iccid,
      ),
    );
  }

  static void _dismissAuthOverlay(BuildContext context) {
    final rootNav = NavRouter.navigationKey.currentState;
    if (rootNav != null && rootNav.canPop()) {
      rootNav.pop();
      return;
    }

    final nav = Navigator.maybeOf(context);
    if (nav != null && nav.canPop()) {
      nav.pop();
    }
  }
}
