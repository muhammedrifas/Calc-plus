import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:omni_calc/modules/scientific_math/scientific_key_action.dart';

class ScientificMathState {
  final String equation;
  final String result;
  final List<String> history;
  final bool isRadians;
  final bool isInverse;

  const ScientificMathState({
    this.equation = '0',
    this.result = '',
    this.history = const [],
    this.isRadians = true,
    this.isInverse = false,
  });

  String get displayEquation => _toSuperscriptDisplay(equation);

  ScientificMathState copyWith({
    String? equation,
    String? result,
    List<String>? history,
    bool? isRadians,
    bool? isInverse,
  }) {
    return ScientificMathState(
      equation: equation ?? this.equation,
      result: result ?? this.result,
      history: history ?? this.history,
      isRadians: isRadians ?? this.isRadians,
      isInverse: isInverse ?? this.isInverse,
    );
  }

  static String _toSuperscriptDisplay(String text) {
    const superscriptMap = {
      '0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴',
      '5': '⁵', '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹',
      '+': '⁺', '-': '⁻', '(': '⁽', ')': '⁾', 'n': 'ⁿ',
      'x': 'ˣ', 'y': 'ʸ',
    };

    String formatted = text.replaceAllMapped(RegExp(r'\^(\([^)]*\)|\d+)'), (match) {
      String rawExp = match.group(1)!;
      if (rawExp.startsWith('(') && rawExp.endsWith(')')) {
        rawExp = rawExp.substring(1, rawExp.length - 1);
      }
      return rawExp.split('').map((c) => superscriptMap[c] ?? c).join();
    });

    if (formatted.endsWith('^')) {
      formatted = '${formatted.substring(0, formatted.length - 1)}ʸ';
    }

    return formatted;
  }
}

final scientificMathProvider = StateNotifierProvider.autoDispose<ScientificMathNotifier, ScientificMathState>((ref) {
  return ScientificMathNotifier();
});

class ScientificMathNotifier extends StateNotifier<ScientificMathState> {
  ScientificMathNotifier() : super(const ScientificMathState());

  bool _isOperator(String c) => c == '+' || c == '-' || c == '×' || c == '÷' || c == '^';

  static final List<String> _atomicTokens = [
    'asin(', 'acos(', 'atan(',
    'sinh(', 'cosh(', 'tanh(',
    'sqrt(', 'cbrt(', 'abs(',
    'sin(', 'cos(', 'tan(',
    'log(', 'ln(',
    '10^(', 'e^(',
    '^(-1)', '^2', '^3',
  ];

  bool get _canApplyPower {
    if (state.equation.isEmpty || state.equation == '0') return false;
    final lastChar = state.equation[state.equation.length - 1];
    return RegExp(r'[0-9πe!\)%]').hasMatch(lastChar);
  }

  void toggleRadDeg() {
    state = state.copyWith(isRadians: !state.isRadians);
    _calculateResult(live: true);
  }

  void toggleInverse() {
    state = state.copyWith(isInverse: !state.isInverse);
  }

