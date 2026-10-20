// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/modules/shop/cubits/data_package_cubit/data_package_cubit.dart';
import 'package:nubesim/ui/widgets/loading_indicator.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:nubesim/utils/extensions/padding_extension.dart';
import 'package:sizer/sizer.dart';
import '../../../utils/heights_and_widths.dart';
import '../cubits/data_package_cubit/data_package_state.dart';
import '../model/all_data_packages_model.dart';
import '../utils/package_listing_price.dart';
import '../widgets/eSIM_package_tile.dart';

class PackagesSelectionScreen extends StatefulWidget {
  PackagesSelectionScreen(
      {super.key,
      required this.name,
      this.iccid,
      this.slug,
      this.orderNo,
      this.routeType,
      this.locationName,
      this.isTopUp = false,
      this.packageCode,
      this.packageList,
      this.unlimitedPackageList,
      this.refreshPackages});

  final String name;
  final String? routeType;
  final String? iccid;
  final String? slug;
  final String? orderNo;
  final String? locationName;
  String? packageCode;
  bool isTopUp = false;
  List<PackageList>? packageList = [];

  /// Optional separate source for the Unlimited tab (used when the Standard
  /// bundle, e.g. Europe 31 areas, has no Unlimited plans of its own).
  List<PackageList>? unlimitedPackageList;
  final Future<Map<String, dynamic>?> Function()? refreshPackages;

  @override
  State<PackagesSelectionScreen> createState() =>
      _PackagesSelectionScreenState();
}

