import '../../config/environment.dart';
import '../di/service_locator.dart';
import '../network/api_key_service.dart';

Future<void> initApp(Environment env) async {
  // API key saved in the website admin (the built-in key is the fallback).
  await ApiKeyService.load();
  setupLocator(env);
  await sl.allReady();
}
