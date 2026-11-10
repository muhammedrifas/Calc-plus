import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum MeasurementSystem { metric, imperial }
enum BiologicalSex { male, female }

enum BmiCategory {
  severeUnderweight('Severe Underweight', 0, 16.0),
  moderateUnderweight('Moderate Underweight', 16.0, 17.0),
  mildUnderweight('Mild Underweight', 17.0, 18.5),
  normalWeight('Normal (Healthy)', 18.5, 25.0),
  overweight('Overweight (Pre-obese)', 25.0, 30.0),
  obesityClass1('Obese Class I', 30.0, 35.0),
  obesityClass2('Obese Class II', 35.0, 40.0),
  obesityClass3('Obese Class III', 40.0, 100.0);

  final String label;
  final double minBmi;
  final double maxBmi;
  const BmiCategory(this.label, this.minBmi, this.maxBmi);
}

class BmiIbwState {
  final MeasurementSystem system;
  final BiologicalSex sex;
  final double heightCm;
  final double weightKg;

  const BmiIbwState({
    this.system = MeasurementSystem.metric,
    this.sex = BiologicalSex.male,
    this.heightCm = 175.0,
    this.weightKg = 72.0,
  });

  // Display conversions
  double get displayHeight =>
      system == MeasurementSystem.metric ? heightCm : heightCm * 0.393701; // inches
  double get displayWeight =>
      system == MeasurementSystem.metric ? weightKg : weightKg * 2.20462; // lbs

  String get heightUnit => system == MeasurementSystem.metric ? 'cm' : 'in';
  String get weightUnit => system == MeasurementSystem.metric ? 'kg' : 'lbs';

  double get bmi {
    if (heightCm <= 0) return 0;
    final heightMeters = heightCm / 100;
    return weightKg / (heightMeters * heightMeters);
  }

  BmiCategory get category {
    final b = bmi;
    for (final cat in BmiCategory.values) {
      if (b >= cat.minBmi && b < cat.maxBmi) return cat;
    }
    return BmiCategory.obesityClass3;
  }

  // WHO Healthy range (18.5 - 24.9)
  (double, double) get healthyWeightRange {
    final heightMeters = heightCm / 100;
    final minKg = 18.5 * pow(heightMeters, 2);
    final maxKg = 24.9 * pow(heightMeters, 2);

    if (system == MeasurementSystem.metric) {
      return (minKg, maxKg);
    }
    return (minKg * 2.20462, maxKg * 2.20462);
  }

  // Devine Formula (1974)
  // Men: 50.0 kg + 2.3 kg per inch over 5 feet
  // Women: 45.5 kg + 2.3 kg per inch over 5 feet
  double get devineIbw {
    final totalInches = heightCm * 0.393701;
    final inchesOver60 = max(0.0, totalInches - 60.0);
    final base = sex == BiologicalSex.male ? 50.0 : 45.5;
    final kg = base + (2.3 * inchesOver60);
    return system == MeasurementSystem.metric ? kg : kg * 2.20462;
  }

  // Robinson Formula (1983)
  // Men: 52 kg + 1.9 kg per inch over 5 feet
  // Women: 49 kg + 1.7 kg per inch over 5 feet
  double get robinsonIbw {
    final totalInches = heightCm * 0.393701;
    final inchesOver60 = max(0.0, totalInches - 60.0);
    final base = sex == BiologicalSex.male ? 52.0 : 49.0;
    final mult = sex == BiologicalSex.male ? 1.9 : 1.7;
    final kg = base + (mult * inchesOver60);
    return system == MeasurementSystem.metric ? kg : kg * 2.20462;
  }

  BmiIbwState copyWith({
    MeasurementSystem? system,
    BiologicalSex? sex,
    double? heightCm,
    double? weightKg,
  }) {
    return BmiIbwState(
      system: system ?? this.system,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
    );
  }
}

final bmiIbwProvider =
    StateNotifierProvider.autoDispose<BmiIbwNotifier, BmiIbwState>((ref) {
  return BmiIbwNotifier();
});

class BmiIbwNotifier extends StateNotifier<BmiIbwState> {
  BmiIbwNotifier() : super(const BmiIbwState());

  void setSystem(MeasurementSystem system) => state = state.copyWith(system: system);
  void setSex(BiologicalSex sex) => state = state.copyWith(sex: sex);

  void setHeight(double val) {
    final cm = state.system == MeasurementSystem.metric ? val : val / 0.393701;
    state = state.copyWith(heightCm: cm);
  }

  void setWeight(double val) {
    final kg = state.system == MeasurementSystem.metric ? val : val / 2.20462;
    state = state.copyWith(weightKg: kg);
  }
}