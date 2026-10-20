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
import '../../../utils/discounts.dart';
import '../../../utils/heights_and_widths.dart';
import '../cubits/countries_list_cubit/countries_list_state.dart';
import '../pages/packages_selection_screen.dart';
import '../utils/package_listing_price.dart';

enum _PopularSlotType { country, region }

/// One entry in the fixed Popular tab layout — either a specific country
/// (matched by its common name) or a region (matched by name prefix, e.g.
/// "Europe", picking one specific bundle by area/country count).
class _PopularSlot {
  final _PopularSlotType type;
  final String name;
  final int? targetAreaCount;

  /// Area count of the bundle to use on the Unlimited tab when it differs
  /// from [targetAreaCount] (e.g. Europe: Standard = 31 areas, but the
  /// Unlimited plans only exist in the 35-areas bundle).
  final int? unlimitedAreaCount;

  const _PopularSlot.country(this.name)
      : type = _PopularSlotType.country,
        targetAreaCount = null,
        unlimitedAreaCount = null;

  const _PopularSlot.region(this.name,
      {this.targetAreaCount, this.unlimitedAreaCount})
      : type = _PopularSlotType.region;
}

class DataTab extends StatefulWidget {
  const DataTab({super.key});

  @override
  State<DataTab> createState() => _DataTabState();
}

class _DataTabState extends State<DataTab> with WidgetsBindingObserver {
  String selectedName = "Popular";

  final TextEditingController _searchController = TextEditingController();
  String searchText = "";
  bool isSearching = false;
  Timer? _debounceTimer;

  /// Exact Popular tab order the client asked for (screenshot, 2026-09-27):
  /// 12 destinations, Europe fixed at position 3 and Asia at position 7,
  /// not appended after the countries.
  static const List<_PopularSlot> _popularOrder = [
    _PopularSlot.country('United States'),
    _PopularSlot.country('Mexico'),
    _PopularSlot.country('Japan'),
    _PopularSlot.region('Europe', targetAreaCount: 31, unlimitedAreaCount: 35),
    _PopularSlot.country('France'),
    _PopularSlot.country('Portugal'),
    _PopularSlot.region('Asia'),
    _PopularSlot.country('Costa Rica'),
    _PopularSlot.country('Brazil'),
    _PopularSlot.country('United Kingdom'),
    _PopularSlot.country('Dominican Republic'),
    _PopularSlot.country('United Arab Emirates'),
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<CountriesCubit>().loadAllData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Refresh admin settings and provider packages whenever the app returns.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    context.read<CountriesCubit>().loadAllData();
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
        ValueListenableBuilder<double>(
          valueListenable: Discounts.maxPercent,
          builder: (context, _, __) => selectedName == "Popular"
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
                          text:
                              "(Save up to ${Discounts.format(Discounts.maxPercent.value)}% at checkout)",
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
                          text:
                              "(Save up to ${Discounts.format(Discounts.maxPercent.value)}% at checkout)",
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
        ),
        h1,
        selectedName == "Popular"
            ? BlocBuilder<CountriesCubit, CountriesState>(
                builder: (context, countryState) {
                  if (countryState.status == CountriesStatus.loading) {
                    return LoadingIndicator();
                  }

                  if (countryState.status == CountriesStatus.error) {
                    return Text(countryState.message);
                  }

                  if (countryState.status == CountriesStatus.success) {
                    final isPriceLoading = countryState.countryPriceMap.isEmpty;
                    final rawRegionalPackages =
                        countryState.rawRegionalPackages ?? [];

                    final items = <Widget>[];
                    for (final slot in _popularOrder) {
                      if (slot.type == _PopularSlotType.country) {
                        if (!slot.name
                            .toLowerCase()
                            .contains(searchText.toLowerCase())) {
                          continue;
                        }

                        final matches = countryState.countriesList
                            .where((c) => c.name.common == slot.name)
                            .toList();
                        if (matches.isEmpty) continue;
                        final country = matches.first;

                        if (isPriceLoading) {
                          items.add(_popularCardShimmer());
                          continue;
                        }

                        final matchedPackage =
                            countryState.countryPriceMap[country.cca2];
                        if (matchedPackage == null) continue;

                        final locationLogo = country.flags.png;
                        final fullImageUrl = locationLogo.startsWith('http')
                            ? locationLogo
                            : 'https://static.redteago.com$locationLogo';

                        items.add(_popularCard(
                          context: context,
                          name: country.name.common,
                          imageUrl: fullImageUrl,
                          isNetworkImage: true,
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
                        ));
                      } else {
                        final region = _resolveRegionSlot(
                            slot,
                            rawRegionalPackages,
                            countryState.rawRegionalUnlimitedPackages ?? []);
                        if (region == null) continue;
                        final regionName = (region['name'] ?? '').toString();
                        if (!regionName
                            .toLowerCase()
                            .contains(searchText.toLowerCase())) {
                          continue;
                        }

                        items.add(_popularCard(
                          context: context,
                          name: regionName,
                          imageUrl: (region['imageUrl'] ?? '').toString(),
                          isNetworkImage: false,
                          onTap: () {
                            final countries = context.read<CountriesCubit>();
                            Future<Map<String, dynamic>?> loadRegion() async {
                              await countries.loadAllData();
                              if (!mounted) return null;
                              return _resolveRegionSlot(
                                slot,
                                countries.state.rawRegionalPackages ?? [],
                                countries.state.rawRegionalUnlimitedPackages ??
                                    [],
                              );
                            }

                            NavRouter.push(
                              context,
                              PackagesSelectionScreen(
                                name: regionName,
                                routeType: "search",
                                packageList: region['plans'],
                                unlimitedPackageList: region['unlimitedPlans'],
                                refreshPackages: loadRegion,
                              ),
                            );
                          },
                        ));
                      }
                    }

                    if (items.isEmpty) {
                      return const SizedBox();
                    }

                    return Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 0),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => h1,
                        itemBuilder: (context, index) => items[index],
                      ),
                    );
                  }

