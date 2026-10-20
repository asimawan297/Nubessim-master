import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/modules/shop/repository/shop_repository.dart';
import 'package:nubesim/utils/helper_widgets.dart';
import '../../../../core/auth_service/firestore_service.dart';
import 'countries_list_state.dart';
import 'package:nubesim/modules/shop/model/all_data_packages_model.dart';

class CountriesCubit extends Cubit<CountriesState> {
  final FireStoreService fireStoreService;
  final ShopRepository shopRepository;

  CountriesCubit({
    required this.fireStoreService,
    required this.shopRepository,
  }) : super(CountriesState.initial());

  Future<void> fetchCountries() async {
    emit(state.copyWith(status: CountriesStatus.loading));
    try {
      final countries = await fireStoreService.fetchCountries();
      emit(state.copyWith(
        status: CountriesStatus.success,
        countriesList: countries,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CountriesStatus.error,
        message: e.toString(),
      ));
    }
  }

  /// 🔥 Load ALL data safely
  Future<void> loadAllData() async {
    emit(state.copyWith(status: CountriesStatus.loading));

    await Future.wait([
      getAllDataPackages(selectedSimType: "", isLoading: false),
      getAllDataPackages(selectedSimType: "!GL", isLoading: false),
      getAllDataPackages(selectedSimType: "!RG", isLoading: false),
    ]);

    emit(state.copyWith(status: CountriesStatus.success));
  }

