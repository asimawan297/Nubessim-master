import '../../config/environment.dart';
import '../di/service_locator.dart';

Future<void> initApp(Environment env) async {
  setupLocator(env);
  await sl.allReady();
}
