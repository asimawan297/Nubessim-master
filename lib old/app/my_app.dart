import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/dev/stripe_test_payment_screen.dart';
import 'package:nubesim/modules/splash/pages/splash_screen.dart';
import 'package:sizer/sizer.dart';
import '../config/routes/nav_router.dart';
import '../config/themes/light_theme.dart';
import 'bloc/bloc_di.dart';
import 'cubit/app_cubit.dart';

class NubESim extends StatelessWidget {
  const NubESim({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocDI(
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          return Sizer(
            builder: (context, orientation, deviceType) {
              return MaterialApp(
                navigatorKey: NavRouter.navigationKey,
                title: 'Nubes',
                debugShowCheckedModeBanner: false,
                theme: lightTheme,
                
                themeMode: ThemeMode.light,
                // builder: (BuildContext context, Widget? child) {
                //   child = BotToastInit()(context, child);
                //   return child;
                // },
                builder: (context, child) {
                  child = BotToastInit()(context, child);
                  return Container(
                    color: Colors.white, // Safe area color
                    child: SafeArea(
                      top: true,
                      bottom: true,
                      child: child,
                    ),
                  );
                },
                navigatorObservers: [BotToastNavigatorObserver()],
                routes: {
                  '/stripe-test-payment': (_) =>
                      const StripeTestPaymentScreen(),
                },
                home:  SplashScreen()
                // home: EmailVerificationScreen(email: 'ubaidasim',),
              );
            },
          );
        },
      ),
    );
  }
}
