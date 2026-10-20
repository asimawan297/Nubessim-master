


  Map<String, String> parseLpaString(String lpa) {
  // Example input: LPA:1$rsp-eu.simlessly.com$C99DB5A50CA24E61938884AE3EF01406
  
  // Split by $
  List<String> parts = lpa.split('\$');

  if (parts.length < 3) {
    throw FormatException("Invalid LPA string format");
  }

  return {
    "smDpAddress": parts[1],  // rsp-eu.simlessly.com
    "activationCode": parts[2],  // C99DB5A50CA24E61938884AE3EF01406
  };
}


