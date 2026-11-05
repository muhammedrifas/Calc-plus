import '../models/calculator_module.dart';
import '../models/calculator_category.dart';

class ModuleRegistry {
  /// The master list of all available calculators.
  static final List<CalculatorModule> allModules = [
    // TODO: We will register instances of CalculatorModule here (e.g., BasicMathModule(), EmiModule())
  ];

  /// Helper to render the categorized accordion list on the dashboard
  static Map<CalculatorCategory, List<CalculatorModule>> get groupedByCategory {
    final map = <CalculatorCategory, List<CalculatorModule>>{};
    for (var category in CalculatorCategory.values) {
      map[category] = allModules.where((m) => m.category == category).toList();
    }
    return map;
  }

  /// Helper for universal search filtering
  static List<CalculatorModule> search(String query) {
    if (query.isEmpty) return allModules;
    final lowerQuery = query.toLowerCase();
    return allModules.where((m) => 
      m.name.toLowerCase().contains(lowerQuery) || 
      m.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}