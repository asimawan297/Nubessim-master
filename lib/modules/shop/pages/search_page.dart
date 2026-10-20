import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/modules/shop/cubits/countries_list_cubit/countries_list_cubit.dart';
import 'package:nubesim/modules/shop/cubits/countries_list_cubit/countries_list_state.dart';
import 'package:nubesim/modules/shop/cubits/data_package_cubit/data_package_cubit.dart';
import 'package:nubesim/modules/shop/cubits/data_package_cubit/data_package_state.dart';
import 'package:nubesim/modules/shop/model/all_data_packages_model.dart';
import 'package:nubesim/modules/shop/widgets/esims_result_list.dart';
import 'package:nubesim/ui/widgets/loading_indicator.dart';

class SearchPageShop extends StatefulWidget {
  const SearchPageShop({super.key});

  @override
  State<SearchPageShop> createState() => _SearchPageShopState();
}

class _SearchPageShopState extends State<SearchPageShop>
    with AutomaticKeepAliveClientMixin {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  String searchText = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    // Auto focus search bar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });

    // Debounced search
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        setState(() {
          searchText = _searchController.text.toLowerCase().trim();
        });
      });
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by keepAlive
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          fillColor: Colors.transparent,
                          hintText: 'Search country or package',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search,
                              color: Colors.grey, size: 18),
                          suffixIcon: searchText.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                  },
                                  child: const Icon(Icons.clear,
                                      color: Colors.grey, size: 18),
                                )
                              : null,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.only(top: 7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 📜 Content
            Expanded(
              child: BlocBuilder<CountriesCubit, CountriesState>(
                builder: (context, countriesState) {
                  return BlocBuilder<DataPackageCubit, DataPackageState>(
                    builder: (context, packagesState) {
                      // 🌀 Show loader immediately while fetching
                      if (countriesState.status == CountriesStatus.loading ||
                          packagesState.status == DataPackageStatus.loading) {
                        return const Center(child: LoadingIndicator());
                      }

                      // ❌ Error state
                      if (countriesState.status == CountriesStatus.error ||
                          packagesState.status == DataPackageStatus.error) {
                        return const Center(
                          child:
                              Text("Something went wrong. Please try again."),
                        );
                      }

                      // ✅ Success state - filter results
                      List<dynamic> allResults = [];

                      if (countriesState.status == CountriesStatus.success) {
                       
                        final filteredCountries = countriesState.countriesList
                            .where((c) => c.name.common
                                .toLowerCase()
                                .contains(searchText))
                            .map((c) => {
                                  'type': 'country',
                                  'data': c,
                                  'esimType': 'single',
                                })
                            .toList();
                        allResults.addAll(filteredCountries);
                      }

                      if (packagesState.status == DataPackageStatus.success) {
                       
                        final searchTextLower = searchText.toLowerCase();
                        final filteredPackages =
                            packagesState.structureRegionalPackages!
                                .where((pkg) {
                                  List<PackageList?> plans =
                                      pkg["plans"] as List<PackageList>;
                                  return plans.any((plan) {
                            
                                    return plan
                                      .toString()
                                      .toLowerCase()
                                      .contains(searchTextLower);
                                  });
                                })
                                .map((pkg) => {
                                      'type': 'regional',
                                      'data': pkg,
                                      'esimType': 'regional',
                                    })
                                .toList();
                        // print(packagesState.structureGlobalPackages);
                        // debugger();
                        //      final filteredPackagesGlobal = packagesState.structureGlobalPackages!
                        //     .where((pkg) =>
                        //         pkg["name"].toLowerCase().contains(searchText)
                        //         )
                        //     .map((pkg) => {
                        //           'type': 'global',
                        //           'data': pkg,
                        //           'esimType': 'global',
                        //         })
                        //     .toList();
                        // allResults.addAll(filteredPackagesGlobal);
                        allResults.addAll(filteredPackages);
                      }

                      if (allResults.isEmpty) {
                        return const Center(
                          child: Text("No results found"),
                        );
                      }

                      // 🖼 Wrap in scrollable
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: EsimResultsList(allResults: allResults),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
