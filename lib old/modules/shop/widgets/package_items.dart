import 'package:flutter/material.dart';
import 'package:nubesim/config/routes/nav_router.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:nubesim/utils/heights_and_widths.dart';
import '../model/all_data_packages_model.dart';
import '../../authentication/widgets/auth_required_wrapper.dart';
import '../pages/secure_checkout_screen.dart';
class PackageItem extends StatelessWidget {
  final Map<String, dynamic> package;
  final String esimType;
  final BuildContext context;

  const PackageItem({
    super.key,
    required this.package,
    required this.esimType,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    final List locationNetworkList =
        package['locationNetworkList'] ?? [];

    final bool hasNetworkInfo = locationNetworkList.isNotEmpty;

    final String? locationLogo = hasNetworkInfo
        ? locationNetworkList.first['locationLogo']
        : null;

    String? fullImageUrl;
    if (locationLogo != null) {
      fullImageUrl = locationLogo.startsWith('http')
          ? locationLogo
          : 'https://static.redteago.com$locationLogo';
    }

    return InkWell(
     onTap: () {
  if (AuthRequiredWrapper.isUserLoggedIn()) {
    final packageModel = PackageList.fromJson(package);

    NavRouter.push(
      context,
      SecureCheckoutScreen(
        name: packageModel.name,
        package: packageModel,
      ),
    );
  } else {
    final packageModel = PackageList.fromJson(package);
    AuthRequiredWrapper.showLoginDialog(
      context,
      message: "Please login to purchase this eSIM package",
      checkoutName: packageModel.name,
      checkoutPackage: packageModel,
    );
  }
},

      child: Card(
        elevation: 6.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Image.network(
                      fullImageUrl ?? '',
                      height: 30,
                      width: 30,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.flag),
                    ),
                    w1,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package['name'] ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: const Color(0xff606A71),
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_outlined,
                size: 18.0,
                color: Color(0xff606A71),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
