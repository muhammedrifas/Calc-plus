import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'unit_definitions.dart';

class UnitConverterState {
  final UnitCategory category;
  final UnitDef sourceUnit;
  final UnitDef targetUnit;
  final double sourceValue;

  const UnitConverterState({
    required this.category,
    required this.sourceUnit,
    required this.targetUnit,
    this.sourceValue = 1.0,
  });

  double get targetValue {
    final base = sourceUnit.toBase(sourceValue);
    return targetUnit.fromBase(base);
  }

  Map<UnitDef, double> get allCategoryConversions {
    final base = sourceUnit.toBase(sourceValue);
    final map = <UnitDef, double>{};
    for (final unit in UnitRegistry.unitsByCategory[category] ?? <UnitDef>[]) {
      map[unit] = unit.fromBase(base);
    }
    return map;
  }

  UnitConverterState copyWith({
    UnitCategory? category,
    UnitDef? sourceUnit,
    UnitDef? targetUnit,
    double? sourceValue,
  }) {
    return UnitConverterState(
      category: category ?? this.category,
      sourceUnit: sourceUnit ?? this.sourceUnit,
      targetUnit: targetUnit ?? this.targetUnit,
      sourceValue: sourceValue ?? this.sourceValue,
    );
  }
}

final unitConverterProvider = StateNotifierProvider.autoDispose<UnitConverterNotifier, UnitConverterState>((ref) {
  final initialCategory = UnitCategory.length;
  final units = UnitRegistry.unitsByCategory[initialCategory]!;
  return UnitConverterNotifier(
    UnitConverterState(
      category: initialCategory,
      sourceUnit: units[2], // meter
      targetUnit: units[5], // foot
      sourceValue: 1.0,
    ),
  );
});

class UnitConverterNotifier extends StateNotifier<UnitConverterState> {
  UnitConverterNotifier(super.initialState);

  void selectCategory(UnitCategory category) {
    final units = UnitRegistry.unitsByCategory[category]!;
    state = state.copyWith(
      category: category,
      sourceUnit: units[0],
      targetUnit: units.length > 1 ? units[1] : units[0],
      sourceValue: 1.0,
    );
  }

  void setSourceUnit(UnitDef unit) {
    state = state.copyWith(sourceUnit: unit);
  }

  void setTargetUnit(UnitDef unit) {
    state = state.copyWith(targetUnit: unit);
  }

  void setSourceValue(double val) {
    state = state.copyWith(sourceValue: val);
  }

  void setTargetValue(double val) {
    final base = state.targetUnit.toBase(val);
    final newSource = state.sourceUnit.fromBase(base);
    state = state.copyWith(sourceValue: newSource);
  }

  void swapUnits() {
    state = state.copyWith(
      sourceUnit: state.targetUnit,
      targetUnit: state.sourceUnit,
    );
  }
}