class _PackagesSelectionScreenState extends State<PackagesSelectionScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.packageList == null) {
      context.read<DataPackageCubit>().getAllDataPackages(
          iccid: widget.iccid ?? "",
          selectedSimType: widget.locationName ?? "",
          packageCode: widget.packageCode ?? "",
          orderNo: widget.orderNo ?? "",
          dataType: 1,
          slug: widget.slug ?? "");
    }

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(_onTabChanged);

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (widget.refreshPackages case final refresh?) {
      refresh().then((fresh) {
        if (!mounted || fresh == null) return;
        setState(() {
          widget.packageList = fresh['plans'];
          widget.unlimitedPackageList = fresh['unlimitedPlans'];
        });
      });
    } else if (widget.packageList == null) {
      context.read<DataPackageCubit>().getAllDataPackages(
            iccid: widget.iccid ?? "",
            selectedSimType: widget.locationName ?? "",
            packageCode: widget.packageCode ?? "",
            orderNo: widget.orderNo ?? "",
            dataType: _tabController.index + 1,
            slug: widget.slug ?? "",
          );
    }
  }

  void _onTabChanged() {
    // This gets called on tap AND swipe
    if (_tabController.indexIsChanging) return;

    final index = _tabController.index; // 0 = Standard, 1 = Unlimited

    context.read<DataPackageCubit>().getAllDataPackages(
          iccid: widget.iccid ?? "",
          selectedSimType: widget.locationName ?? "",
          packageCode: widget.packageCode ?? "",
          isLoading: false,
          orderNo: widget.orderNo ?? "",
          dataType: index + 1,
          slug: widget.slug ?? "",
        );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          extractCountry(widget.name),
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textColor,
            fontSize: 19.0,
            fontFamily: "Inter",
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Container(
            width: 75.w,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(100),
            ),
            padding: EdgeInsets.all(6.0),
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xfaEF5576).withOpacity(0.7), // pink
                    Color(0xfaCA2045).withOpacity(1), // dark red
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: "Inter",
              ),
              tabs: [Tab(text: 'Standard'), Tab(text: 'Unlimited')],
              onTap: (index) {
                context.read<DataPackageCubit>().getAllDataPackages(
                    iccid: widget.iccid ?? "",
                    selectedSimType: widget.locationName ?? "",
                    packageCode: widget.packageCode ?? "",
                    orderNo: widget.orderNo ?? "",
                    dataType: index + 1,
                    slug: widget.slug ?? "");
              },
            ),
          ),
        ),
      ),
      body: TabBarView(controller: _tabController, children: [
        widget.packageList != null
            ? Builder(builder: (context) {
                final filteredAndSorted = dedupeRateCards(
                  widget.packageList!.where(isStandardListingPackage).toList(),
                );
                return filteredAndSorted.isEmpty
                    ? Center(
                        child: Text(widget.routeType == "search"
                            ? "Thank you for your interest. Unfortunately, our eSIM service is currently unavailable for this destination."
                            : "No TOPUPs are available"),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: filteredAndSorted.length,
                        padding: const EdgeInsets.symmetric(
                            vertical: 24.0, horizontal: 30.0),
                        itemBuilder: (context, index) {
                          final package = filteredAndSorted[index];
                          return EsimPackageTile(
                            name: filteredAndSorted[index].name,
                            package: package,
                            countryName: widget.name,
                            stripeTopUp: widget.isTopUp ? true : false,
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return h2;
                        },
                      );
              })
            : BlocBuilder<DataPackageCubit, DataPackageState>(
                builder: (context, state) {
                  if (state.status == DataPackageStatus.loading) {
                    return LoadingIndicator();
                  } else if (state.status == DataPackageStatus.error) {
                    return Text(state.message);
                  } else if (state.status == DataPackageStatus.success) {
                    final List<PackageList> packages =
                        dedupeRateCards(state.packageList);

                    return packages.isEmpty
                        ? Center(
                            child: Text(widget.routeType == "search"
                                ? "eSIM service is currently unavailable for this destination."
                                : "No TOPUPs are available"),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: packages.length,
                            padding: const EdgeInsets.symmetric(
                                vertical: 24.0, horizontal: 30.0),
                            itemBuilder: (context, index) {
                              final package = packages[index];
                              return EsimPackageTile(
                                isSingleSIM: widget.packageList == null,
                                countryName: widget.name,
                                name: packages[index].name,
                                package: package,
                                stripeTopUp: widget.isTopUp ? true : false,
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return h2;
                            },
                          );
                  } else {
                    return SizedBox();
                  }
                },
              ),
        widget.packageList != null
            ? Builder(builder: (context) {
                /// Get standard plans
                final standardPlans =
                    (widget.unlimitedPackageList ?? widget.packageList!)
                        .where(isUnlimitedSourcePackage)
                        .toList();

                if (standardPlans.isEmpty) {
                  return Center(
                    child: Text(
                        "Thank you for your interest. Unfortunately, our eSIM service is currently unavailable for this destination.",
                        textAlign: TextAlign.center),
                  ).paddingSymmetric(horizontal: 12, vertical: 0);
                }

                /// Pick best package
                final basePackage = selectUnlimitedBasePackage(standardPlans);
                if (basePackage == null) {
                  return const Center(
                    child: Text("No TOPUPs are available"),
                  );
                }

                final unlimitedPlans =
                    buildUnlimitedDayPlans(basePackage, standardPlans);

                if (unlimitedPlans.isEmpty) {
                  return Center(
                    child: Text(
                        "Thank you for your interest. Unfortunately, our eSIM service is currently unavailable for this destination.",
                        textAlign: TextAlign.center),
                  ).paddingSymmetric(horizontal: 12, vertical: 0);
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: unlimitedPlans.length,
                  padding: const EdgeInsets.symmetric(
                      vertical: 24.0, horizontal: 30.0),
                  itemBuilder: (context, index) {
                    final package = unlimitedPlans[index];

                    return EsimPackageTile(
                      name: package.name,
                      package: package,
                      countryName: widget.name,
                      stripeTopUp: widget.isTopUp ? true : false,
                    );
                  },
                  separatorBuilder: (_, __) => h2,
                );
              })
            : BlocBuilder<DataPackageCubit, DataPackageState>(
                builder: (context, state) {
                  if (state.status == DataPackageStatus.loading) {
                    return LoadingIndicator();
                  } else if (state.status == DataPackageStatus.error) {
                    return Text(state.message);
                  } else if (state.status == DataPackageStatus.success) {
                    for (final pkg in state.packageList) {
                      pkg.dataType = 2;
                    }
                    final List<PackageList> packages =
                        dedupeRateCards(state.packageList);
                    return packages.isEmpty
                        ? Center(
                            child: Text(widget.routeType == "search"
                                ? "eSIM service is currently unavailable for this destination."
                                : "No TOPUPs are available"))
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: packages.length,
                            padding: const EdgeInsets.symmetric(
                                vertical: 24.0, horizontal: 30.0),
                            itemBuilder: (context, index) {
                              final package = packages[index];
                              return EsimPackageTile(
                                isSingleSIM: widget.packageList == null,
                                countryName: widget.name,
                                name: packages[index].name,
                                package: package,
                                stripeTopUp: widget.isTopUp ? true : false,
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return h2;
                            },
                          );
                  } else {
                    return SizedBox();
                  }
                },
              )
      ]),
    );
  }
}
