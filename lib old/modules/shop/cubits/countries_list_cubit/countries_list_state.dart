import 'package:equatable/equatable.dart';
import 'package:nubesim/core/model/countries_data_model.dart';
import '../../model/all_data_packages_model.dart';

enum CountriesStatus {
  initial,
  loading,
  success,
  error,
}

class CountriesState extends Equatable {
  final CountriesStatus status;
  final String message;
  final List<CountriesData> countriesList;


  final List<Map<String, dynamic>>? structureRegionalPackages;
  final List<Map<String, dynamic>>? structureGlobalPackages;

 final Map<String, PackageList> countryPriceMap;

  const CountriesState({
    required this.status,
    required this.message,
    required this.countriesList,
  
    required this.structureRegionalPackages,
    required this.structureGlobalPackages,
    required this.countryPriceMap,
  });

  factory CountriesState.initial() {
    return const CountriesState(
      status: CountriesStatus.initial,
      message: '',
      countriesList: [],
      structureRegionalPackages: [],
      structureGlobalPackages: [],
      countryPriceMap: {},
    );
  }

  CountriesState copyWith({
    CountriesStatus? status,
    String? message,
    List<CountriesData>? countriesList,
    List<PackageList>? topUppackageList,
    List<Map<String, dynamic>>? structureRegionalPackages,
    List<Map<String, dynamic>>? structureGlobalPackages,
   Map<String, PackageList>? countryPriceMap,

  }) {
    return CountriesState(
      status: status ?? this.status,
      message: message ?? this.message,
      countriesList: countriesList ?? this.countriesList,
      structureRegionalPackages:
          structureRegionalPackages ?? this.structureRegionalPackages,
      structureGlobalPackages:
          structureGlobalPackages ?? this.structureGlobalPackages,
      countryPriceMap: countryPriceMap ?? this.countryPriceMap,
    );
  }

 @override
List<Object?> get props => [
  status,
  message,
  countriesList,
  structureRegionalPackages,
  structureGlobalPackages,
  countryPriceMap,
];

}
