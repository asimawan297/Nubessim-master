import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/core/exceptions/api_error.dart';
import 'package:nubesim/modules/shop/model/all_data_packages_model.dart';
import '../../../../utils/helper_widgets.dart';
import '../../repository/shop_repository.dart';
import 'data_package_state.dart';

class DataPackageCubit extends Cubit<DataPackageState> {
  final ShopRepository shopRepository;

  DataPackageCubit({required this.shopRepository})
      : super(DataPackageState.initial());

  Future<void> getAllDataPackages(
      {selectedSimType = "",
      iccid = "",
      orderNo = "",
      slug = "",
      dataType,
      isLoading = true,
      packageCode = "",
      structure = false}) async {
    if (isLoading) {
      emit(state.copyWith(status: DataPackageStatus.loading));
    }
    try {
      var response = await shopRepository.getAllDataPackages(
          selectedSimType: selectedSimType,
          iccid: iccid,
          orderNo: orderNo,
          slug: slug,
          dataType: dataType,
          packageCode: packageCode);
      final packages = response.obj.packageList;
      if (packages.isNotEmpty) {
        List<PackageList> filteredPackages = packages.where((package) {
          // First, check that location does not contain "global" or "region"
          bool isValidLocation =
              !package.location.toLowerCase().contains('global') &&
                  !package.location.toLowerCase().contains('region');

          // Then, check if the length of the location split by commas is 1
          bool isSingleLocation = getLocationCount(package.location) == 1;

          // Add the package if it passes both conditions
          return isValidLocation && isSingleLocation;
        }).toList();

        List<PackageList> filteredAndSorted = filteredPackages
            .where((pkg) =>
                formatBytesToGB(pkg.volume) >= 1 &&
                pkg.duration > 0) // Any positive duration
            .toList()
          ..sort((a, b) {
            final volCompare =
                formatBytesToGB(a.volume).compareTo(formatBytesToGB(b.volume));
            if (volCompare != 0) return volCompare;
            return a.duration.compareTo(b.duration);
          });

        if (dataType != null && dataType == 2) {
          if (filteredAndSorted.isEmpty) {
            emit(state.copyWith(
              status: DataPackageStatus.success,
              packageList: [],
            ));
            return;
          }
          final dayList = [1, 3, 5, 7, 10, 15, 30];
          final packageList = filteredAndSorted;
          final package = selectedPackageLogic(packageList);
          if (package == null) {
            emit(state.copyWith(
              status: DataPackageStatus.success,
              packageList: [],
            ));
            return;
          }
          List<PackageList> packages = [];
          for (var i = 0; i < dayList.length; i++) {
            final temPackage = PackageList.fromJson(package.toJson());
            temPackage.duration = dayList[i];
            temPackage.retailPrice = dayList[i] * temPackage.retailPrice;
            // print(
            //     "retail price ${dayList[i] * temPackage.retailPrice} =  ${dayList[i]} X ${temPackage.retailPrice}");
            packages.add(temPackage);
          }
          filteredAndSorted = packages;
        }

        if (selectedSimType == "!GL") {
          var sortedList =
              await createDataStructure(response.obj.packageList, "!GL");
          // print("FILLED GLOBAL");
          emit(state.copyWith(
            status: DataPackageStatus.success,
            structureGlobalPackages: sortedList,
          ));
        } else if (selectedSimType == "!RG") {
          var sortedList =
              await createDataStructure(response.obj.packageList, "!RG");
          emit(state.copyWith(
            status: DataPackageStatus.success,
            structureRegionalPackages: sortedList,
          ));
        } else {
          final regex = RegExp(r'\b1\s?gb\b', caseSensitive: false);

          final Map<String, PackageList> priceMap = {};

          for (var pkg in packages) {
            if (regex.hasMatch(pkg.name)) {
              priceMap.putIfAbsent(pkg.location, () => pkg);
            }
          }

          emit(state.copyWith(
            status: DataPackageStatus.success,
            packageList: filteredAndSorted,
            allPackageList: packages,
            countryPriceMap: priceMap,
          ));
        }
      } else {
        emit(state.copyWith(
          status: DataPackageStatus.success,
          packageList: [],
        ));
      }
    } on ApiError catch (e) {
      emit(
        state.copyWith(status: DataPackageStatus.error, message: e.message),
      );
    }
  }

