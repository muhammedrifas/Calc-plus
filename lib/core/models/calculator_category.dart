enum CalculatorCategory {
  everyday('Basic & Everyday'),
  finance('Finance & Wealth'),
  health('Health & Fitness'),
  developer('Developer Tools'),
  construction('Construction & DIY');

  final String displayName;
  const CalculatorCategory(this.displayName);
}