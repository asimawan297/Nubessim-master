import 'package:flutter/material.dart';

class PersistentNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget initialRoute;

  const PersistentNavigator({
    super.key,
    required this.navigatorKey,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            if (settings.name == '/') {
              return initialRoute;
            }
            // Any other routes would be handled here
            return initialRoute;
          },
        );
      },
    );
  }
}