  void onAction(SciKeyAction action) {
    switch (action) {
      case SciKeyAction.toggleInverse:
        toggleInverse();
        break;
      case SciKeyAction.toggleAngleUnit:
        toggleRadDeg();
        break;
      case SciKeyAction.clearAll:
        state = state.copyWith(equation: '0', result: '');
        break;
      case SciKeyAction.backspace:
        _handleBackspace();
        break;
      case SciKeyAction.calculate:
        _calculateResult(live: false);
        break;
      case SciKeyAction.parentheses:
        _insertSmartParenthesis();
        break;
      case SciKeyAction.toggleSign:
        _toggleSign();
        break;
      case SciKeyAction.percent:
        _appendPercent();
        break;

      // Digits & Dot
      case SciKeyAction.digit0: _appendChar('0'); break;
      case SciKeyAction.digit1: _appendChar('1'); break;
      case SciKeyAction.digit2: _appendChar('2'); break;
      case SciKeyAction.digit3: _appendChar('3'); break;
      case SciKeyAction.digit4: _appendChar('4'); break;
      case SciKeyAction.digit5: _appendChar('5'); break;
      case SciKeyAction.digit6: _appendChar('6'); break;
      case SciKeyAction.digit7: _appendChar('7'); break;
      case SciKeyAction.digit8: _appendChar('8'); break;
      case SciKeyAction.digit9: _appendChar('9'); break;
      case SciKeyAction.decimal: _appendChar('.'); break;

      // Operators
      case SciKeyAction.add: _appendOperator('+'); break;
      case SciKeyAction.subtract: _appendOperator('-'); break;
      case SciKeyAction.multiply: _appendOperator('×'); break;
      case SciKeyAction.divide: _appendOperator('÷'); break;

      // Constants
      case SciKeyAction.pi: _appendFunctionToken('π'); break;
      case SciKeyAction.e: _appendFunctionToken('e'); break;

      // Functions
      case SciKeyAction.sin: _appendFunctionCall('sin'); break;
      case SciKeyAction.cos: _appendFunctionCall('cos'); break;
      case SciKeyAction.tan: _appendFunctionCall('tan'); break;
      case SciKeyAction.asin: _appendFunctionCall('asin'); break;
      case SciKeyAction.acos: _appendFunctionCall('acos'); break;
      case SciKeyAction.atan: _appendFunctionCall('atan'); break;
      case SciKeyAction.sinh: _appendFunctionCall('sinh'); break;
      case SciKeyAction.cosh: _appendFunctionCall('cosh'); break;
      case SciKeyAction.tanh: _appendFunctionCall('tanh'); break;
      case SciKeyAction.ln: _appendFunctionCall('ln'); break;
      case SciKeyAction.log: _appendFunctionCall('log'); break;
      case SciKeyAction.sqrt: _appendFunctionCall('sqrt'); break;
      case SciKeyAction.cbrt: _appendFunctionCall('cbrt'); break;
      case SciKeyAction.abs: _appendFunctionCall('abs'); break;

      case SciKeyAction.random:
        final r = math.Random().nextDouble().toStringAsFixed(4);
        _appendChar(r);
        break;

      // Powers & Exponents (Protected with valid base validation & bracket chaining)
      case SciKeyAction.reciprocal:
        if (_canApplyPower) {
          _applyExponent('^(-1)');
        }
        break;
      case SciKeyAction.square:
        if (_canApplyPower) {
          _applyExponent('^2');
        }
        break;
      case SciKeyAction.cube:
        if (_canApplyPower) {
          _applyExponent('^3');
        }
        break;
      case SciKeyAction.power:
        if (_canApplyPower) {
          state = state.copyWith(equation: '${state.equation}^(');
        }
        break;
      case SciKeyAction.expPower:
        state = state.copyWith(equation: state.equation == '0' ? 'e^(' : '${state.equation}×e^(');
        break;
      case SciKeyAction.tenPower:
        state = state.copyWith(equation: state.equation == '0' ? '10^(' : '${state.equation}×10^(');
        break;
      case SciKeyAction.factorial:
        if (_canApplyPower) {
          state = state.copyWith(equation: '${state.equation}!');
          _calculateResult(live: true);
        }
        break;
    }
  }

  void _applyExponent(String expSuffix) {
    String eq = state.equation;

    // If an exponent already exists at the end (e.g. 5^2), wrap in parentheses: (5^2)^2
    if (eq.endsWith('^2') || eq.endsWith('^3') || eq.endsWith('^(-1)') || RegExp(r'\^\([^)]+\)$').hasMatch(eq)) {
      eq = '($eq)$expSuffix';
    } else {
      eq = '$eq$expSuffix';
    }

    state = state.copyWith(equation: eq);
    _calculateResult(live: true);
  }

  void _appendChar(String c) {
    String eq = state.equation;
    if (eq == '0' && c != '.') {
      eq = c;
    } else {
      eq += c;
    }
    state = state.copyWith(equation: eq);
    _calculateResult(live: true);
  }

  void _appendOperator(String op) {
    String eq = state.equation;
    if (eq.isEmpty) return;
    if (_isOperator(eq[eq.length - 1])) {
      eq = eq.substring(0, eq.length - 1) + op;
    } else {
      eq += op;
    }
    state = state.copyWith(equation: eq);
  }

  void _appendPercent() {
    String eq = state.equation;
    if (eq.isNotEmpty && !_isOperator(eq[eq.length - 1])) {
      state = state.copyWith(equation: '$eq%');
      _calculateResult(live: true);
    }
  }

