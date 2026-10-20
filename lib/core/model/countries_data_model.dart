class CountriesData {
  final Flags flags;
  final Name name;
  final String cca2;
  final String region;
  final List<String> timezones;

  CountriesData({
    required this.flags,
    required this.name,
    required this.cca2,
    required this.region,
    required this.timezones,
  });

  factory CountriesData.fromJson(Map<String, dynamic> json) {
    return CountriesData(
      flags: Flags.fromJson(json['flags']),
      name: Name.fromJson(json['name']),
      cca2: json['cca2'] ?? '',
      region: json['region'] ?? '',
      timezones: List<String>.from(json['timezones'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "flags": flags.toJson(),
      "name": name.toJson(),
      "cca2": cca2,
      "region": region,
      "timezones": timezones,
    };
  }
}

class Flags {
  final String png;
  final String svg;
  final String alt;

  Flags({
    required this.png,
    required this.svg,
    required this.alt,
  });

  factory Flags.fromJson(Map<String, dynamic> json) {
    return Flags(
      png: json['png'] ?? '',
      svg: json['svg'] ?? '',
      alt: json['alt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "png": png,
      "svg": svg,
      "alt": alt,
    };
  }
}

class Name {
  final String common;
  final String official;

  Name({
    required this.common,
    required this.official,
  });

  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      common: json['common'] ?? '',
      official: json['official'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "common": common,
      "official": official,
    };
  }
}
