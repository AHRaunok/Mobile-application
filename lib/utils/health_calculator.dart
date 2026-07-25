class HealthCalculator {
  // ১. আদর্শ ওজন
  static Map<String, double> getIdealWeightRange(double heightInCm) {
    double heightInMeters = heightInCm / 100;
    double minWeight = 18.5 * (heightInMeters * heightInMeters);
    double maxWeight = 24.9 * (heightInMeters * heightInMeters);

    return {
      'minWeight': double.parse(minWeight.toStringAsFixed(1)),
      'maxWeight': double.parse(maxWeight.toStringAsFixed(1)),
    };
  }

  // ২. BMR
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
  }) {
    if (gender.toLowerCase() == 'male') {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }

  // ৩. TDEE (Daily Calorie)
  static double calculateTDEE(double bmr, String activityLevel) {
    switch (activityLevel) {
      case 'Sedentary':
        return bmr * 1.2;
      case 'Lightly Active':
        return bmr * 1.375;
      case 'Moderately Active':
        return bmr * 1.55;
      case 'Very Active':
        return bmr * 1.725;
      default:
        return bmr * 1.2;
    }
  }
}