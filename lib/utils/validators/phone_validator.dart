class PhoneValidator {
  static bool validate(String phoneNumber) {
    String pattern = r'^((\+92)?(0092)?(92)?(0)?)(3)([0-9]{9})$';
    // String pattern = r'^((0)?)(3)([0-9]{9})$';
    RegExp regex = RegExp(pattern);
    return (regex.hasMatch(phoneNumber)) ? true : false;
  }
}
