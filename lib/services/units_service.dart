class UnitsService {
  static const double metersToInches = 39.3701;
  static const double sqMetersToSqInches = 1550.0031;
  static const double metersToFeet = 3.28084;
  static const double sqMetersToSqFeet = 10.7639;

  static double convertMetersToInches(double meters) {
    return meters * metersToInches;
  }

  static double convertSqMetersToSqInches(double sqMeters) {
    return sqMeters * sqMetersToSqInches;
  }

  static double convertMetersToFeet(double meters) {
    return meters * metersToFeet;
  }

  static double convertSqMetersToSqFeet(double sqMeters) {
    return sqMeters * sqMetersToSqFeet;
  }
} 