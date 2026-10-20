import 'package:get_it/get_it.dart';
import 'package:nubesim/common/email_repository/email_repository.dart';
import 'package:nubesim/core/auth_service/auth_service.dart';
import 'package:nubesim/core/network/dio_client.dart';
import 'package:nubesim/core/network/stripe_dio_client.dart';
import 'package:nubesim/modules/authentication/repository/auth_repository.dart';
import 'package:nubesim/modules/common/repo/session_repo.dart';
import 'package:nubesim/modules/my_esim/repo/my_esim_repo.dart';
import 'package:nubesim/modules/shop/cubits/currency_cubit/currency_cubit.dart';
import 'package:nubesim/modules/shop/currency/fx_quote_repository.dart';
import 'package:nubesim/modules/shop/repository/shop_repository.dart';
import 'package:nubesim/modules/shop/repository/stripe_payment_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/environment.dart';
import '../storage_service/storage_service.dart';

final sl = GetIt.instance;

void setupLocator(Environment environment) async {
  /// ==================== Environment =========================
  sl.registerLazySingleton<Environment>(() => environment);

  sl.registerLazySingleton<DioClient>(
      () => DioClient(environment: sl<Environment>()));
  sl.registerLazySingleton<StripeDioClient>(() => StripeDioClient());

  /// ==================== Shared Pref =========================
  sl.registerSingletonAsync<SharedPreferences>(
    () async => SharedPreferences.getInstance(),
  );

  /// ==================== DataBase ===========================
  sl.registerSingletonWithDependencies<StorageService>(
    () => StorageService(sharedPreferences: sl<SharedPreferences>()),
    dependsOn: [SharedPreferences],
  );

  // sl.registerLazySingleton<ShopRepository>(
  //     () => ShopRepository(
  //           dioClient: sl<DioClient>(),
  //         ));
  sl.registerLazySingleton<ShopRepository>(
    () => ShopRepository(dioClient: sl<DioClient>()),
  );

  sl.registerLazySingleton<MyEsimRepository>(
    () => MyEsimRepository(dioClient: sl<DioClient>()),
  );

  sl.registerLazySingleton<EmailRepository>(
    () => EmailRepository(dioClient: sl<DioClient>()),
  );

  /// ==================== Networking ===========================
  sl.registerLazySingleton<SessionRepository>(() => SessionRepository(
        storageService: sl<StorageService>(),
      ));

  /// ==================== Modules ===========================

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      authService: AuthService(),
      storageService: sl<StorageService>(),
      sessionRepository: sl<SessionRepository>(),
      dioClient: sl<DioClient>(),
    ),
  );

  sl.registerLazySingleton<FxQuoteRepository>(() => FxQuoteRepository());
  sl.registerLazySingleton<CurrencyCubit>(
    () => CurrencyCubit(sl(), sl()),
  );
  sl.registerLazySingleton<StripePaymentRepository>(
      () => StripePaymentRepository());
  sl.registerLazySingleton<PaymentWithCardRepository>(
    () => PaymentWithCardRepository(),
  );

  // sl.registerLazySingleton<PaymentWithCardCubit>(
  //   () => PaymentWithCardCubit(sl<PaymentWithCardRepository>()),
  // );
}
