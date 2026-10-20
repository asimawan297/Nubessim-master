import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';
import 'package:nubesim/modules/shop/cubits/countries_list_cubit/countries_list_cubit.dart';
import 'package:nubesim/modules/shop/cubits/currency_cubit/currency_cubit.dart';
import 'package:nubesim/modules/shop/model/all_data_packages_model.dart';
import 'package:nubesim/modules/shop/pages/search_page.dart';
import 'package:nubesim/modules/shop/widgets/banner_section.dart';
import 'package:nubesim/modules/shop/widgets/sim_type_selector.dart';
import 'package:nubesim/ui/widgets/loading_indicator.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:nubesim/utils/helper_widgets.dart';
import 'package:shimmer/shimmer.dart';
import '../../../config/routes/nav_router.dart';
import '../../../constants/app_colors.dart';
import '../../../generated/assets.dart';
import '../../../utils/heights_and_widths.dart';
import '../cubits/countries_list_cubit/countries_list_state.dart';
import '../pages/packages_selection_screen.dart';
import '../utils/package_listing_price.dart';

class DataTab extends StatefulWidget {
  const DataTab({super.key});

  @override
  State<DataTab> createState() => _DataTabState();
}

class _DataTabState extends State<DataTab> {
  String selectedName = "Popular";

