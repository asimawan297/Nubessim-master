import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nubesim/config/routes/nav_router.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/core/di/service_locator.dart';
import 'package:nubesim/core/storage_service/storage_service.dart';
import 'package:nubesim/generated/assets.dart';
import 'package:nubesim/modules/authentication/cubits/login_cubit/login_cubit.dart';
import 'package:nubesim/modules/authentication/widgets/auth_required_wrapper.dart';
import 'package:nubesim/modules/help/page/help_page.dart';
import 'package:nubesim/modules/my_esim/cubits/all_esims_cubit/all_esims_cubit.dart';
import 'package:nubesim/modules/my_esim/cubits/all_esims_cubit/all_esims_state.dart';
import 'package:nubesim/modules/my_esim/models/all_allocated_esim_input.dart';
import 'package:nubesim/modules/profile/pages/contact_us_page.dart';
import 'package:nubesim/modules/profile/pages/profile_page.dart';
import 'package:nubesim/ui/widgets/persistent_navroutor.dart';
import 'package:nubesim/utils/display/display_utils.dart';
import 'package:nubesim/utils/html_templates.dart';
import 'package:nubesim/utils/speed_dail/src/speed_dial.dart';
import 'package:nubesim/utils/speed_dail/src/speed_dial_child.dart';
import 'package:nubesim/utils/urls_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../my_esim/pages/my_esim_screen.dart';
import '../../shop/pages/shop_screen.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _currentIndex = 0;
  int _profileRefreshToken = 0;
  bool isOpened = false;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  List<Widget> get _screens => [
        const ShopScreen(),
        const MyESimScreen(),
        const HelpPage(),
        ProfileScreen(refreshToken: _profileRefreshToken),
      ];

  void _onTabTapped(int index) {
    // Check authentication for protected tabs
    if (index == 1 || index == 3) {
      final auth = AuthRequiredWrapper.isUserLoggedIn();
      if (!auth) {
        final message = index == 1
            ? "Please login to view your eSIM data"
            : "Please login to access your profile";
        AuthRequiredWrapper.showLoginDialog(
          context,
          message: message,
          pendingTabIndex: index,
          onAuthSuccess: () => _switchToTab(
            index,
            refreshEsims: index == 1,
            refreshProfile: index == 3,
          ),
        );
        return;
      }
    }

    _switchToTab(
      index,
      refreshEsims: index == 1,
      refreshProfile: index == 3,
    );
  }

  void _switchToTab(
    int index, {
    bool refreshEsims = false,
    bool refreshProfile = false,
  }) {
    setState(() {
      _currentIndex = index;
      if (refreshProfile) {
        _profileRefreshToken++;
      }
    });
    if (refreshEsims && AuthRequiredWrapper.isUserLoggedIn()) {
      context
          .read<EsimCubit>()
          .fetchEsims(input: AllAllocatedEsimInput.initial());
    }
  }

  @override
  void initState() {
    super.initState();
    if (AuthRequiredWrapper.isUserLoggedIn()) {
      context
          .read<EsimCubit>()
          .fetchEsims(input: AllAllocatedEsimInput.initial());
    }
    getLocation();
    _currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_currentIndex].currentState!.maybePop();
        if (isFirstRouteInCurrentTab && _currentIndex != 0) {
          _onTabTapped(0);
          return false;
        }
        return isFirstRouteInCurrentTab;
      },
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              _buildOffstageNavigator(0),
              _buildOffstageNavigator(1),
              _buildOffstageNavigator(2),
              _buildOffstageNavigator(3),
            ],
          ),
          bottomNavigationBar:
              BlocBuilder<EsimCubit, EsimState>(builder: (context, state) {
            return Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: state.isVoice
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTabItemFreeze(
                          selectedIcon: Assets.svgShoppingBagSelected,
                          unselectedIcon: Assets.shoppingBagOutline,
                          label: 'Packs',
                          index: 9,
                        ),
                        _buildTabItemFreeze(
                          selectedIcon: Assets.svgKeypad,
                          unselectedIcon: Assets.svgKeypad,
                          label: 'Keypad',
                          index: 8,
                        ),
                        _buildTabItemFreeze(
                          selectedIcon: Assets.svgFrame,
                          unselectedIcon: Assets.svgProfile,
                          label: 'Contacts',
                          index: 7,
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTabItem(
                          selectedIcon: Assets.svgShoppingBagSelected,
                          unselectedIcon: Assets.svgShoppingBag,
                          label: 'Shop',
                          index: 0,
                        ),
                        _buildTabItem(
                          selectedIcon: Assets.svgSimcardSelected,
                          unselectedIcon: Assets.svgSimcard,
                          label: 'My eSIM',
                          index: 1,
                        ),
                        _buildCenterIcon(),
                        _buildTabItem(
                          selectedIcon: Assets.svgMessageQuestionSelected,
                          unselectedIcon: Assets.svgMessageQuestion,
                          label: 'Help',
                          index: 2,
                        ),
                        _buildTabItem(
                          selectedIcon: Assets.svgFrame,
                          unselectedIcon: Assets.svgProfile,
                          label: 'Profile',
                          index: 3,
                        ),
                      ],
                    ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabItemFreeze({
    required String selectedIcon,
    required String unselectedIcon,
    required String label,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        DisplayUtils.showToast(
            context, 'Stay Tuned — Voice Service Launching Soon!');
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            unselectedIcon,
            height: 20,
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String selectedIcon,
    required String unselectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? Colors.purple : Colors.grey;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            isSelected ? selectedIcon : unselectedIcon,
            height: 20,
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCenterIcon() {
    return SpeedDial(
      onOpen: () {
        setState(() {
          isOpened = true;
        });
      },
      onClose: () {
        setState(() {
          isOpened = false;
        });
      },
      overlayOpacity: 0.7,
      activeBackgroundColor: Colors.transparent,
      overlayColor: Colors.black12,
      foregroundColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      children: [
        SpeedDialChild(
          child: Text("Logout"),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          onTap: () {
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
        ),
        SpeedDialChild(
          child: Text("Rate App"),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          onTap: () {
            openStore();
          },
        ),
        SpeedDialChild(
          child: Text("Contact Email"),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          onTap: () {
            openEmail("support@nubessim.com");
          },
          onLongPress: () => debugPrint('FIRST CHILD LONG PRESS'),
        ),
        SpeedDialChild(
          child: Text("Contact Whatsapp"),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          onTap: () {
            openWhatsApp(phone: "17058812941", message: "Hello!");
          },
        ),
      ],
      child: Transform.rotate(
        angle: 0.785398, // 45 degrees
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(isOpened ? 100 : 15),
          ),
          child: Transform.rotate(
            angle: -0.785398, // rotate back inner icon
            child: Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _currentIndex != index,
      child: PersistentNavigator(
        key: index == 3
            ? ValueKey('profile_nav_$_profileRefreshToken')
            : ValueKey('nav_tab_$index'),
        navigatorKey: _navigatorKeys[index],
        initialRoute: _screens[index],
      ),
    );
  }
}
