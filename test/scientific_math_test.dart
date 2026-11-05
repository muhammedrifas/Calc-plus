import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:omni_calc/modules/scientific_math/scientific_math_provider.dart';

void main() {
  group('Scientific Math Engine Tests', () {
    test('Standard Trigonometry in Radians', () {
      expect(ScientificMathNotifier.evaluateExpression('sin(0)', isRadians: true), '0');
      expect(ScientificMathNotifier.evaluateExpression('cos(0)', isRadians: true), '1');
      expect(ScientificMathNotifier.evaluateExpression('tan(0)', isRadians: true), '0');
    });

    test('Standard Trigonometry in Degrees', () {
      expect(ScientificMathNotifier.evaluateExpression('sin(30)', isRadians: false), '0.5');
      expect(ScientificMathNotifier.evaluateExpression('cos(60)', isRadians: false), '0.5');
      expect(ScientificMathNotifier.evaluateExpression('tan(45)', isRadians: false), '1');
      expect(ScientificMathNotifier.evaluateExpression('sin(90)', isRadians: false), '1');
      expect(ScientificMathNotifier.evaluateExpression('cos(90)', isRadians: false), '0');
    });

    test('Inverse Trigonometry in Degrees', () {
      expect(ScientificMathNotifier.evaluateExpression('asin(0.5)', isRadians: false), '30');
      expect(ScientificMathNotifier.evaluateExpression('acos(0.5)', isRadians: false), '60');
      expect(ScientificMathNotifier.evaluateExpression('atan(1)', isRadians: false), '45');
    });

    test('Inverse Trigonometry in Radians', () {
      final asinResult = double.parse(ScientificMathNotifier.evaluateExpression('asin(1)', isRadians: true));
      expect((asinResult - (math.pi / 2)).abs() < 1e-6, isTrue);
    });

    test('Hyperbolic Functions', () {
      expect(ScientificMathNotifier.evaluateExpression('sinh(0)', isRadians: true), '0');
      expect(ScientificMathNotifier.evaluateExpression('cosh(0)', isRadians: true), '1');
      expect(ScientificMathNotifier.evaluateExpression('tanh(0)', isRadians: true), '0');

      // cosh(1) ≈ 1.543080635
      final cosh1 = double.parse(ScientificMathNotifier.evaluateExpression('cosh(1)', isRadians: true));
      expect((cosh1 - 1.543080635).abs() < 1e-4, isTrue);
    });

    test('Powers, Roots and Logs', () {
      expect(ScientificMathNotifier.evaluateExpression('sqrt(16)', isRadians: true), '4');
      expect(ScientificMathNotifier.evaluateExpression('cbrt(27)', isRadians: true), '3');
      expect(ScientificMathNotifier.evaluateExpression('log(100)', isRadians: true), '2');
      expect(ScientificMathNotifier.evaluateExpression('ln(e)', isRadians: true), '1');
      expect(ScientificMathNotifier.evaluateExpression('2^3', isRadians: true), '8');
      expect(ScientificMathNotifier.evaluateExpression('1/(4)', isRadians: true), '0.25');
    });

    test('Factorial and Consumer Percentage', () {
      expect(ScientificMathNotifier.evaluateExpression('5!', isRadians: true), '120');
      expect(ScientificMathNotifier.evaluateExpression('0!', isRadians: true), '1');
      expect(ScientificMathNotifier.evaluateExpression('50+10%', isRadians: true), '55');
    });
  });
}