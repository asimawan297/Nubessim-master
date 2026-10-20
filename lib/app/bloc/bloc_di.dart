import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/common/email_cubit/email_cubit.dart';
import 'package:nubesim/core/auth_service/auth_service.dart';
import 'package:nubesim/core/auth_service/firestore_service.dart';
import 'package:nubesim/modules/authentication/cubits/signup_cubit/signup_cubit.dart';
import 'package:nubesim/modules/my_esim/cubits/all_esims_cubit/all_esims_cubit.dart';
import 'package:nubesim/modules/my_esim/cubits/esim_details_cubit/esim_detail_cubit.dart';
import 'package:nubesim/modules/shop/cubits/account_balance_cubit/account_balance_cubit.dart';
import 'package:nubesim/modules/shop/cubits/currency_cubit/currency_cubit.dart';
import 'package:nubesim/modules/shop/cubits/data_package_cubit/data_package_cubit.dart';
import 'package:nubesim/modules/shop/cubits/order_esim_cubit/order_esim_cubit.dart';
import 'package:nubesim/modules/shop/cubits/payment_intent/payment_intent_cubit.dart';

import '../../core/di/service_locator.dart';
import '../../modules/authentication/cubits/login_cubit/login_cubit.dart';
import '../../modules/profile/cubits/delete_account/delete_account_cubit.dart';
import '../../modules/profile/pages/order_history_screen.dart';
import '../../modules/shop/cubits/countries_list_cubit/countries_list_cubit.dart';
import '../cubit/app_cubit.dart';

class BlocDI extends StatelessWidget {
  const BlocDI({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppCubit>(create: (context) => AppCubit(sl())..init()),
        BlocProvider<CurrencyCubit>.value(
          value: sl<CurrencyCubit>(),
        ),
        BlocProvider<LoginCubit>(
          create: (context) => LoginCubit(authRepository: sl()),
        ),
        BlocProvider<CountriesCubit>(
          create: (context) =>
              CountriesCubit(
                shopRepository:  sl(),
                fireStoreService: FireStoreService())
                ..fetchCountries(),
        ),
        BlocProvider<SignupCubit>(
          create: (context) => SignupCubit(authRepository: sl()),
        ),
        BlocProvider<OrderEsimCubit>(
          create: (context) => OrderEsimCubit(shopRepository: sl()),
        ),
        BlocProvider<AccountBalanceCubit>(
          create: (context) => AccountBalanceCubit(shopRepository: sl()),
        ),
        BlocProvider<DataPackageCubit>(
          create: (context) => DataPackageCubit(shopRepository: sl()),
        ),
        BlocProvider<DeleteAccountCubit>(
          create: (context) => DeleteAccountCubit(authService: AuthService()),
        ),
        BlocProvider(
          create: (context) => PaymentIntentCubit(sl()),
        ),
        BlocProvider(
          create: (context) => EmailCubit(emailRepository: sl()),
        ),
        BlocProvider(
          create: (context) => EsimDetailCubit(myEsimRepository: sl()),
        ),
        // BlocProvider<PaymentWithCardCubit>(
        //   create: (context) =>
        //       PaymentWithCardCubit(sl<PaymentWithCardRepository>()),
        // ),
        BlocProvider(
          create: (_) =>
              EsimCubit(myEsimRepository: sl()),
          child: const OrderHistoryScreen(),
        )
      ],
      child: child,
    );
  }
}
