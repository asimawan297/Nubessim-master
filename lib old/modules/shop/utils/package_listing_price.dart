import 'package:nubesim/modules/shop/currency/fx_quote.dart';
import 'package:nubesim/modules/shop/model/all_data_packages_model.dart';
import 'package:nubesim/utils/helper_widgets.dart';

/// Same duration options as [PackagesSelectionScreen] unlimited tab.
const List<int> unlimitedListingDayOptions = [1, 3, 5, 7, 10, 15, 30];

bool isStandardListingPackage(PackageList pkg) {
  return pkg.dataType == 1 &&
      formatBytesToGB(pkg.volume) >= 1 &&
      (pkg.duration == 1 ||
          pkg.duration == 7 ||
          pkg.duration == 15 ||
          pkg.duration == 30);
}

bool isUnlimitedSourcePackage(PackageList pkg) {
  return pkg.dataType == 2 && formatBytesToGB(pkg.volume) >= 1;
}

/// Picks the unlimited base plan using the same rules as the package detail screen.
PackageList? selectUnlimitedBasePackage(List<PackageList> packageList) {
  if (packageList.isEmpty) return null;
  final sorted = [...packageList]..sort((a, b) {
        final dataCompare = _dataPriority(a).compareTo(_dataPriority(b));
        if (dataCompare != 0) return dataCompare;

        final networkCompare =
            _networkPriority(a).compareTo(_networkPriority(b));
        if (networkCompare != 0) return networkCompare;

        final speedCompare = _speedPriority(a).compareTo(_speedPriority(b));
        if (speedCompare != 0) return speedCompare;

        return a.retailPrice.compareTo(b.retailPrice);
      });
  return sorted.first;
}

/// Lowest displayed price across packages visible on the regional/global detail page.
double? lowestDisplayedPriceForRegionalGlobalPlans(List<PackageList> plans) {
  double? lowest;

  for (final pkg in plans.where(isStandardListingPackage)) {
    final price = displayedStartingPrice(
      pkg.retailPrice,
      dataType: pkg.dataType,
    );
    if (price != null && price > 0 && (lowest == null || price < lowest)) {
      lowest = price;
    }
  }

  final unlimitedSources =
      plans.where(isUnlimitedSourcePackage).toList(growable: false);
  final basePackage = selectUnlimitedBasePackage(unlimitedSources);
  if (basePackage != null) {
    final basePrice = basePackage.retailPrice;
    for (final day in unlimitedListingDayOptions) {
      final price = displayedStartingPrice(
        basePrice * day,
        dataType: 2,
      );
      if (price != null && price > 0 && (lowest == null || price < lowest)) {
        lowest = price;
      }
    }
  }

  return lowest;
}

String startingPriceLabelForRegionalGlobalPlans(
  List<PackageList> plans, {
  required FxQuote quote,
}) {
  final lowest = lowestDisplayedPriceForRegionalGlobalPlans(plans);
  if (lowest == null) return '';
  return 'From ${quote.format(lowest)}';
}

int _dataPriority(PackageList pkg) {
  final gb = formatBytesToGB(pkg.volume);
  if (gb == 3) return 0;
  if (gb == 2) return 1;
  if (gb == 5) return 2;
  return 10 + gb.round();
}

int _networkPriority(PackageList pkg) {
  final generation = _getMaxGenerationFromLocations(pkg.locationNetworkList);
  if (generation >= 5) return 0;
  if (generation == 4) return 1;
  if (generation == 3) return 2;
  return 3;
}

int _speedPriority(PackageList pkg) {
  final fup = _extractFupMbpsFromPackage(pkg);
  if (fup == null) return 1000;
  if (fup == 1.0) return 0;
  if (fup < 1.0) return (fup * 1000).round() + 10;
  return (fup * 1000).round() + 100;
}

double? _extractFupMbps(String? fupPolicy) {
  if (fupPolicy == null || fupPolicy.trim().isEmpty) return null;
  final normalized = fupPolicy.toLowerCase().replaceAll(' ', '');
  final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(normalized);
  if (match == null) return null;
  final value = double.tryParse(match.group(1)!);
  if (value == null) return null;
  if (normalized.contains('kbps')) return value / 1000;
  return value;
}

double? _extractFupMbpsFromPackage(PackageList pkg) {
  return _extractFupMbps(pkg.fupPolicy) ??
      _extractFupMbps(pkg.name) ??
      _extractFupMbps(pkg.description);
}

int _extractGeneration(String networkType) {
  final type = networkType.toUpperCase();
  final match = RegExp(r'(\d+)G').firstMatch(type);
  if (match != null) return int.parse(match.group(1)!);
  if (type.contains('5G')) return 5;
  if (type.contains('4G')) return 4;
  if (type.contains('3G')) return 3;
  if (type.contains('2G')) return 2;
  return 0;
}

int _getMaxGenerationFromLocations(List<LocationNetworkList> locations) {
  return locations
      .expand((location) => location.operatorList)
      .map((operator) =>
          _extractGeneration(operator['networkType']?.toString() ?? ''))
      .fold(0, (max, current) => current > max ? current : max);
}