                  return const SizedBox();
                },
              )
            : selectedName == "Single"
                ? BlocBuilder<CountriesCubit, CountriesState>(
                    builder: (context, countryState) {
                      if (countryState.status == CountriesStatus.loading) {
                        return LoadingIndicator();
                      }

                      if (countryState.status == CountriesStatus.error) {
                        return Text(countryState.message);
                      }

                      if (countryState.status == CountriesStatus.success) {
                        final filteredCountries = countryState.countriesList
                            .where((country) => country.name.common
                                .toLowerCase()
                                .contains(searchText.toLowerCase()))
                            .toList();

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
                              final fullImageUrl = locationLogo
                                      .startsWith('http')
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
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
                                                style: context
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  color:
                                                      const Color(0xff606A71),
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                          ],
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
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final sortedPackages =
                            List<Map<String, dynamic>>.from(filteredPackages)
                              ..sort((a, b) {
                                final priceA =
                                    _lowestDisplayedPriceForRegion(a);
                                final priceB =
                                    _lowestDisplayedPriceForRegion(b);
                                if (priceA == null && priceB == null) return 0;
                                if (priceA == null) return 1;
                                if (priceB == null) return -1;
                                return priceA.compareTo(priceB);
                              });

                        return Expanded(
                          child: ListView.separated(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: sortedPackages.length,
                            itemBuilder: (context, index) {
                              final flag = sortedPackages[index];
                              final regionName = flag["name"];
                              final List<PackageList> plans =
                                  List<PackageList>.from(flag["plans"] ?? []);

                              final priceText = plans.isNotEmpty
                                  ? startingPriceLabelForRegionalGlobalPlans(
                                      plans,
                                      quote: context
                                          .watch<CurrencyCubit>()
                                          .state,
                                    )
                                  : '';

                              return InkWell(
                                onTap: () {
                                  final countries =
                                      context.read<CountriesCubit>();
                                  Future<Map<String, dynamic>?>
                                      loadRegion() async {
                                    await countries.loadAllData();
                                    if (!mounted) return null;
                                    final freshList = isRegional
                                        ? countries
                                            .state.structureRegionalPackages
                                        : countries
                                            .state.structureGlobalPackages;
                                    return freshList
                                        ?.where(
                                          (item) => item['name'] == regionName,
                                        )
                                        .firstOrNull;
                                  }

                                  NavRouter.push(
                                    context,
                                    PackagesSelectionScreen(
                                      name: regionName,
                                      routeType: "search",
                                      packageList: plans,
                                      refreshPackages: loadRegion,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
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
                                                style: context
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  color:
                                                      const Color(0xff606A71),
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                          ],
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

  /// Resolves a region slot (e.g. "Europe") to one specific API bundle.
  ///
  /// IMPORTANT (confirmed against the live API on 2026-09-27): package
  /// `name` values are just "Europe 3GB 30Days" etc. — they never contain
  /// an area count, so wording like "Europe (31 areas)" can't be matched
  /// from the name. The different bundles are really distinguished by
  /// which countries are listed in each package's `location` field (a
  /// comma-separated list of country codes) — so the "areas" count is just
  /// how many codes are in that list. That's what this matches on, via
  /// [rawRegionalPackages] (the ungrouped packages, unlike
  /// `structureRegionalPackages` which merges every bundle for a region
  /// into one entry and loses this distinction).
  ///
  /// If [_PopularSlot.targetAreaCount] is null (no exact count confirmed
  /// yet, e.g. Asia), this defaults to the bundle with the MOST countries
  /// — a reasonable guess, but double-check with the client once they see
  /// it, the same way Europe's exact "31" was confirmed.
  Map<String, dynamic>? _resolveRegionSlot(
      _PopularSlot slot,
      List<PackageList> rawRegionalPackages,
      List<PackageList> rawRegionalUnlimitedPackages) {
    final candidates = rawRegionalPackages
        .where((pkg) =>
            pkg.name.trim().toLowerCase().startsWith(slot.name.toLowerCase()))
        .toList();
    if (candidates.isEmpty) return null;

    final byAreaCount = <int, List<PackageList>>{};
    for (final pkg in candidates) {
      byAreaCount.putIfAbsent(_areaCountOf(pkg), () => []).add(pkg);
    }

    final int chosenCount;
    if (slot.targetAreaCount != null) {
      if (!byAreaCount.containsKey(slot.targetAreaCount)) return null;
      chosenCount = slot.targetAreaCount!;
    } else {
      chosenCount = byAreaCount.keys.reduce((a, b) => a > b ? a : b);
    }

    // Unlimited tab: use the bundle with [unlimitedAreaCount] areas when the
    // Standard bundle has no Unlimited plans of its own (Europe 31 → 35).
    List<PackageList>? unlimitedPlans;
    if (slot.unlimitedAreaCount != null) {
      unlimitedPlans = rawRegionalUnlimitedPackages
          .where((pkg) =>
              pkg.name.trim().toLowerCase().startsWith(slot.name.toLowerCase()))
          .where((pkg) => _areaCountOf(pkg) == slot.unlimitedAreaCount)
          .toList();
      if (unlimitedPlans.isEmpty) unlimitedPlans = null;
    }

    return {
      // Displayed name matches the client's clean design (just "Europe",
      // no area count) — the count above is only used internally to pick
      // which specific bundle this card links to.
      'name': slot.name,
      'imageUrl': slot.name.toLowerCase() == 'europe'
          ? 'assets/regionalIMG/Europe-removebg-preview1.png'
          : slot.name.toLowerCase() == 'asia'
              ? 'assets/regionalIMG/Asia-removebg-preview1.png'
              : 'assets/regionalIMG/World_Map-removebg-preview1.png',
      'plans': byAreaCount[chosenCount],
      'unlimitedPlans': unlimitedPlans,
    };
  }

  int _areaCountOf(PackageList pkg) => pkg.location
      .split(',')
      .map((code) => code.trim())
      .where((code) => code.isNotEmpty)
      .length;

  Widget _popularCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Card used in the Popular tab: flag/icon + name + chevron, no price.
  Widget _popularCard({
    required BuildContext context,
    required String name,
    required String imageUrl,
    required bool isNetworkImage,
    required VoidCallback onTap,
  }) {
    final Widget leadingImage = imageUrl.isEmpty
        ? const Icon(Icons.flag)
        : isNetworkImage
            ? Image.network(
                imageUrl,
                height: 30,
                width: 30,
                errorBuilder: (_, __, ___) => const Icon(Icons.flag),
              )
            : Image.asset(
                imageUrl,
                height: 30,
                width: 30,
                errorBuilder: (_, __, ___) => const Icon(Icons.flag),
              );

    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 6.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  leadingImage,
                  w2,
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'eSIM',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: const Color(0xff606A71).withOpacity(0.7),
                            fontSize: 11.0,
                          ),
                        ),
                        Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: const Color(0xff606A71),
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xff606A71),
              ),
            ],
          ),
        ),
      ),
    );
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
