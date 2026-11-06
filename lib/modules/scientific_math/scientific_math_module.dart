import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omni_calc/core/models/calculator_module.dart';
import 'package:omni_calc/core/models/calculator_category.dart';
import 'package:omni_calc/core/theme/app_colors.dart';
import 'package:omni_calc/core/theme/app_theme_extension.dart';
import 'package:omni_calc/modules/scientific_math/scientific_key_action.dart';
import 'package:omni_calc/modules/scientific_math/scientific_math_provider.dart';

class ScientificMathModule extends CalculatorModule {
  const ScientificMathModule()
      : super(
          id: 'scientific_math',
          name: 'Scientific Math',
          description: 'Trigonometry, logarithms, roots, and powers',
          icon: Icons.science,
          category: CalculatorCategory.everyday,
          primaryColor: AppColors.purpleAccent,
        );

  @override
  Widget buildUI(BuildContext context) {
    return const ScientificMathScreen();
  }
}

class ScientificMathScreen extends ConsumerWidget {
  const ScientificMathScreen({super.key});

  List<List<SciKeyDef>> _buildSciRows(ScientificMathState state) {
    final modeLabel = state.isRadians ? 'RAD' : 'DEG';

    if (state.isInverse) {
      return [
        [
          const SciKeyDef(action: SciKeyAction.toggleInverse, label: '⇄', type: SciKeyType.action),
          SciKeyDef(action: SciKeyAction.toggleAngleUnit, label: modeLabel, type: SciKeyType.action),
          const SciKeyDef(action: SciKeyAction.asin, label: 'asin', type: SciKeyType.function),
          const SciKeyDef(action: SciKeyAction.acos, label: 'acos', type: SciKeyType.function),
          const SciKeyDef(action: SciKeyAction.atan, label: 'atan', type: SciKeyType.function),
        ],
        [
          const SciKeyDef(action: SciKeyAction.sinh, label: 'sinh', type: SciKeyType.function),
          const SciKeyDef(action: SciKeyAction.cosh, label: 'cosh', type: SciKeyType.function),
          const SciKeyDef(action: SciKeyAction.tanh, label: 'tanh', type: SciKeyType.function),
          const SciKeyDef(action: SciKeyAction.expPower, label: 'eˣ', type: SciKeyType.function),
          const SciKeyDef(action: SciKeyAction.tenPower, label: '10ˣ', type: SciKeyType.function),
        ],
        [
          const SciKeyDef(action: SciKeyAction.square, label: 'x²', type: SciKeyType.function),
          const SciKeyDef(action: SciKeyAction.cube, label: 'x³', type: SciKeyType.function),
          const SciKeyDef(action: SciKeyAction.power, label: 'xʸ', type: SciKeyType.function),
          const SciKeyDef(action: SciKeyAction.factorial, label: 'n!', type: SciKeyType.function),
          const SciKeyDef(action: SciKeyAction.parentheses, label: '( )', type: SciKeyType.action),
        ],
      ];
    }

    return [
      [
        const SciKeyDef(action: SciKeyAction.toggleInverse, label: '⇄', type: SciKeyType.action),
        SciKeyDef(action: SciKeyAction.toggleAngleUnit, label: modeLabel, type: SciKeyType.action),
        const SciKeyDef(action: SciKeyAction.sin, label: 'sin', type: SciKeyType.function),
        const SciKeyDef(action: SciKeyAction.cos, label: 'cos', type: SciKeyType.function),
        const SciKeyDef(action: SciKeyAction.tan, label: 'tan', type: SciKeyType.function),
      ],
      [
        const SciKeyDef(action: SciKeyAction.ln, label: 'ln', type: SciKeyType.function),
        const SciKeyDef(action: SciKeyAction.log, label: 'log', type: SciKeyType.function),
        const SciKeyDef(action: SciKeyAction.reciprocal, label: '1/x', type: SciKeyType.function),
        const SciKeyDef(action: SciKeyAction.e, label: 'e', type: SciKeyType.function),
        const SciKeyDef(action: SciKeyAction.pi, label: 'π', type: SciKeyType.function),
      ],
      [
        const SciKeyDef(action: SciKeyAction.sqrt, label: '√', type: SciKeyType.function),
        const SciKeyDef(action: SciKeyAction.cbrt, label: '∛', type: SciKeyType.function),
        const SciKeyDef(action: SciKeyAction.abs, label: '|x|', type: SciKeyType.function),
        const SciKeyDef(action: SciKeyAction.parentheses, label: '( )', type: SciKeyType.action),
        const SciKeyDef(action: SciKeyAction.percent, label: '%', type: SciKeyType.action),
      ],
    ];
  }