  Future<void> getAllDataPackages({
    selectedSimType = "",
    bool isLoading = true,
  }) async {
    try {
      final response = await shopRepository.getAllDataPackages(
          selectedSimType: selectedSimType);

      final packages = response.obj.packageList;

      if (packages.isEmpty) return;

      /// 🔥 Create location price map ONCE
      final Map<String, PackageList> locationMap = {};
      final oneGBRegex = RegExp(r'\b1\s?gb\b', caseSensitive: false);

      final sevenDaysRegex = RegExp(r'\b7\s?day', caseSensitive: false);

      for (var pkg in packages) {
        if (oneGBRegex.hasMatch(pkg.name) &&
            sevenDaysRegex.hasMatch(pkg.name)) {
          if (!locationMap.containsKey(pkg.location)) {
            /// First time for this location
            locationMap[pkg.location] = pkg;
          } else {
            /// Compare price and keep lowest
            final existingPkg = locationMap[pkg.location]!;

            if (pkg.retailPrice < existingPkg.retailPrice) {
              locationMap[pkg.location] = pkg;
            }
          }
        }
      }

      if (selectedSimType == "!GL") {
        final sortedList = await createDataStructure(packages, "!GL");

        emit(state.copyWith(
          structureGlobalPackages: sortedList,
        ));
      } else if (selectedSimType == "!RG") {
        final sortedList = await createDataStructure(packages, "!RG");

        emit(state.copyWith(
          structureRegionalPackages: sortedList,
        ));
      } else {
        emit(state.copyWith(
          countryPriceMap: locationMap,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CountriesStatus.error,
        message: e.toString(),
      ));
    }
  }

  createDataStructure(List<PackageList> plans, [type]) {
    Map<String, List<PackageList>> groupedPlans = {};

    for (var plan in plans) {
      final match = RegExp(r"^(.+?)\s\d").firstMatch(plan.name);
      if (match != null) {
        String region = match.group(1)!.trim();
        groupedPlans.putIfAbsent(region, () => []);
        groupedPlans[region]!.add(plan);
      }
    }
    List<Map<String, dynamic>> result = groupedPlans.entries.map((entry) {
      // Get the first package in this region
      final firstPackage = entry.value.first;

      // Handle image url same as your logic
      String? fullImageUrl;

      if (type == "!RG" || type == "!GL") {
        final regionName = entry.key.toLowerCase();

        if (regionName == 'europe') {
          fullImageUrl = 'assets/regionalIMG/Europe-removebg-preview1.png';
        } else if (regionName == 'south america') {
          fullImageUrl =
              'assets/regionalIMG/South_america-removebg-preview1.png';
        } else if (regionName == 'north america') {
          fullImageUrl =
              'assets/regionalIMG/North_america-removebg-preview1.png';
        } else if (regionName == 'china (mainland hk macao)') {
          fullImageUrl =
              'assets/regionalIMG/china_mainland___Japan___south_Korea-removebg-preview1.png';
        } else if (regionName == 'africa') {
          fullImageUrl = 'assets/regionalIMG/Africa-removebg-preview1.png';
        } else if (regionName == 'middle east') {
          fullImageUrl =
              'assets/regionalIMG/Middle_east_and_North_Africa-removebg-preview1.png';
        } else if (regionName.contains('china') && regionName.contains('hk')) {
          fullImageUrl =
              'assets/regionalIMG/china_mainland_Japan-removebg-preview1.png';
        } else if (regionName == 'asia (7 areas)') {
          fullImageUrl = 'assets/regionalIMG/Asia-removebg-preview1.png';
        } else if (regionName == 'asia (12 areas)') {
          fullImageUrl = 'assets/regionalIMG/Asia-removebg-preview1.png';
        } else if (regionName == 'asia-20') {
          fullImageUrl = 'assets/regionalIMG/Asia-removebg-preview1.png';
        } else if (regionName.contains('singapore') &&
            regionName.contains('malaysia') &&
            regionName.contains('thailand')) {
          fullImageUrl =
              'assets/regionalIMG/Singapore___Malaysia_and_Thailand-removebg-preview1.png';
        } else if (regionName == 'global (120+ areas)' ||
            regionName == 'global139') {
          fullImageUrl = 'assets/regionalIMG/World_Map-removebg-preview1.png';
        } else if (regionName == 'singapore & malaysia & thailand') {
          fullImageUrl =
              'assets/regionalIMG/Singapore___Malaysia_and_Thailand-removebg-preview1.png';
        } else {
          fullImageUrl = 'assets/regionalIMG/World_Map-removebg-preview1.png';
        }
      } else {
        if (firstPackage.locationNetworkList.isNotEmpty) {
          final locationLogo = firstPackage.locationNetworkList[0].locationLogo;

          if (locationLogo.isNotEmpty) {
            fullImageUrl = locationLogo.startsWith('http')
                ? locationLogo
                : 'https://static.redteago.com$locationLogo';
          }
        }
      }

      return {
        "name": entry.key,
        "imageUrl": fullImageUrl,
        "plans": entry.value.map((p) => p).toList(),
      };
    }).toList();
    return result;
  }

  selectedPackageLogic(List<PackageList> packageList) {
    // Sort packages by volume in descending order
    packageList.sort((a, b) => b.volume.compareTo(a.volume));

// Helper function to get volume in GB
    num getVolumeInGB(PackageList pkg) => formatBytesToGB(pkg.volume);

// Find all 3GB packages
    final threeGBPackages =
        packageList.where((p) => getVolumeInGB(p) == 3.0).toList();
// Find all 2GB packages
    final twoGBPackages =
        packageList.where((p) => getVolumeInGB(p) == 2.0).toList();
// Find all 2GB packages
    final fiveGBPackages =
        packageList.where((p) => getVolumeInGB(p) == 5.0).toList();

// debugger();
    PackageList? selectedPackage;

// First try to find 3GB packages
    if (threeGBPackages.isNotEmpty) {
      // If multiple 3GB packages, check for FUP
      if (threeGBPackages.length > 1) {
        final fupPackages = threeGBPackages.where((p) {
          return
              // (p.name.toLowerCase().contains('fup')) ||
              (p.name.contains("nonhkip") ||
                  p.name.toLowerCase().contains('5G'));
        }).toList();
        selectedPackage =
            fupPackages.isNotEmpty ? fupPackages.first : threeGBPackages.first;
      } else {
        selectedPackage = threeGBPackages.first;
      }
    }
// If no 3GB, try 2GB packages
    else if (twoGBPackages.isNotEmpty) {
      // If multiple 2GB packages, check for FUP
      if (twoGBPackages.length > 1) {
        final fupPackages = twoGBPackages
            .where((p) => p.name.toLowerCase().contains('fup'))
            .toList();
        selectedPackage =
            fupPackages.isNotEmpty ? fupPackages.first : twoGBPackages.first;
      } else {
        selectedPackage = twoGBPackages.first;
      }
    }
    // If no 2GB, try 5GB packages
    else if (fiveGBPackages.isNotEmpty) {
      // If multiple 2GB packages, check for FUP
      if (fiveGBPackages.length > 1) {
        final fupPackages = fiveGBPackages
            .where((p) => p.name.toLowerCase().contains('fup'))
            .toList();
        selectedPackage =
            fupPackages.isNotEmpty ? fupPackages.first : fiveGBPackages.first;
      } else {
        selectedPackage = fiveGBPackages.first;
      }
    }

// Fallback to largest package if no 3GB or 2GB found
    return selectedPackage ?? packageList.first;
  }
}
