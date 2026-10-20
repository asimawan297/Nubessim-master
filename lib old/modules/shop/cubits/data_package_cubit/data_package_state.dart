import '../../model/all_data_packages_model.dart';

enum DataPackageStatus {
  initial,
  loading,
  success,
  error,
}

class DataPackageState {
  final DataPackageStatus status;
  final String message;
  final List<PackageList> packageList;
  final List<PackageList> allPackageList;
  final List<PackageList> topUppackageList;
  final List<Map<String, dynamic>>? structureRegionalPackages; 
  final List<Map<String, dynamic>>? structureGlobalPackages; 
  final Map<String, PackageList> countryPriceMap;

  DataPackageState({
    required this.status,
    required this.message,
    required this.packageList,
    required this.allPackageList,
    required this.topUppackageList,
    this.structureRegionalPackages, this.structureGlobalPackages,
    required this.countryPriceMap,
  });

  factory DataPackageState.initial() {
    return DataPackageState(
      status: DataPackageStatus.initial,
      message: '',
      packageList: [],
      allPackageList: [],
      topUppackageList: [],
      structureRegionalPackages: [],
      structureGlobalPackages: [],
       countryPriceMap: {},
    );
  }

  DataPackageState copyWith({
    DataPackageStatus? status,
    String? message,
    List<PackageList>? packageList,
    List<PackageList>? allPackageList,
    List<PackageList>? topUppackageList,
    List<Map<String, dynamic>>? structureRegionalPackages,
    List<Map<String, dynamic>>? structureGlobalPackages,
    Map<String, PackageList>? countryPriceMap,

  }) {
    return DataPackageState(
      status: status ?? this.status,
      message: message ?? this.message,
      packageList: packageList ?? this.packageList,
      allPackageList: allPackageList ?? this.allPackageList,
      topUppackageList: topUppackageList ?? this.topUppackageList,
      structureRegionalPackages: structureRegionalPackages ?? this.structureRegionalPackages,
      structureGlobalPackages: structureGlobalPackages ?? this.structureGlobalPackages,
      countryPriceMap: countryPriceMap ?? this.countryPriceMap,
    );
  }
}
