// ignore: unused_import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:math_expressions/math_expressions.dart';

class BasicMathState {
  final String equation;
  final String result;
  final List<String> history;

  const BasicMathState({
    this.equation = '0',
    this.result = '',
    this.history = const [],
  });

  BasicMathState copyWith({
    String? equation,
    String? result,
    List<String>? history,
  }) {
    return BasicMathState(
      equation: equation ?? this.equation,
      result: result ?? this.result,
      history: history ?? this.history,
    );
  }
}

final basicMathProvider = StateNotifierProvider.autoDispose<BasicMathNotifier, BasicMathState>((ref) {
  return BasicMathNotifier();
});

class BasicMathNotifier extends StateNotifier<BasicMathState> {
  BasicMathNotifier() : super(const BasicMathState());

  bool _isOperator(String c) => c == '+' || c == '-' || c == '×' || c == '÷';

  void onButtonPressed(String buttonText) {
    if (buttonText == 'AC') {
      state = state.copyWith(equation: '0', result: '');
      return;
    }

    if (buttonText == '⌫') {
      if (state.equation.length > 1) {
        state = state.copyWith(equation: state.equation.substring(0, state.equation.length - 1));
        _calculateResult(live: true);
      } else {
        state = state.copyWith(equation: '0', result: '');
      }
      return;
    }

    if (buttonText == '+/-') {
      _toggleSign();
      return;
    }

    if (buttonText == '( )') {
      _insertSmartParenthesis();
      return;
    }

    if (buttonText == '=') {
      _calculateResult(live: false);
      return;
    }

    String eq = state.equation;

    if (buttonText == '%') {
      if (eq.isNotEmpty && !_isOperator(eq[eq.length - 1]) && eq[eq.length - 1] != '(') {
        state = state.copyWith(equation: '$eq%');
        _calculateResult(live: true);
      }
      return;
    }

    if (_isOperator(buttonText)) {
      if (eq.isEmpty) return;
      if (_isOperator(eq[eq.length - 1])) {
        eq = eq.substring(0, eq.length - 1) + buttonText;
      } else {
        eq += buttonText;
      }
    } else {
      if (eq == '0' && buttonText != '.') {
        eq = buttonText;
      } else {
        eq += buttonText;
      }
    }

    state = state.copyWith(equation: eq);
    if (!_isOperator(buttonText)) {
      _calculateResult(live: true);
    }
  }

  void _insertSmartParenthesis() {
    String eq = state.equation;
    int openCount = 0;
    int closeCount = 0;

    for (int i = 0; i < eq.length; i++) {
      if (eq[i] == '(') openCount++;
      if (eq[i] == ')') closeCount++;
    }

    if (eq == '0') {
      state = state.copyWith(equation: '(');
      return;
    }

    String lastChar = eq[eq.length - 1];

    // If there is an open bracket left to match and the last char is a number or close bracket
    if (openCount > closeCount && (RegExp(r'[0-9%]').hasMatch(lastChar) || lastChar == ')')) {
      state = state.copyWith(equation: '$eq)');
    } else if (_isOperator(lastChar) || lastChar == '(') {
      state = state.copyWith(equation: '$eq(');
    } else {
      // If after a number without operator, insert implicit multiplication: "5("
      state = state.copyWith(equation: '$eq×(');
    }
    _calculateResult(live: true);
  }

  void _toggleSign() {
    String eq = state.equation;
    if (eq == '0') return;

    // Find the boundary of the last number
    final match = RegExp(r'(\(?-?\d+\.?\d*\)?)$').firstMatch(eq);
    if (match != null) {
      String target = match.group(0)!;
      String replacement;
      if (target.startsWith('(-') && target.endsWith(')')) {
        replacement = target.substring(2, target.length - 1);
      } else if (target.startsWith('-')) {
        replacement = target.substring(1);
      } else {
        replacement = '(-$target)';
      }
      state = state.copyWith(equation: eq.substring(0, match.start) + replacement);
      _calculateResult(live: true);
    }
  }

  void _calculateResult({required bool live}) {
    try {
      String finalEquation = state.equation;

      // 1. Business Logic Percentage: A + B% => A + (A * (B/100))
      final percentRegex = RegExp(r'(\d+(?:\.\d+)?)([\+\-])(\d+(?:\.\d+)?)%');
      finalEquation = finalEquation.replaceAllMapped(percentRegex, (match) {
        String base = match.group(1)!;
        String op = match.group(2)!;
        String pct = match.group(3)!;
        return '$base$op($base*($pct/100))';
      });

      // 2. Standalone percentage (e.g., 50 * 10% or just 20%)
      finalEquation = finalEquation.replaceAllMapped(RegExp(r'(\d+(?:\.\d+)?)%'), (match) {
        return '(${match.group(1)}/100)';
      });

      // 3. Operators & Parentheses conversion
      finalEquation = finalEquation.replaceAll('×', '*').replaceAll('÷', '/');

      // Balance unmatched parentheses so AST parser doesn't crash during live typing
      int openBrackets = finalEquation.split('(').length - 1;
      int closeBrackets = finalEquation.split(')').length - 1;
      while (openBrackets > closeBrackets) {
        finalEquation += ')';
        closeBrackets++;
      }

      if (_isOperator(finalEquation[finalEquation.length - 1])) {
        if (live) return;
        finalEquation = finalEquation.substring(0, finalEquation.length - 1);
      }

      Parser p = Parser();
      Expression exp = p.parse(finalEquation);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval.isNaN || eval.isInfinite) {
        if (!live) state = state.copyWith(result: 'Error');
        return;
      }

      String evalResult = eval.toString();
      if (evalResult.endsWith('.0')) {
        evalResult = evalResult.substring(0, evalResult.length - 2);
      }

      if (live) {
        state = state.copyWith(result: evalResult);
      } else {
        final newHistory = List<String>.from(state.history)..insert(0, '${state.equation} = $evalResult');
        state = state.copyWith(equation: evalResult, result: '', history: newHistory);
      }
    } catch (_) {
      if (!live) state = state.copyWith(result: 'Error');
    }
  }
}