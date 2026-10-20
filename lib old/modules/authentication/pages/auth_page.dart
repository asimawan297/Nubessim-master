import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/modules/authentication/widgets/login_tab.dart';
import 'package:nubesim/modules/authentication/widgets/signup_tab.dart';
import 'package:nubesim/modules/splash/widget/color_loader.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:nubesim/utils/heights_and_widths.dart';
import '../../../generated/assets.dart';

class AuthPage extends StatefulWidget {
  final String? message;

  const AuthPage({super.key, this.message});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final loginState = context.watch<LoginCubit>().state;
    // final signUpState = context.watch<SignupCubit>().state;

    // if ((loginState.loginStatus == LoginStatus.loading) ||
    //     (signUpState.signupStatus == SignupStatus.loading)) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     showLoading(context);
    //   });
    // }

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  Assets.imagesLogo,
                  height: 100
                ),
               
                h2,
                Container(
                  // width: 80.w,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xffF6F6F6),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: EdgeInsets.all(4.0),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerHeight: 0,
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xfaEF5576).withOpacity(0.7), // pink
                          Color(0xfaCA2045).withOpacity(1), // dark red
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Inter",
                      fontSize: 14.0,
                    ),
                    tabs: const [
                      Tab(text: 'Sign In'),
                      Tab(text: 'Sign Up'),
                    ],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    // your content height
                    child: TabBarView(
                      controller: _tabController,
                      children: [LoginTab(), SignupTab()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _tabController.index == 0
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _tabController.index == 0
                            ? "Don’t have an account?"
                            : "Already have an account?",
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontSize: 14.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          final newIndex = _tabController.index == 0 ? 1 : 0;
                          _tabController.animateTo(newIndex);
                        },
                        child: Text(
                          _tabController.index == 0
                              ? "Sign up here"
                              : "Login here",
                          style: context.textTheme.bodyMedium?.copyWith(
                              fontSize: 14.0,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  h2,
                ],
              )
            : SizedBox(),
      ),
    );
  }
}

void showLoading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // user must tap a button
    builder: (BuildContext context) {
      return AlertDialog(
          content: Container(
        height: 100,
        width: 150,
        color: AppColors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                Assets.imagesLogo,
                height: 80,
                // width: 199,
              ),
              SizedBox(
                height: 10,
              ),
              ColorLoader(),
            ],
          ),
        ),
      ));
    },
  );
}
