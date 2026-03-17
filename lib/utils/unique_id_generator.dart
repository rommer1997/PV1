import 'dart:math';

class UniqueIdGenerator {
  static final _random = Random();

  /// Generates a unique ID in the format SLP-[ROLE]-[RANDOM]
  /// Example: SLP-P-7281 (Player), SLP-C-9921 (Coach)
  static String generate(String rolePrefix) {
    final year = DateTime.now().year.toString().substring(2);
    final randomDigits = _random.nextInt(9000) + 1000;
    return 'SLP-$rolePrefix$year-$randomDigits';
  }

  static String getPrefixForRole(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'player':
        return 'P';
      case 'coach':
        return 'C';
      case 'scout':
        return 'S';
      case 'referee':
        return 'R';
      case 'journalist':
        return 'J';
      case 'brand':
        return 'B';
      case 'fan':
        return 'F';
      case 'staff':
        return 'A';
      case 'tutor':
        return 'T';
      default:
        return 'U';
    }
  }
}
