import 'dart:math' as math;
// ignore: unused_import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum InterestRateType { reducing, flat }

class AmortizationRow {
  final int month;
  final double principalPaid;
  final double interestPaid;
  final double totalPayment;
  final double remainingBalance;

  const AmortizationRow({
    required this.month,
    required this.principalPaid,
    required this.interestPaid,
    required this.totalPayment,
    required this.remainingBalance,
  });
}

class LoanEmiState {
  final double principal;
  final double annualInterestRate;
  final int tenureYears;
  final InterestRateType rateType;

  const LoanEmiState({
    this.principal = 1000000,
    this.annualInterestRate = 8.5,
    this.tenureYears = 10,
    this.rateType = InterestRateType.reducing,
  });

  int get totalMonths => tenureYears * 12;

  double get monthlyEmi {
    if (principal <= 0 || tenureYears <= 0) return 0;
    if (annualInterestRate <= 0) return principal / totalMonths;

    if (rateType == InterestRateType.flat) {
      // Flat Rate: Total Interest = P * R * T; EMI = (P + Interest) / Months
      final totalInterest = principal * (annualInterestRate / 100) * tenureYears;
      return (principal + totalInterest) / totalMonths;
    } else {
      // Reducing Balance: Standard Amortization Formula
      // EMI = [P * r * (1 + r)^n] / [(1 + r)^n - 1]
      final r = (annualInterestRate / 12) / 100;
      final n = totalMonths;
      final powFactor = math.pow(1 + r, n);
      return (principal * r * powFactor) / (powFactor - 1);
    }
  }

  double get totalPayment => monthlyEmi * totalMonths;
  double get totalInterest => math.max(0, totalPayment - principal);
  double get principalRatio => totalPayment > 0 ? (principal / totalPayment) : 1.0;
  double get interestRatio => totalPayment > 0 ? (totalInterest / totalPayment) : 0.0;

  List<AmortizationRow> get schedule {
    final rows = <AmortizationRow>[];
    if (principal <= 0 || tenureYears <= 0) return rows;

    double balance = principal;
    final r = (annualInterestRate / 12) / 100;
    final emi = monthlyEmi;

    if (rateType == InterestRateType.flat) {
      final monthlyInterest = (principal * (annualInterestRate / 100)) / 12;
      final monthlyPrincipal = principal / totalMonths;

      for (int m = 1; m <= totalMonths; m++) {
        balance = math.max(0, balance - monthlyPrincipal);
        rows.add(AmortizationRow(
          month: m,
          principalPaid: monthlyPrincipal,
          interestPaid: monthlyInterest,
          totalPayment: emi,
          remainingBalance: balance,
        ));
      }
    } else {
      for (int m = 1; m <= totalMonths; m++) {
        final interest = balance * r;
        final principalPart = emi - interest;
        balance = math.max(0, balance - principalPart);

        rows.add(AmortizationRow(
          month: m,
          principalPaid: principalPart,
          interestPaid: interest,
          totalPayment: emi,
          remainingBalance: balance,
        ));
      }
    }
    return rows;
  }

  LoanEmiState copyWith({
    double? principal,
    double? annualInterestRate,
    int? tenureYears,
    InterestRateType? rateType,
  }) {
    return LoanEmiState(
      principal: principal ?? this.principal,
      annualInterestRate: annualInterestRate ?? this.annualInterestRate,
      tenureYears: tenureYears ?? this.tenureYears,
      rateType: rateType ?? this.rateType,
    );
  }
}

final loanEmiProvider = StateNotifierProvider.autoDispose<LoanEmiNotifier, LoanEmiState>((ref) {
  return LoanEmiNotifier();
});

class LoanEmiNotifier extends StateNotifier<LoanEmiState> {
  LoanEmiNotifier() : super(const LoanEmiState());

  void setPrincipal(double value) => state = state.copyWith(principal: value);
  void setInterestRate(double value) => state = state.copyWith(annualInterestRate: value);
  void setTenure(int value) => state = state.copyWith(tenureYears: value);
  void setRateType(InterestRateType type) => state = state.copyWith(rateType: type);
}