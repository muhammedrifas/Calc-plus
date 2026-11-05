import 'package:flutter/material.dart';
import 'calculator_category.dart';

abstract class CalculatorModule {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final CalculatorCategory category;
  final Color primaryColor;

  const CalculatorModule({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.primaryColor,
  });

  /// Every calculator module must provide its own UI implementation.
  /// The dashboard shell will call this method when a user taps the module's card.
  Widget buildUI(BuildContext context);
}