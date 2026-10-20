import 'package:flutter/foundation.dart';

/// Discount percentages shown to customers: 25% Standard / 50% Unlimited by
/// default. The website admin ("eSIM Discounts") can change them; the app
/// receives them through `PackageControls`.
class Discounts {
  Discounts._();

  static const double defaultStandard = 25;
  static const double defaultUnlimited = 50;
  static const double maxAllowed = 90;

  static double standard = defaultStandard;
  static double unlimited = defaultUnlimited;

  /// The biggest discount, for texts like "Save up to X% at checkout".
  static final ValueNotifier<double> maxPercent =
      ValueNotifier<double>(defaultUnlimited);

  static double percentFor(int? dataType) =>
      dataType == 2 ? unlimited : standard;

  /// Ignores values that are missing or outside 0..[maxAllowed].
  static void update({Object? standardPercent, Object? unlimitedPercent}) {
    standard = _valid(standardPercent) ?? standard;
    unlimited = _valid(unlimitedPercent) ?? unlimited;
    maxPercent.value = standard > unlimited ? standard : unlimited;
  }

  static void reset() =>
      update(standardPercent: defaultStandard, unlimitedPercent: defaultUnlimited);

  static double? _valid(Object? value) {
    if (value is! num) return null;
    final v = value.toDouble();
    return v >= 0 && v <= maxAllowed ? v : null;
  }

  /// 25 -> "25", 12.5 -> "12.5"
  static String format(double percent) {
    final text = percent.toStringAsFixed(2);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
