import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omni_calc/core/models/calculator_module.dart';
import 'package:omni_calc/core/models/calculator_category.dart';
import 'package:omni_calc/core/theme/app_colors.dart';
import 'package:omni_calc/core/theme/app_theme_extension.dart';
import 'package:omni_calc/modules/basic_math/basic_math_provider.dart';

class BasicMathModule extends CalculatorModule {
  const BasicMathModule()
      : super(
          id: 'basic_math',
          name: 'Basic Math',
          description: 'Standard arithmetic and equations',
          icon: Icons.calculate,
          category: CalculatorCategory.everyday,
          primaryColor: AppColors.tealAccent,
        );

  @override
  Widget buildUI(BuildContext context) {
    return const BasicMathScreen();
  }
}

class BasicMathScreen extends ConsumerWidget {
  const BasicMathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(basicMathProvider);
    final notifier = ref.read(basicMathProvider.notifier);
    final theme = context.omniTheme;

    final buttonMatrix = [
      ['AC', '( )', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['+/-', '0', '.', '='],
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBg,
      appBar: AppBar(
        title: const Text('Basic Math', style: TextStyle(fontWeight: FontWeight.bold)),
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
          IconButton(
            tooltip: 'Backspace',
            icon: const Icon(Icons.backspace_outlined),
            onPressed: () => notifier.onButtonPressed('⌫'),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Expression & Live Evaluation Display
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      reverse: true,
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        state.equation,
                        style: TextStyle(
                          fontSize: state.equation.length > 12 ? 34 : 46,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.result.isEmpty ? ' ' : state.result,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: theme.basicMathAccent,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
            // Keypad Shell
            Expanded(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                decoration: BoxDecoration(
                  color: theme.surfaceBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: buttonMatrix.map((row) {
                    return Expanded(
                      child: Row(
                        children: row.map((btnText) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: _CalcButton(
                                text: btnText,
                                onTap: () => notifier.onButtonPressed(btnText),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalcButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _CalcButton({required this.text, required this.onTap});

  bool get isOperator => text == '÷' || text == '×' || text == '-' || text == '+' || text == '=';
  bool get isAction => text == 'AC' || text == '( )' || text == '%' || text == '+/-';

  @override
  Widget build(BuildContext context) {
    final theme = context.omniTheme;
    Color bgColor;
    Color textColor;

    if (text == '=') {
      bgColor = theme.basicMathAccent;
      textColor = theme.scaffoldBg;
    } else if (isOperator) {
      bgColor = AppColors.operatorBgTeal;
      textColor = theme.basicMathAccent;
    } else if (text == 'AC') {
      bgColor = theme.buttonClearBg;
      textColor = AppColors.redAccent;
    } else if (isAction) {
      bgColor = theme.buttonActionBg;
      textColor = theme.basicMathAccent;
    } else {
      bgColor = theme.buttonDefaultBg;
      textColor = AppColors.textPrimary;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: textColor.withOpacity(0.25),
        highlightColor: textColor.withOpacity(0.12),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: text.length > 2 ? 20 : 25,
              fontWeight: (isOperator || text == 'AC') ? FontWeight.bold : FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}