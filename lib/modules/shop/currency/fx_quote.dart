import 'dart:convert';

import 'package:intl/intl.dart';

/// One locked Stripe conversion. [exchangeRate] is dollars per 1 local unit,
/// matching the website's one-day quote. Local price is dollars divided by it.
class FxQuote {
  const FxQuote({
    required this.currency,
    required this.exchangeRate,
    this.quoteId,
    this.expiresAt,
  });

  /// Marks a quote whose rate is dollars per local unit. Older saved quotes
  /// stored local currency per dollar and must not be divided.
  static const rateBasisUsdPerUnit = 'usd_per_unit';

  final String currency;
  final double exchangeRate;
  final String? quoteId;
  final DateTime? expiresAt;

  factory FxQuote.usd() {
    return const FxQuote(currency: 'USD', exchangeRate: 1);
  }

  bool get isUsd => currency.toUpperCase() == 'USD';

  bool get isExpired {
    final expiry = expiresAt;
    if (expiry == null) return false;
    return DateTime.now().toUtc().isAfter(expiry.toUtc());
  }

  factory FxQuote.fromJson(Map<String, dynamic> json) {
    final rate = json['exchangeRate'];
    final parsedRate = rate is num ? rate.toDouble() : double.tryParse('$rate');
    if (parsedRate == null || parsedRate <= 0) {
      return FxQuote.usd();
    }
    final currency = (json['currency'] ?? 'USD').toString().toUpperCase();
    if (currency == 'USD') return FxQuote.usd();
    if (json['rateBasis'] != rateBasisUsdPerUnit) return FxQuote.usd();
    return FxQuote(
      currency: currency,
      exchangeRate: parsedRate,
      quoteId: json['quoteId']?.toString(),
      expiresAt: _parseStripeTime(json['expiresAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'exchangeRate': exchangeRate,
      if (!isUsd) 'rateBasis': rateBasisUsdPerUnit,
      if (quoteId != null) 'quoteId': quoteId,
      if (expiresAt != null) 'expiresAt': expiresAt!.millisecondsSinceEpoch,
    };
  }

  String encode() => jsonEncode(toJson());

  static FxQuote? decode(String raw) {
    if (raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final quote = FxQuote.fromJson(Map<String, dynamic>.from(decoded));
      return quote.isUsd ? null : quote;
    } catch (_) {
      return null;
    }
  }

  /// Amount in the local currency, rounded the same way it is displayed.
  double localizedAmount(num usdAmount) {
    if (isUsd) return double.parse(usdAmount.toStringAsFixed(2));
    final raw = usdAmount / exchangeRate;
    if (_wholeUnitCurrencies.contains(currency)) return raw.roundToDouble();
    if (_threeDecimalCurrencies.contains(currency)) {
      return (raw * 1000).round() / 1000;
    }
    return (raw * 100).round() / 100;
  }

  /// Stripe minor units for [usdAmount]. PKR 850 is 85000.
  int toMinorUnits(num usdAmount) {
    final major = localizedAmount(usdAmount);
    if (_zeroDecimalCurrencies.contains(currency)) return major.round();
    if (_threeDecimalCurrencies.contains(currency)) return (major * 1000).round();
    return (major * 100).round();
  }

  String format(num usdAmount) {
    final major = localizedAmount(usdAmount);
    if (isUsd) return '\$${major.toStringAsFixed(2)} USD';
    if (currency == 'PKR') {
      return 'Rs${NumberFormat('#,##0', 'en').format(major.round())} PKR';
    }
    if (_wholeUnitCurrencies.contains(currency)) {
      return '${NumberFormat('#,##0', 'en').format(major.round())} $currency';
    }
    if (_threeDecimalCurrencies.contains(currency)) {
      return '${major.toStringAsFixed(3)} $currency';
    }
    return '${major.toStringAsFixed(2)} $currency';
  }
}

const Set<String> _zeroDecimalCurrencies = {
  'BIF',
  'CLP',
  'DJF',
  'GNF',
  'JPY',
  'KMF',
  'KRW',
  'MGA',
  'PYG',
  'RWF',
  'UGX',
  'VND',
  'VUV',
  'XAF',
  'XOF',
  'XPF',
};

const Set<String> _threeDecimalCurrencies = {
  'BHD',
  'JOD',
  'KWD',
  'OMR',
  'TND',
};

const Set<String> _wholeUnitCurrencies = {
  'PKR',
  ..._zeroDecimalCurrencies,
};

DateTime? _parseStripeTime(dynamic value) {
  if (value == null) return null;
  final parsed = value is num ? value.toDouble() : double.tryParse('$value');
  if (parsed == null) return null;
  final millis = parsed > 100000000000 ? parsed.round() : (parsed * 1000).round();
  return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
}

/// Country to the currency Stripe can quote. Countries omitted here,
/// including Iran, stay on USD because Stripe has no rate for them.
const Map<String, String> countryCurrency = {
  'AD': 'EUR', 'AE': 'AED', 'AF': 'AFN', 'AG': 'XCD', 'AI': 'XCD',
  'AL': 'ALL', 'AM': 'AMD', 'AO': 'AOA', 'AT': 'EUR', 'AU': 'AUD',
  'AW': 'AWG', 'AX': 'EUR', 'AZ': 'AZN', 'BA': 'BAM', 'BB': 'BBD',
  'BD': 'BDT', 'BE': 'EUR', 'BF': 'XOF', 'BG': 'EUR', 'BH': 'BHD',
  'BI': 'BIF', 'BJ': 'XOF', 'BL': 'EUR', 'BM': 'BMD', 'BN': 'BND',
  'BO': 'BOB', 'BR': 'BRL', 'BS': 'BSD', 'BT': 'INR', 'BW': 'BWP',
  'BZ': 'BZD', 'CA': 'CAD', 'CF': 'XAF', 'CG': 'XAF', 'CH': 'CHF',
  'CI': 'XOF', 'CK': 'NZD', 'CL': 'CLP', 'CM': 'XAF', 'CN': 'CNY',
  'CO': 'COP', 'CR': 'CRC', 'CV': 'CVE', 'CW': 'ANG', 'CY': 'EUR',
  'CZ': 'CZK', 'DE': 'EUR', 'DJ': 'DJF', 'DK': 'DKK', 'DM': 'XCD',
  'DO': 'DOP', 'DZ': 'DZD', 'EE': 'EUR', 'ES': 'EUR', 'FI': 'EUR',
  'FK': 'FKP', 'FR': 'EUR', 'GA': 'XAF', 'GB': 'GBP', 'GD': 'XCD',
  'GE': 'GEL', 'GF': 'EUR', 'GG': 'GBP', 'GI': 'GIP', 'GM': 'GMD',
  'GN': 'GNF', 'GP': 'EUR', 'GQ': 'XAF', 'GR': 'EUR', 'GS': 'GBP',
  'GT': 'GTQ', 'GW': 'XOF', 'GY': 'GYD', 'HK': 'HKD', 'HN': 'HNL',
  'HR': 'EUR', 'HT': 'HTG', 'HU': 'HUF', 'ID': 'IDR', 'IE': 'EUR',
  'IL': 'ILS', 'IM': 'GBP', 'IN': 'INR', 'IO': 'GBP', 'IS': 'ISK',
  'IT': 'EUR', 'JE': 'GBP', 'JM': 'JMD', 'JO': 'JOD', 'JP': 'JPY',
  'KE': 'KES', 'KG': 'KGS', 'KH': 'KHR', 'KI': 'AUD', 'KN': 'XCD',
  'KR': 'KRW', 'KW': 'KWD', 'KY': 'KYD', 'KZ': 'KZT', 'LC': 'XCD',
  'LI': 'CHF', 'LK': 'LKR', 'LR': 'LRD', 'LT': 'EUR', 'LU': 'EUR',
  'LV': 'EUR', 'MA': 'MAD', 'MC': 'EUR', 'MD': 'MDL', 'ME': 'EUR',
  'MF': 'EUR', 'MG': 'MGA', 'MK': 'MKD', 'ML': 'XOF', 'MN': 'MNT',
  'MO': 'MOP', 'MQ': 'EUR', 'MS': 'XCD', 'MT': 'EUR', 'MU': 'MUR',
  'MV': 'MVR', 'MX': 'MXN', 'MY': 'MYR', 'MZ': 'MZN', 'NA': 'NAD',
  'NC': 'XPF', 'NE': 'XOF', 'NL': 'EUR', 'NO': 'NOK', 'NP': 'NPR',
  'NR': 'AUD', 'NU': 'NZD', 'NZ': 'NZD', 'OM': 'OMR', 'PA': 'PAB',
  'PE': 'PEN', 'PF': 'XPF', 'PH': 'PHP', 'PK': 'PKR', 'PL': 'PLN',
  'PM': 'EUR', 'PN': 'GBP', 'PT': 'EUR', 'QA': 'QAR', 'RE': 'EUR',
  'RO': 'RON', 'RS': 'RSD', 'RW': 'RWF', 'SA': 'SAR', 'SE': 'SEK',
  'SG': 'SGD', 'SH': 'SHP', 'SI': 'EUR', 'SK': 'EUR', 'SM': 'EUR',
  'SN': 'XOF', 'ST': 'STD', 'SX': 'ANG', 'TD': 'XAF', 'TG': 'XOF',
  'TH': 'THB', 'TJ': 'TJS', 'TN': 'TND', 'TR': 'TRY', 'TT': 'TTD',
  'TV': 'AUD', 'TW': 'TWD', 'TZ': 'TZS', 'UA': 'UAH', 'UG': 'UGX',
  'UY': 'UYU', 'UZ': 'UZS', 'VA': 'EUR', 'VC': 'XCD', 'VN': 'VND',
  'WF': 'XPF', 'XK': 'EUR', 'YE': 'YER', 'YT': 'EUR', 'ZA': 'ZAR',
  'ZM': 'ZMW',
};

String currencyForCountry(String? countryCode) {
  if (countryCode == null || countryCode.isEmpty) return 'USD';
  return countryCurrency[countryCode.toUpperCase()] ?? 'USD';
}