  final TextEditingController _searchController = TextEditingController();
  String searchText = "";
  bool isSearching = false;
  Timer? _debounceTimer;
  final List<String> popularCountries = [
    "United States",
    "France",
    "Turkey",
    "Germany",
    "Japan",
    "Thailand",
    "Australia",
    "Singapore",
    "Italy",
    "UK",
    "Spain",
    "India",
    "Canada",
    "Mexico",
    "Dominican Republic",
    "UAE",
    "Costa Rica",
  ];
  @override
  void initState() {
    super.initState();
    context.read<CountriesCubit>().loadAllData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<String> bannerList = [
    Assets.svgBanner1,
    Assets.svgBanner2,
    Assets.svgBanner3,
    Assets.svgBanner4
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchCard(context),
        h3,
        BannerSection(bannerList: bannerList),
        h1,
        SimTypesSelector(
            selectedName: selectedName,
            onChanged: (value) {
              setState(() => selectedName = value);
            }),
        h2,
        selectedName == "Popular"
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text.rich(
                  TextSpan(
                    text: "Popular Countries  ",
                    style: context.textTheme.titleMedium?.copyWith(
                      color: AppColors.black,
                      fontFamily: "Inter",
                      fontSize: 19.0,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: "(Save up to 50% at checkout)",
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black.withOpacity(0.7),
                          fontFamily: "Inter",
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text.rich(
                  TextSpan(
                    text: "$selectedName eSIM ",
                    style: context.textTheme.titleMedium?.copyWith(
                      color: AppColors.black,
                      fontFamily: "Inter",
                      fontSize: 19.0,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: "(Save up to 50% at checkout)",
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black.withOpacity(0.7),
                          fontFamily: "Inter",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        h1,
        selectedName == "Single" || selectedName == "Popular"
            ? BlocBuilder<CountriesCubit, CountriesState>(
                builder: (context, countryState) {
                  if (countryState.status == CountriesStatus.loading) {
                    return LoadingIndicator();
                  }

                  if (countryState.status == CountriesStatus.error) {
                    return Text(countryState.message);
                  }

                  if (countryState.status == CountriesStatus.success) {
                    List countriesToShow = countryState.countriesList;

// 🔹 If Popular selected → filter only popular list
                    if (selectedName == "Popular") {
                      countriesToShow = countriesToShow.where((country) {
                        return popularCountries.contains(country.name.common);
                      }).toList();
                    }

                    final filteredCountries = countriesToShow.where((country) {
                      return country.name.common
                          .toLowerCase()
                          .contains(searchText.toLowerCase());
                    }).toList();

                    return Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 0),
                        itemCount: filteredCountries.length,
                        itemBuilder: (context, index) {
                          final country = filteredCountries[index];

                          final matchedPackage =
                              countryState.countryPriceMap[country.cca2];

                          bool isPriceLoading =
                              countryState.countryPriceMap.isEmpty;

                          String priceText = "";

                          if (matchedPackage != null) {
                            priceText = startingPriceLabel(
                              matchedPackage.retailPrice,
                              dataType: matchedPackage.dataType,
                              quote: context.watch<CurrencyCubit>().state,
                            );
                          }

                          final locationLogo = country.flags.png;
                          final fullImageUrl = locationLogo.startsWith('http')
                              ? locationLogo
                              : 'https://static.redteago.com$locationLogo';

                          if (isPriceLoading) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height: 40,
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }

                          if (priceText.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return InkWell(
                            onTap: () {
                              NavRouter.push(
                                context,
                                PackagesSelectionScreen(
                                  name: country.name.common,
                                  routeType: "search",
                                  locationName: country.cca2,
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
                                  children: [
                                    Image.network(
                                      fullImageUrl,
                                      height: 30,
                                      width: 30,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.flag),
                                    ),
                                    w2,
                                    Expanded(
                                      child: Text(
                                        country.name.common,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: context.textTheme.titleMedium
                                            ?.copyWith(
                                          color: const Color(0xff606A71),
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      priceText,
                                      style: const TextStyle(
                                        color: Color(0xff606A71),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },

                        /// FIXED
                        separatorBuilder: (context, index) {
                          final country = filteredCountries[index];
                          final matchedPackage =
                              countryState.countryPriceMap[country.cca2];

                          if (matchedPackage == null) {
                            return const SizedBox.shrink();
                          }

                          final price = startingPriceLabel(
                            matchedPackage.retailPrice,
                            dataType: matchedPackage.dataType,
                            quote: context.watch<CurrencyCubit>().state,
                          );

                          if (price.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return h1;
                        },
                      ),
                    );
                  }

                  return const SizedBox();
                },
              )
            : BlocBuilder<CountriesCubit, CountriesState>(
                builder: (context, state) {
                  if (state.status == CountriesStatus.loading) {
                    return LoadingIndicator();
                  } else if (state.status == CountriesStatus.error) {
                    return Text(state.message);
                  } else if (state.status == CountriesStatus.success) {
                    final isRegional = selectedName == "Regional";

                    final filteredPackages = isRegional
                        ? state.structureRegionalPackages
                        : state.structureGlobalPackages;

                    if (filteredPackages == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final sortedPackages =
                        List<Map<String, dynamic>>.from(filteredPackages)
                          ..sort((a, b) {
                            final priceA = _lowestDisplayedPriceForRegion(a);
                            final priceB = _lowestDisplayedPriceForRegion(b);
                            if (priceA == null && priceB == null) return 0;
                            if (priceA == null) return 1;
                            if (priceB == null) return -1;
                            return priceA.compareTo(priceB);
                          });

                    return Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: sortedPackages.length,
                        itemBuilder: (context, index) {
                          final flag = sortedPackages[index];
                          final regionName = flag["name"];
                          final List<PackageList> plans =
                              List<PackageList>.from(flag["plans"] ?? []);

                          final priceText = plans.isNotEmpty
                              ? startingPriceLabelForRegionalGlobalPlans(
                                  plans,
                                  quote: context.watch<CurrencyCubit>().state,
                                )
                              : '';

                          return InkWell(
                            onTap: () {
                              NavRouter.push(
                                context,
                                PackagesSelectionScreen(
                                  name: regionName,
                                  routeType: "search",
                                  packageList: flag["plans"],
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
                                  children: [
                                    Image.asset(
                                      flag["imageUrl"],
                                      height: 30,
                                      width: 30,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.flag),
                                    ),
                                    w2,
                                    Expanded(
                                      child: Text(
                                        regionName,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: context.textTheme.titleMedium
                                            ?.copyWith(
                                          color: const Color(0xff606A71),
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      priceText,
                                      style: const TextStyle(
                                        color: Color(0xff606A71),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),

                                //  Row(
                                //   children: [
                                //     Image.asset(
                                //       flag["imageUrl"],
                                //       height: 30,
                                //       width: 30,
                                //       errorBuilder: (_, __, ___) =>
                                //           const Icon(Icons.flag),
                                //     ),
                                //     const SizedBox(width: 8),
                                //     Expanded(
                                //       child: isPriceLoading
                                //           ? Shimmer.fromColors(
                                //               baseColor: Colors.grey[300]!,
                                //               highlightColor: Colors.grey[100]!,
                                //               child: Container(
                                //                 height: 16,
                                //                 width: double.infinity,
                                //                 color: Colors.white,
                                //               ),
                                //             )
                                //           : Text(
                                //               priceText.isEmpty
                                //                   ? regionName
                                //                   : '$regionName – $priceText',
                                //               overflow: TextOverflow.ellipsis,
                                //               maxLines: 2,
                                //               style: context
                                //                   .textTheme.titleMedium
                                //                   ?.copyWith(
                                //                 color: const Color(0xff606A71),
                                //                 fontSize: 16.0,
                                //               ),
                                //             ),
                                //     ),
                                //   ],
                                // ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => h1,
                      ),
                    );
                  } else {
                    return SizedBox();
                  }
                },
              ),
      ],
    );
  }

  double? _lowestDisplayedPriceForRegion(Map<String, dynamic> flag) {
    final plans = List<PackageList>.from(flag['plans'] ?? []);
    return lowestDisplayedPriceForRegionalGlobalPlans(plans);
  }

  Widget _buildSearchCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 14.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffCD57B2), Color(0xff911B76)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          context.read<CountriesCubit>().fetchCountries();
          NavRouter.push(context, SearchPageShop());
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100.0),
          ),
          padding: const EdgeInsets.only(left: 14, top: 6, bottom: 6, right: 8),
          child: Row(
            children: [
              SvgPicture.asset(
                Assets.svgAirplane,
                color: AppColors.black,
                height: 18.0,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  "Select Country",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
              ),
              CircleAvatar(
                backgroundColor: AppColors.primaryColor,
                child: const Icon(Icons.search, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
