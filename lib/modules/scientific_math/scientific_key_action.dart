enum SciKeyType {
  number,
  operator,
  action,
  function,
  equals,
}

enum SciKeyAction {
  // Navigation & Modes
  toggleInverse,
  toggleAngleUnit,

  // Functions
  sin, cos, tan,
  asin, acos, atan,
  sinh, cosh, tanh,
  ln, log,
  sqrt, cbrt,
  reciprocal,
  square, cube, power,
  expPower, tenPower,
  factorial,
  abs,
  random,

  // Constants
  pi, e,

  // Numpad & Editing
  digit0, digit1, digit2, digit3, digit4,
  digit5, digit6, digit7, digit8, digit9,
  decimal,
  clearAll,
  backspace,
  toggleSign,
  parentheses,
  percent,

  // Operators
  add, subtract, multiply, divide,
  calculate,
}

class SciKeyDef {
  final SciKeyAction action;
  final String label;
  final SciKeyType type;
  final int flex;

  const SciKeyDef({
    required this.action,
    required this.label,
    required this.type,
    this.flex = 1,
  });
}