import '../models/calculator_module.dart';
import '../models/calculator_category.dart';
import '../../modules/basic_math_module.dart'; // Add this import

class ModuleRegistry {
  static final List<CalculatorModule> allModules = [
    const BasicMathModule(), // Register the module here
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