  static const List<List<SciKeyDef>> _numpadMatrix = [
    [
      SciKeyDef(action: SciKeyAction.clearAll, label: 'AC', type: SciKeyType.action),
      SciKeyDef(action: SciKeyAction.backspace, label: '⌫', type: SciKeyType.action),
      SciKeyDef(action: SciKeyAction.toggleSign, label: '+/-', type: SciKeyType.action),
      SciKeyDef(action: SciKeyAction.divide, label: '÷', type: SciKeyType.operator),
    ],
    [
      SciKeyDef(action: SciKeyAction.digit7, label: '7', type: SciKeyType.number),
      SciKeyDef(action: SciKeyAction.digit8, label: '8', type: SciKeyType.number),
      SciKeyDef(action: SciKeyAction.digit9, label: '9', type: SciKeyType.number),
      SciKeyDef(action: SciKeyAction.multiply, label: '×', type: SciKeyType.operator),
    ],
    [
      SciKeyDef(action: SciKeyAction.digit4, label: '4', type: SciKeyType.number),
      SciKeyDef(action: SciKeyAction.digit5, label: '5', type: SciKeyType.number),
      SciKeyDef(action: SciKeyAction.digit6, label: '6', type: SciKeyType.number),
      SciKeyDef(action: SciKeyAction.subtract, label: '-', type: SciKeyType.operator),
    ],
    [
      SciKeyDef(action: SciKeyAction.digit1, label: '1', type: SciKeyType.number),
      SciKeyDef(action: SciKeyAction.digit2, label: '2', type: SciKeyType.number),
      SciKeyDef(action: SciKeyAction.digit3, label: '3', type: SciKeyType.number),
      SciKeyDef(action: SciKeyAction.add, label: '+', type: SciKeyType.operator),
    ],
    [
      SciKeyDef(action: SciKeyAction.digit0, label: '0', type: SciKeyType.number, flex: 2),
      SciKeyDef(action: SciKeyAction.decimal, label: '.', type: SciKeyType.number, flex: 1),
      SciKeyDef(action: SciKeyAction.calculate, label: '=', type: SciKeyType.equals, flex: 1),
    ],
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scientificMathProvider);
    final notifier = ref.read(scientificMathProvider.notifier);
    final sciRows = _buildSciRows(state);
    final theme = context.omniTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBg,
      appBar: AppBar(
        title: const Text('Scientific Math', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Calculation History',
            icon: const Icon(Icons.history),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: theme.surfaceBg,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (context) {
                  if (state.history.isEmpty) {
                    return const SizedBox(
                      height: 180,
                      child: Center(
                        child: Text(
                          'No calculations yet',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    itemCount: state.history.length,
                    separatorBuilder: (_, __) => const Divider(color: AppColors.slate600, height: 1),
                    itemBuilder: (context, index) => ListTile(
                      title: Text(
                        state.history[index],
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      reverse: true,
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        state.displayEquation,
                        style: TextStyle(
                          fontSize: state.displayEquation.length > 14 ? 28 : 38,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.result.isEmpty ? ' ' : state.result,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.scientificAccent,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
                decoration: BoxDecoration(
                  color: theme.surfaceBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    ...sciRows.map((row) {
                      return Expanded(
                        flex: 4,
                        child: Row(
                          children: row.map((keyDef) {
                            final isHighlighted = (keyDef.action == SciKeyAction.toggleInverse && state.isInverse) ||
                                (keyDef.action == SciKeyAction.toggleAngleUnit);
                            return Expanded(
                              flex: keyDef.flex,
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: _SciKeyButton(
                                  keyDef: keyDef,
                                  isHighlighted: isHighlighted,
                                  onTap: () => notifier.onAction(keyDef.action),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Divider(color: AppColors.slate600, height: 1),
                    ),
                    ..._numpadMatrix.map((row) {
                      return Expanded(
                        flex: 5,
                        child: Row(
                          children: row.map((keyDef) {
                            return Expanded(
                              flex: keyDef.flex,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: _SciKeyButton(
                                  keyDef: keyDef,
                                  onTap: () => notifier.onAction(keyDef.action),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SciKeyButton extends StatelessWidget {
  final SciKeyDef keyDef;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _SciKeyButton({
    required this.keyDef,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.omniTheme;
    Color bgColor;
    Color textColor;

    switch (keyDef.type) {
      case SciKeyType.equals:
        bgColor = theme.scientificAccent;
        textColor = theme.scaffoldBg;
        break;
      case SciKeyType.operator:
        bgColor = AppColors.operatorBgPurple;
        textColor = theme.scientificAccent;
        break;
      case SciKeyType.action:
        if (keyDef.action == SciKeyAction.clearAll) {
          bgColor = theme.buttonClearBg;
          textColor = AppColors.redAccent;
        } else {
          bgColor = isHighlighted ? theme.scientificAccent.withOpacity(0.3) : theme.surfaceBg;
          textColor = isHighlighted ? theme.scientificAccent : AppColors.textSecondary;
        }
        break;
      case SciKeyType.number:
        bgColor = theme.buttonDefaultBg;
        textColor = AppColors.textPrimary;
        break;
      case SciKeyType.function:
        bgColor = theme.surfaceBg;
        textColor = AppColors.textSecondary;
        break;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: textColor.withOpacity(0.2),
        highlightColor: textColor.withOpacity(0.1),
        child: Center(
          child: Text(
            keyDef.label,
            style: TextStyle(
              fontSize: keyDef.label.length > 3
                  ? 13
                  : (keyDef.type == SciKeyType.number ||
                          keyDef.type == SciKeyType.operator ||
                          keyDef.type == SciKeyType.equals
                      ? 22
                      : 16),
              fontWeight: (keyDef.type == SciKeyType.operator ||
                      keyDef.type == SciKeyType.equals ||
                      keyDef.action == SciKeyAction.clearAll ||
                      isHighlighted)
                  ? FontWeight.bold
                  : FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}