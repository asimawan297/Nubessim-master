extension ExtendedString on String {
  // File Name => FileName
  String removeSpaces() {
    return replaceAll(' ', '').trim();
  }

  // user => User
  String toCapitalize() {
    return isEmpty
        ? ''
        : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  // user name => User Name
  String toCapitaliseEachWordFirstChar() {
    if (trim().isEmpty) return '';
    return split(' ')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  // 5 => 5.0
  double toDouble() => double.parse(this);

  // '10' => 10
  int toInt() => int.parse(this);

  Uri toUri() => Uri.parse(this);

  bool get isUrl => contains('https://') || contains('http://');
}