  selectedPackageLogic(List<PackageList> packageList) {
    if (packageList.isEmpty) return null;
    final sorted = [...packageList]..sort((a, b) {
        // 1) Data filter priority: 3GB -> 2GB -> 5GB -> lower/others.
        final dataCompare = _dataPriority(a).compareTo(_dataPriority(b));
        if (dataCompare != 0) return dataCompare;

        // 2) Network type: prefer highest generation (5G first, then 4G).
        final networkCompare =
            _networkPriority(a).compareTo(_networkPriority(b));
        if (networkCompare != 0) return networkCompare;

        // 3) Plan speed: prefer FUP exactly 1 Mbps, then lower FUP rates.
        final speedCompare = _speedPriority(a).compareTo(_speedPriority(b));
        if (speedCompare != 0) return speedCompare;

        // 4) Price: if all above equal, pick lower retail price.
        return a.retailPrice.compareTo(b.retailPrice);
      });

    return sorted.first;
  }

  int _dataPriority(PackageList pkg) {
    final gb = formatBytesToGB(pkg.volume);
    if (gb == 3) return 0;
    if (gb == 2) return 1;
    if (gb == 5) return 2;
    // Lower/other plans afterwards.
    return 10 + gb.round();
  }

  int _networkPriority(PackageList pkg) {
    final generation = getMaxGenerationFromLocations(pkg.locationNetworkList);
    if (generation >= 5) return 0;
    if (generation == 4) return 1;
    if (generation == 3) return 2;
    return 3;
  }

  int _speedPriority(PackageList pkg) {
    final fup = _extractFupMbpsFromPackage(pkg);
    if (fup == null) return 1000;
    if (fup == 1.0) return 0; // first choice: FUP 1mbps
    if (fup < 1.0) return (fup * 1000).round() + 10; // then lower rates
    return (fup * 1000).round() + 100; // then higher than 1mbps
  }

  double? _extractFupMbps(String? fupPolicy) {
    if (fupPolicy == null || fupPolicy.trim().isEmpty) return null;
    final normalized = fupPolicy.toLowerCase().replaceAll(' ', '');
    final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(normalized);
    if (match == null) return null;
    final value = double.tryParse(match.group(1)!);
    if (value == null) return null;
    if (normalized.contains('kbps')) return value / 1000;
    return value; // Mbps default
  }

  double? _extractFupMbpsFromPackage(PackageList pkg) {
    return _extractFupMbps(pkg.fupPolicy) ??
        _extractFupMbps(pkg.name) ??
        _extractFupMbps(pkg.description);
  }

  // Function to extract generation number from network type
  int extractGeneration(String networkType) {
    // Convert to uppercase for case-insensitive matching
    final type = networkType.toUpperCase();

    // Try to extract number from patterns like 5G, 4G, 3G, etc.
    final match = RegExp(r'(\d+)G').firstMatch(type);
    if (match != null) {
      return int.parse(match.group(1)!);
    }

    // Handle other network type formats
    if (type.contains('5G')) return 5;
    if (type.contains('4G')) return 4;
    if (type.contains('3G')) return 3;
    if (type.contains('2G')) return 2;
    if (type.contains('1G')) return 1;

    return 0; // Unknown/not found
  }

// Main function to find highest G from a list
  int getMaxGenerationFromLocations(
      List<LocationNetworkList> locationNetworkList) {
    return locationNetworkList
        .expand((location) => (location.operatorList))
        .map((operator) =>
            extractGeneration(operator['networkType']?.toString() ?? ''))
        .fold(0, (max, current) => current > max ? current : max);
  }

// List<String> totalCountries() {
  // // Merge all lists
  // final allPackages = [
  //   ...?state.packageList,
  //   ...?state.structureGlobalPackages,
  //   ...?state.structureRegionalPackages,
  // ];

  // // Assuming each package has a `country` or `countryName` field
  // final countryNames = allPackages
  //     .map((pkg) => pkg.name )
  //     .where((c) => c != null && c.isNotEmpty)
  //     .toSet()
  //     .toList();

  // return countryNames;
// }

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

  Future<void> getAllTopUpPackages(String packageCode) async {
    emit(state.copyWith(status: DataPackageStatus.loading));
    try {
      final response = await shopRepository.getAllTopUpPackages(packageCode);

      emit(state.copyWith(
        status: DataPackageStatus.success,
        topUppackageList: response.obj.packageList,
      ));
    } on ApiError catch (e) {
      emit(state.copyWith(
        status: DataPackageStatus.error,
        message: e.message,
      ));
    }
  }
}