  void _appendFunctionCall(String fn) {
    String eq = state.equation;

    // 1. Initial/empty state: start fresh with fn(
    if (eq == '0' || eq.isEmpty) {
      state = state.copyWith(equation: '$fn(');
      _calculateResult(live: true);
      return;
    }

    String lastChar = eq[eq.length - 1];

    // 2. Trailing operator or open bracket: append directly without multiplication
    if (_isOperator(lastChar) || lastChar == '(') {
      state = state.copyWith(equation: '$eq$fn(');
      _calculateResult(live: true);
      return;
    }

    // 3. Trailing closed bracket: wrap the entire matched parenthetical group
    if (lastChar == ')') {
      int depth = 0;
      int matchIndex = -1;
      for (int i = eq.length - 1; i >= 0; i--) {
        if (eq[i] == ')') depth++;
        if (eq[i] == '(') {
          depth--;
          if (depth == 0) {
            matchIndex = i;
            break;
          }
        }
      }

      if (matchIndex != -1) {
        // Check if there was already an outer function attached, e.g. "sin(5)" -> wrap "sin(5)"
        int fnPrefixStart = matchIndex;
        while (fnPrefixStart > 0 && RegExp(r'[a-zA-Z]').hasMatch(eq[fnPrefixStart - 1])) {
          fnPrefixStart--;
        }

        String target = eq.substring(fnPrefixStart);
        String prefix = eq.substring(0, fnPrefixStart);
        state = state.copyWith(equation: '$prefix$fn($target)');
        _calculateResult(live: true);
        return;
      }
    }

    // 4. Trailing number or constant: wrap the last operand
    // Matches trailing decimal numbers, constants (π, e), factorials, or percentages
    final trailingOperandRegex = RegExp(r'([0-9πe.%!]+)$');
    final match = trailingOperandRegex.firstMatch(eq);

    if (match != null) {
      String target = match.group(1)!;
      String prefix = eq.substring(0, match.start);
      state = state.copyWith(equation: '$prefix$fn($target)');
      _calculateResult(live: true);
      return;
    }

    // Fallback: append fn(
    state = state.copyWith(equation: '$eq$fn(');
    _calculateResult(live: true);
  }

  void _appendFunctionToken(String token) {
    String eq = state.equation;
    if (eq == '0') {
      eq = token;
    } else if (RegExp(r'[0-9πe)]$').hasMatch(eq)) {
      eq = '$eq×$token';
    } else {
      eq = '$eq$token';
    }
    state = state.copyWith(equation: eq);
    _calculateResult(live: true);
  }

  void _handleBackspace() {
    String eq = state.equation;
    if (eq.isEmpty || eq == '0') {
      state = state.copyWith(equation: '0', result: '');
      return;
    }

    for (final token in _atomicTokens) {
      if (eq.endsWith(token)) {
        eq = eq.substring(0, eq.length - token.length);
        if (eq.isEmpty) eq = '0';
        state = state.copyWith(equation: eq);
        _calculateResult(live: true);
        return;
      }
    }

    if (eq.length > 1) {
      eq = eq.substring(0, eq.length - 1);
    } else {
      eq = '0';
    }

    state = state.copyWith(equation: eq);
    _calculateResult(live: true);
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
    if (openCount > closeCount && (RegExp(r'[0-9%πe!]').hasMatch(lastChar) || lastChar == ')')) {
      state = state.copyWith(equation: '$eq)');
    } else if (_isOperator(lastChar) || lastChar == '(') {
      state = state.copyWith(equation: '$eq(');
    } else {
      state = state.copyWith(equation: '$eq×(');
    }
    _calculateResult(live: true);
  }

