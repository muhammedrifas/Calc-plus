import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum FuelEfficiencyUnit {
  kmPerLiter('km/L', 'km', 'L'),
  mpgUS('MPG (US)', 'mi', 'gal');

  final String label;
  final String distanceUnit;
  final String volumeUnit;
  const FuelEfficiencyUnit(this.label, this.distanceUnit, this.volumeUnit);
}

class FuelCostState {
  final FuelEfficiencyUnit unit;
  final double? distance;
  final double? efficiency;
  final bool isRoundTrip;
  final bool calculateCost;
  final double? fuelPrice;
  final int passengers;

  const FuelCostState({
    this.unit = FuelEfficiencyUnit.kmPerLiter,
    this.distance,
    this.efficiency,
    this.isRoundTrip = false,
    this.calculateCost = true,
    this.fuelPrice,
    this.passengers = 1,
  });

  bool get hasRequiredInputs =>
      distance != null && distance! > 0 && efficiency != null && efficiency! > 0;

  double get effectiveDistance =>
      distance == null ? 0.0 : (isRoundTrip ? distance! * 2 : distance!);

  double? get fuelRequired {
    if (!hasRequiredInputs) return null;
    return effectiveDistance / efficiency!;
  }

  double? get totalFuelCost {
    if (!calculateCost || fuelPrice == null || fuelPrice! <= 0 || fuelRequired == null) {
      return null;
    }
    return fuelRequired! * fuelPrice!;
  }

  double? get costPerPassenger {
    if (totalFuelCost == null || passengers <= 0) return null;
    return totalFuelCost! / passengers;
  }

  double? get costPerDistanceUnit {
    if (totalFuelCost == null || effectiveDistance <= 0) return null;
    return totalFuelCost! / effectiveDistance;
  }

  FuelCostState copyWith({
    FuelEfficiencyUnit? unit,
    double? Function()? distance,
    double? Function()? efficiency,
    bool? isRoundTrip,
    bool? calculateCost,
    double? Function()? fuelPrice,
    int? passengers,
  }) {
    return FuelCostState(
      unit: unit ?? this.unit,
      distance: distance != null ? distance() : this.distance,
      efficiency: efficiency != null ? efficiency() : this.efficiency,
      isRoundTrip: isRoundTrip ?? this.isRoundTrip,
      calculateCost: calculateCost ?? this.calculateCost,
      fuelPrice: fuelPrice != null ? fuelPrice() : this.fuelPrice,
      passengers: passengers ?? this.passengers,
    );
  }
}

final fuelCostProvider =
    StateNotifierProvider.autoDispose<FuelCostNotifier, FuelCostState>((ref) {
  return FuelCostNotifier();
});

class FuelCostNotifier extends StateNotifier<FuelCostState> {
  FuelCostNotifier() : super(const FuelCostState());

  void setUnit(FuelEfficiencyUnit unit) {
    if (unit == state.unit) return;

    if (unit == FuelEfficiencyUnit.mpgUS) {
      // km -> miles, km/L -> MPG, per L -> per gal
      state = state.copyWith(
        unit: unit,
        distance: () => state.distance != null ? state.distance! * 0.621371 : null,
        efficiency: () => state.efficiency != null ? state.efficiency! * 2.35215 : null,
        fuelPrice: () => state.fuelPrice != null ? state.fuelPrice! * 3.78541 : null,
      );
    } else {
      // miles -> km, MPG -> km/L, per gal -> per L
      state = state.copyWith(
        unit: unit,
        distance: () => state.distance != null ? state.distance! / 0.621371 : null,
        efficiency: () => state.efficiency != null ? state.efficiency! / 2.35215 : null,
        fuelPrice: () => state.fuelPrice != null ? state.fuelPrice! / 3.78541 : null,
      );
    }
  }

  void setDistance(double? val) => state = state.copyWith(distance: () => val);
  void setEfficiency(double? val) => state = state.copyWith(efficiency: () => val);
  void toggleRoundTrip(bool val) => state = state.copyWith(isRoundTrip: val);
  void toggleCalculateCost(bool val) => state = state.copyWith(calculateCost: val);
  void setFuelPrice(double? val) => state = state.copyWith(fuelPrice: () => val);
  void setPassengers(int val) => state = state.copyWith(passengers: val);
}