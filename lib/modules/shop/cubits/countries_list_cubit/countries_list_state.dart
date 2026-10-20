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

  /// Ungrouped regional packages, straight from the API. Unlike
  /// [structureRegionalPackages] (which groups everything by name and so
  /// merges different provider bundles — e.g. every "Europe" locationCode —
  /// into a single entry), this keeps each package's own `location` /
  /// `locationCode` so a specific bundle (e.g. "31 areas") can still be
  /// picked out. Used for the Popular tab's region cards.
  final List<PackageList>? rawRegionalPackages;

  /// Same as [rawRegionalPackages] but for Unlimited (day-pass) plans. Some
  /// bundles only exist as Standard (e.g. Europe 31 areas) and their Unlimited
  /// counterpart is a different bundle (Europe 35 areas).
  final List<PackageList>? rawRegionalUnlimitedPackages;

 final Map<String, PackageList> countryPriceMap;

  const CountriesState({
    required this.status,
    required this.message,
    required this.countriesList,

    required this.structureRegionalPackages,
    required this.structureGlobalPackages,
    this.rawRegionalPackages,
    this.rawRegionalUnlimitedPackages,
    required this.countryPriceMap,
  });

  factory CountriesState.initial() {
    return const CountriesState(
      status: CountriesStatus.initial,
      message: '',
      countriesList: [],
      structureRegionalPackages: [],
      structureGlobalPackages: [],
      rawRegionalPackages: [],
      rawRegionalUnlimitedPackages: [],
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
    List<PackageList>? rawRegionalPackages,
    List<PackageList>? rawRegionalUnlimitedPackages,
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
      rawRegionalPackages: rawRegionalPackages ?? this.rawRegionalPackages,
      rawRegionalUnlimitedPackages:
          rawRegionalUnlimitedPackages ?? this.rawRegionalUnlimitedPackages,
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
  rawRegionalPackages,
  rawRegionalUnlimitedPackages,
  countryPriceMap,
];

}