  void _toggleSign() {
    String eq = state.equation;
    if (eq == '0') return;

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
      final evalResult = evaluateExpression(state.equation, isRadians: state.isRadians);
      if (evalResult == 'Error') {
        if (!live) state = state.copyWith(result: 'Error');
        return;
      }

      if (live) {
        state = state.copyWith(result: evalResult);
      } else {
        final newHistory = List<String>.from(state.history)..insert(0, '${state.displayEquation} = $evalResult');
        state = state.copyWith(equation: evalResult, result: '', history: newHistory);
      }
    } catch (_) {
      if (!live) state = state.copyWith(result: 'Error');
    }
  }

  static String evaluateExpression(String input, {required bool isRadians}) {
    try {
      String eq = input;

      final factRegex = RegExp(r'(\d+)!');
      eq = eq.replaceAllMapped(factRegex, (match) {
        int n = int.parse(match.group(1)!);
        return _factorial(n).toString();
      });

      final percentRegex = RegExp(r'(\d+(?:\.\d+)?)([\+\-])(\d+(?:\.\d+)?)%');
      eq = eq.replaceAllMapped(percentRegex, (match) {
        String base = match.group(1)!;
        String op = match.group(2)!;
        String pct = match.group(3)!;
        return '$base$op($base*($pct/100))';
      });

      eq = eq.replaceAllMapped(RegExp(r'(\d+(?:\.\d+)?)%'), (match) {
        return '(${match.group(1)}/100)';
      });

      eq = eq.replaceAll('π', '${math.pi}').replaceAll('e', '${math.e}');

      eq = _expandFunction(eq, 'abs', (arg) => '(abs($arg))');
      eq = _expandFunction(eq, 'sinh', (arg) => '((e^($arg) - e^(-($arg))) / 2)');
      eq = _expandFunction(eq, 'cosh', (arg) => '((e^($arg) + e^(-($arg))) / 2)');
      eq = _expandFunction(eq, 'tanh', (arg) => '((e^($arg) - e^(-($arg))) / (e^($arg) + e^(-($arg))))');

      if (!isRadians) {
        eq = _expandFunction(eq, 'asin', (arg) => '(arcsin($arg) * 180 / ${math.pi})');
        eq = _expandFunction(eq, 'acos', (arg) => '(arccos($arg) * 180 / ${math.pi})');
        eq = _expandFunction(eq, 'atan', (arg) => '(arctan($arg) * 180 / ${math.pi})');
      } else {
        eq = eq.replaceAll('asin(', 'arcsin(')
               .replaceAll('acos(', 'arccos(')
               .replaceAll('atan(', 'arctan(');
      }

      if (!isRadians) {
        eq = _expandFunctionByPattern(eq, RegExp(r'(?<!arc)(sin|cos|tan)'), (fn, arg) {
          return '$fn(($arg) * ${math.pi} / 180)';
        });
      }

      eq = eq
          .replaceAll('log(', 'log(10, ')
          .replaceAll('cbrt(', 'nrt(3, ')
          .replaceAll('×', '*')
          .replaceAll('÷', '/');

      int openBrackets = eq.split('(').length - 1;
      int closeBrackets = eq.split(')').length - 1;
      while (openBrackets > closeBrackets) {
        eq += ')';
        closeBrackets++;
      }

      if (eq.endsWith('+') || eq.endsWith('-') || eq.endsWith('*') || eq.endsWith('/') || eq.endsWith('^')) {
        eq = eq.substring(0, eq.length - 1);
      }

      Parser p = Parser();
      Expression exp = p.parse(eq);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval.isNaN || eval.isInfinite) return 'Error';
      if (eval.abs() < 1e-12) eval = 0.0;

      String evalResult = eval.toStringAsPrecision(10);
      evalResult = double.parse(evalResult).toString();
      if (evalResult.endsWith('.0')) {
        evalResult = evalResult.substring(0, evalResult.length - 2);
      }

      return evalResult;
    } catch (_) {
      return 'Error';
    }
  }

  static String _expandFunction(String text, String fnName, String Function(String arg) replacer) {
    String pattern = '$fnName(';
    int index = text.indexOf(pattern);
    while (index != -1) {
      int start = index + pattern.length;
      int depth = 1;
      int end = start;
      while (end < text.length && depth > 0) {
        if (text[end] == '(') depth++;
        if (text[end] == ')') depth--;
        end++;
      }
      String arg = text.substring(start, end - (depth == 0 ? 1 : 0));
      String replacement = replacer(arg);
      text = text.substring(0, index) + replacement + text.substring(end);
      index = text.indexOf(pattern, index + replacement.length);
    }
    return text;
  }

  static String _expandFunctionByPattern(
      String text, RegExp pattern, String Function(String fn, String arg) replacer) {
    Match? match = pattern.firstMatch(text);
    while (match != null) {
      String fn = match.group(0)!;
      int start = match.end;
      if (start < text.length && text[start] == '(') {
        start++;
        int depth = 1;
        int end = start;
        while (end < text.length && depth > 0) {
          if (text[end] == '(') depth++;
          if (text[end] == ')') depth--;
          end++;
        }
        String arg = text.substring(start, end - (depth == 0 ? 1 : 0));
        String replacement = replacer(fn, arg);
        text = text.substring(0, match.start) + replacement + text.substring(end);
        match = pattern.firstMatch(text.substring(match.start + replacement.length));
      } else {
        break;
      }
    }
    return text;
  }

  static double _factorial(int n) {
    if (n < 0) return double.nan;
    if (n == 0 || n == 1) return 1.0;
    double res = 1.0;
    for (int i = 2; i <= n; i++) {
      res *= i;
    }
    return res;
  }
}