import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:nubesim/core/network/my_http_overrides.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/bloc/app_bloc_observer.dart';
import 'app/bloc/bloc_di.dart';
import 'app/my_app.dart';
import 'config/environment.dart';
import 'core/initializer/init_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Bloc.observer = AppBlocObserver();
  // TODO: Replace with your actual Stripe publishable key
  // Get this from your Stripe dashboard: https://dashboard.stripe.com/apikeys
  // Stripe.publishableKey = 'pk_test_YOUR_PUBLISHABLE_KEY_HERE';
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Status bar background
      statusBarIconBrightness: Brightness.dark, // For Android
      statusBarBrightness: Brightness.light, // For iOS
      systemNavigationBarColor: Colors.white, // Navigation bar background
      systemNavigationBarIconBrightness: Brightness.dark, // Icons in nav bar
    ),
  );

  // Stripe.publishableKey =
  //     'pk_test_51Rcw5qLDdMZwUDvCddUGd1sIXopJelqNTl3EcluqMDnlt36QYf2261BRGTGBKMgs5WMXOuBK9r1IBxML4cuJhttr00ldrWqQhq';
  Stripe.publishableKey =
      'pk_live_51Rcw5qLDdMZwUDvCW6uBpmcJWFwoom8cMTjEgD9BbT8S7lnM3hHnzEiPeON5edXajrGqdJ25UDOvhS2USLNubnJ600DpJXR8bx';
  Stripe.urlScheme = 'nubesim';
  await Stripe.instance.applySettings();

  await initApp(Environment.fromEnv(AppEnv.dev));
  runApp(const BlocDI(child: NubESim()));
}
