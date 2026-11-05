import 'package:flutter/material.dart';
import '../core/models/calculator_module.dart';
import '../core/models/calculator_category.dart';

class BasicMathModule extends CalculatorModule {
  const BasicMathModule()
      : super(
          id: 'basic_math',
          name: 'Basic Math',
          description: 'Standard arithmetic and equations',
          icon: Icons.calculate,
          category: CalculatorCategory.everyday,
          primaryColor: Colors.tealAccent,
        );

  @override
  Widget buildUI(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: const Center(
        child: Text('Modular Calculator Engine Running...'),
      ),
    );
  }
}