enum AppEnv { dev, prod, local }

abstract class Environment {
  String name;
  String baseUrl;
  String resourceUrl;
  String stripeBaseUrl;

  Environment(
      {required this.baseUrl,
      required this.resourceUrl,
      required this.name,
      required this.stripeBaseUrl});

  factory Environment.fromEnv(AppEnv appEnv) {
    if (appEnv == AppEnv.local) {
      return LocalEnvironment();
    } else if (appEnv == AppEnv.dev) {
      return DevEnvironment();
    } else {
      return ProdEnvironment();
    }
  }

  Future<void> map({
    required Future<void> Function() prod,
    required Future<void> Function() dev,
  }) async {
    if (this is ProdEnvironment) {
      await prod();
    } else if (this is DevEnvironment) {
      await dev();
    }
  }
}

/// ================= Local =======================

class LocalEnvironment extends Environment {
  LocalEnvironment()
      : super(
          name: 'Local',
          baseUrl: 'https://api.esimaccess.com',
          resourceUrl: 'https://api.esimaccess.com',
          // Android emulator uses 10.0.2.2 to reach host machine localhost
          stripeBaseUrl: 'http://10.0.2.2:3000',
        );
}

/// ================= Development =======================

class DevEnvironment extends Environment {
  DevEnvironment()
      : super(
          name: 'Dev',
          baseUrl: 'https://api.esimaccess.com',
          resourceUrl: 'https://api.esimaccess.com',
          stripeBaseUrl: 'http://10.0.2.2:3000',
        );
}

/// ================= Production =======================

class ProdEnvironment extends Environment {
  ProdEnvironment()
      : super(
          name: 'Prod',
          baseUrl: 'https://api.esimaccess.com',
          resourceUrl: 'https://api.esimaccess.com',
          stripeBaseUrl: 'https://your-stripe-backend.example.com',
        );
}
