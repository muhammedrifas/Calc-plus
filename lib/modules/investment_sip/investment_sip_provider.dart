import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum InvestmentMode { sip, lumpSum }

class YearlyProjectionRow {
  final int year;
  final double investedAmount;
  final double futureValue;
  final double inflationAdjustedValue;

  const YearlyProjectionRow({
    required this.year,
    required this.investedAmount,
    required this.futureValue,
    required this.inflationAdjustedValue,
  });
}

class InvestmentSipState {
  final InvestmentMode mode;
  final double investmentAmount; // Monthly if SIP, One-Time if Lump Sum
  final double annualReturnRate; // CAGR (%)
  final int tenureYears;
  final bool adjustForInflation;
  final double annualInflationRate; // (%)

  const InvestmentSipState({
    this.mode = InvestmentMode.sip,
    this.investmentAmount = 10000,
    this.annualReturnRate = 12.0,
    this.tenureYears = 15,
    this.adjustForInflation = false,
    this.annualInflationRate = 6.0,
  });

  double get totalInvested {
    if (mode == InvestmentMode.lumpSum) {
      return investmentAmount;
    } else {
      return investmentAmount * (tenureYears * 12);
    }
  }

  double get maturityValue {
    if (investmentAmount <= 0 || tenureYears <= 0) return 0;
    final r = annualReturnRate / 100;

    if (mode == InvestmentMode.lumpSum) {
      // Lump Sum: FV = P * (1 + r)^t
      return investmentAmount * math.pow(1 + r, tenureYears);
    } else {
      // SIP Monthly Compounding Formula:
      // FV = P * [((1 + i)^n - 1) / i] * (1 + i)
      if (annualReturnRate == 0) return totalInvested;
      final i = r / 12;
      final n = tenureYears * 12;
      return investmentAmount * ((math.pow(1 + i, n) - 1) / i) * (1 + i);
    }
  }

  double get inflationAdjustedMaturity {
    if (!adjustForInflation || annualInflationRate <= 0) return maturityValue;
    // Real Purchasing Value = Nominal FV / (1 + inflation)^t
    final inf = annualInflationRate / 100;
    return maturityValue / math.pow(1 + inf, tenureYears);
  }

  double get estimatedGain {
    return math.max(0, maturityValue - totalInvested);
  }

  double get investedRatio => maturityValue > 0 ? (totalInvested / maturityValue).clamp(0.0, 1.0) : 1.0;
  double get gainRatio => maturityValue > 0 ? (estimatedGain / maturityValue).clamp(0.0, 1.0) : 0.0;

  List<YearlyProjectionRow> get yearlyProjections {
    final rows = <YearlyProjectionRow>[];
    final r = annualReturnRate / 100;
    final i = r / 12;
    final inf = annualInflationRate / 100;

    for (int yr = 1; yr <= tenureYears; yr++) {
      double invested;
      double fv;

      if (mode == InvestmentMode.lumpSum) {
        invested = investmentAmount;
        fv = investmentAmount * math.pow(1 + r, yr);
      } else {
        invested = investmentAmount * (yr * 12);
        if (annualReturnRate == 0) {
          fv = invested;
        } else {
          final n = yr * 12;
          fv = investmentAmount * ((math.pow(1 + i, n) - 1) / i) * (1 + i);
        }
      }

      final realFv = fv / math.pow(1 + inf, yr);

      rows.add(YearlyProjectionRow(
        year: yr,
        investedAmount: invested,
        futureValue: fv,
        inflationAdjustedValue: realFv,
      ));
    }
    return rows;
  }

  InvestmentSipState copyWith({
    InvestmentMode? mode,
    double? investmentAmount,
    double? annualReturnRate,
    int? tenureYears,
    bool? adjustForInflation,
    double? annualInflationRate,
  }) {
    return InvestmentSipState(
      mode: mode ?? this.mode,
      investmentAmount: investmentAmount ?? this.investmentAmount,
      annualReturnRate: annualReturnRate ?? this.annualReturnRate,
      tenureYears: tenureYears ?? this.tenureYears,
      adjustForInflation: adjustForInflation ?? this.adjustForInflation,
      annualInflationRate: annualInflationRate ?? this.annualInflationRate,
    );
  }
}

final investmentSipProvider = StateNotifierProvider.autoDispose<InvestmentSipNotifier, InvestmentSipState>((ref) {
  return InvestmentSipNotifier();
});

class InvestmentSipNotifier extends StateNotifier<InvestmentSipState> {
  InvestmentSipNotifier() : super(const InvestmentSipState());

  void setMode(InvestmentMode mode) => state = state.copyWith(mode: mode);
  void setInvestmentAmount(double val) => state = state.copyWith(investmentAmount: val);
  void setAnnualReturnRate(double val) => state = state.copyWith(annualReturnRate: val);
  void setTenureYears(int val) => state = state.copyWith(tenureYears: val);
  void toggleInflationAdjustment(bool val) => state = state.copyWith(adjustForInflation: val);
  void setInflationRate(double val) => state = state.copyWith(annualInflationRate: val);
}