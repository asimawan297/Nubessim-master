class DOBValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your date of birth';
    }

    // Check mm/dd/yyyy format
    final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!regex.hasMatch(value)) {
      return 'Date must be in mm/dd/yyyy format (numbers only)';
    }

    // Validate actual date and age
    try {
      final parts = value.split('/');
      final month = int.parse(parts[0]);
      final day = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final dob = DateTime(year, month, day);
      final now = DateTime.now();

      // Check if the parsed date matches input (avoids 02/30/2020 issues)
      if (dob.month != month || dob.day != day || dob.year != year) {
        return 'Invalid date, please check the values';
      }

      // Check if user is at least 18
      final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
      if (dob.isAfter(eighteenYearsAgo)) {
        return 'You must be at least 18 years old';
      }
    } catch (e) {
      return 'Invalid date, please check the values';
    }

    return null;
  }
}
