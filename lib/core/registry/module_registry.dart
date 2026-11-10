import 'package:omni_calc/core/models/calculator_module.dart';
import 'package:omni_calc/core/models/calculator_category.dart';
import 'package:omni_calc/modules/basic_math/basic_math_module.dart';
import 'package:omni_calc/modules/scientific_math/scientific_math_module.dart';
import 'package:omni_calc/modules/loan_emi/loan_emi_module.dart';
import 'package:omni_calc/modules/investment_sip/investment_sip_module.dart';
import 'package:omni_calc/modules/unit_converter/unit_converter_module.dart';
import 'package:omni_calc/modules/date_time_interval/date_time_interval_module.dart'; 
import 'package:omni_calc/modules/fuel_cost/fuel_cost_module.dart';
import 'package:omni_calc/modules/round_robin/round_robin_module.dart';
import 'package:omni_calc/modules/bmi_ibw/bmi_ibw_module.dart';
import 'package:omni_calc/modules/bmr_tdee/bmr_tdee_module.dart';

class ModuleRegistry {
  static final List<CalculatorModule> allModules = [
    const BasicMathModule(),
    const ScientificMathModule(),
    const LoanEmiModule(),
    const InvestmentSipModule(),
    const UnitConverterModule(),
    const DateTimeIntervalModule(),
    const FuelCostModule(),
    const RoundRobinModule(),
    const BmiIbwModule(),
    const BmrTdeeModule(),
  ];

  static Map<CalculatorCategory, List<CalculatorModule>> get groupedByCategory {
    final map = <CalculatorCategory, List<CalculatorModule>>{};
    for (var category in CalculatorCategory.values) {
      map[category] = allModules.where((m) => m.category == category).toList();
    }
    return map;
  }

  static List<CalculatorModule> search(String query) {
    if (query.isEmpty) return allModules;
    final lowerQuery = query.toLowerCase();
    return allModules.where((m) => 
      m.name.toLowerCase().contains(lowerQuery) || 
      m.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}