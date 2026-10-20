import 'package:flutter/material.dart';
import 'package:nubesim/config/routes/nav_router.dart';
import 'package:nubesim/core/model/countries_data_model.dart';
import 'package:nubesim/modules/shop/pages/packages_selection_screen.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';

class CountryItem extends StatelessWidget {
  final CountriesData country;
  final String esimType;

  const CountryItem({
    super.key,
    required this.country,
    required this.esimType,
  });

  @override
  Widget build(BuildContext context) {
    final locationLogo = country.flags.png;
    String fullImageUrl = locationLogo.startsWith('http')
        ? locationLogo
        : 'https://static.redteago.com$locationLogo';

    return InkWell(
      onTap: () {
        NavRouter.push(
          context,
          PackagesSelectionScreen(
            name: country.name.common,
            locationName: country.cca2,
            routeType:"search"
          ),
        );
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
                      fullImageUrl,
                      height: 30,
                      width: 30,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.flag),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            country.name.common,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: const Color(0xff606A71),
                              fontSize: 16.0,
                            ),
                          ),
                          // Text(
                          //   esimType,
                          //   style: context.textTheme.bodySmall?.copyWith(
                          //     color: Colors.grey[600],
                          //     fontSize: 12.0,
                          //   ),
                          // ),
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
