import 'package:flutter/material.dart';
import 'package:nubesim/constants/keys.dart';
import 'package:nubesim/modules/shop/currency/fx_quote.dart';
import 'package:nubesim/utils/discounts.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../core/di/service_locator.dart';
import '../core/storage_service/storage_service.dart';

var storageService = StorageService(sharedPreferences: sl<SharedPreferences>());

getUID() {
  return storageService.getString(StorageKeys.userUid);
}

/// Markup added on top of the API price.
const double kPriceMarkup = 0.05;

/// Raw API price units that display as [usd] before the 25% / 50% discount
/// (inverse of the conversion in [calculateTotal]). Used to apply the price
/// overrides from the website admin.
int retailPriceForUsd(double usd) =>
    (usd / (0.0001 * (1 + kPriceMarkup))).round();

String calculateTotal(price, {required bool isUnlimited}) {
  final basePrice = convertToDollars(price);

  final markupPercent = kPriceMarkup;

  final finalPrice = basePrice + (basePrice * markupPercent);

  final rounded = roundToNearestQuarter(finalPrice);

  return rounded.toStringAsFixed(2);
}

/// Package discount before tax (25% standard, 50% unlimited by default,
/// editable in the website admin, see [Discounts]).
double discountedRetailPrice(num retailPrice, {required int? dataType}) {
  final discountPercent = Discounts.percentFor(dataType);
  return retailPrice.toDouble() * (1 - discountPercent / 100);
}

/// Final displayed price after discount + tax/rounding (for sorting).
double? displayedStartingPrice(num retailPrice, {required int? dataType}) {
  final discounted =
      discountedRetailPrice(retailPrice, dataType: dataType);
  final total = calculateTotal(discounted, isUnlimited: dataType == 2);
  return double.tryParse(total);
}

/// Homepage label, e.g. "From $1.50 USD" or "From Rs850 PKR".
String startingPriceLabel(
  num retailPrice, {
  required int? dataType,
  required FxQuote quote,
}) {
  final total = displayedStartingPrice(retailPrice, dataType: dataType);
  if (total == null) return '';
  return 'From ${quote.format(total)}';
}

num calculateTotalInt(price, {required bool isUnlimited}) {
  final basePrice = convertToDollars(price);

  final markupPercent = kPriceMarkup;

  final finalPrice = basePrice + (basePrice * markupPercent);

  return roundToNearestQuarter(finalPrice);
}

// String calculateTotal(price) {
//   num withTax = convertToDollars(price) + convertToDollars(price) * 0.05;
//   num rounded = roundToNearestQuarter(withTax);
//   return rounded.toStringAsFixed(2); // ensures 2 decimal places
// }

// calculateTotalInt(price) {
//   num withTax = convertToDollars(price) + convertToDollars(price) * 0.05;
//   num rounded = roundToNearestQuarter(withTax);
//   return rounded;
// }

double convertToDollars(num units) {
  return units * 0.0001; // Each unit equals 0.0001 dollars
}

num roundToNearestQuarter(num value) {
  // Round to nearest 0.25
  return (value * 4).round() / 4.0;
}

Widget customDivider(
    {double? vPadding, double? hPadding, double? thickness, Color? color}) {
  return Padding(
    padding: EdgeInsets.symmetric(
      vertical: vPadding ?? 12.0,
      horizontal: hPadding ?? 2.0,
    ),
    child: Divider(
      thickness: thickness ?? 0.6,
      color: color ?? Colors.grey.shade400,
    ),
  );
}

Widget customVerticalDivider({
  double? height = 20,
  double? thickness = 1,
  Color? color = Colors.grey,
}) {
  return Container(
    height: height,
    width: thickness,
    color: color,
  );
}

String formatBytes(int bytes) {
  // print(bytes);
  double gb = bytes / (1024 * 1024 * 1024);
  if (gb >= 1) {
    return "${gb % 1 == 0 ? gb.toInt() : gb.toStringAsFixed(2)} GB";
  } else {
    double mb = bytes / (1024 * 1024);
    return "${mb % 1 == 0 ? mb.toInt() : mb.toStringAsFixed(2)} MB";
  }
}

num formatBytesToGB(int bytes) {
  double gb = bytes / (1024 * 1024 * 1024);

  return (gb % 1 == 0 ? gb.toInt() : num.parse(gb.toStringAsFixed(2)));
}

num formatBytesToGB1(int bytes) {
  final gb = bytes / (1024 * 1024 * 1024);

  // Round to 2 decimal places
  final rounded = double.parse(gb.toStringAsFixed(2));

  // If whole number, return int
  if (rounded == rounded.roundToDouble()) {
    return rounded.toInt();
  }

  return rounded;
}

// Function to get the number of locations (splitting the string by commas)
int getLocationCount(String location) {
  List<String> locationList = location.split(',');
  return locationList.length;
}

int getCountryCount(String countries) {
  // Split the string by commas and return the length of the resulting list
  List<String> countryList = countries.split(',');
  return countryList.length;
}
