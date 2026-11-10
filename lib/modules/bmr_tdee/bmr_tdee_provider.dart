import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum BmrSex { male, female }

enum ActivityLevel {
  sedentary('Sedentary', 'Little or no exercise, desk job', 1.2),
  lightlyActive('Light Exercise', 'Sports/exercise 1-3 days/week', 1.375),
  moderatelyActive('Moderate Exercise', 'Sports/exercise 3-5 days/week', 1.55),
  veryActive('Heavy Exercise', 'Hard sports/exercise 6-7 days/week', 1.725),
  extraActive('Athlete / Physical Job', 'Endurance training or 2x/day', 1.9);

  final String title;
  final String subtitle;
  final double multiplier;
  const ActivityLevel(this.title, this.subtitle, this.multiplier);
}

class BmrTdeeState {
  final BmrSex sex;
  final int age;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activityLevel;

  const BmrTdeeState({
    this.sex = BmrSex.male,
    this.age = 26,
    this.heightCm = 175.0,
    this.weightKg = 72.0,
    this.activityLevel = ActivityLevel.moderatelyActive,
  });

  // Mifflin-St Jeor Equation:
  // Men: BMR = (10 * weight in kg) + (6.25 * height in cm) - (5 * age in years) + 5
  // Women: BMR = (10 * weight in kg) + (6.25 * height in cm) - (5 * age in years) - 161
  double get bmr {
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    return sex == BmrSex.male ? base + 5 : base - 161;
  }

  double get tdee => bmr * activityLevel.multiplier;

  // Weight Management Targets
  double get mildWeightLoss => tdee - 250; // ~0.25 kg/week loss
  double get weightLoss => tdee - 500; // ~0.50 kg/week loss
  double get extremeWeightLoss => tdee - 1000; // ~1.00 kg/week loss
  double get mildWeightGain => tdee + 250; // ~0.25 kg/week gain
  double get weightGain => tdee + 500; // ~0.50 kg/week gain

  BmrTdeeState copyWith({
    BmrSex? sex,
    int? age,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
  }) {
    return BmrTdeeState(
      sex: sex ?? this.sex,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }
}

final bmrTdeeProvider =
    StateNotifierProvider.autoDispose<BmrTdeeNotifier, BmrTdeeState>((ref) {
  return BmrTdeeNotifier();
});

class BmrTdeeNotifier extends StateNotifier<BmrTdeeState> {
  BmrTdeeNotifier() : super(const BmrTdeeState());

  void setSex(BmrSex sex) => state = state.copyWith(sex: sex);
  void setAge(int age) => state = state.copyWith(age: age);
  void setHeight(double heightCm) => state = state.copyWith(heightCm: heightCm);
  void setWeight(double weightKg) => state = state.copyWith(weightKg: weightKg);
  void setActivityLevel(ActivityLevel level) => state = state.copyWith(activityLevel: level);
}