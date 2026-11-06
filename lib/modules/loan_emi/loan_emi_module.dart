import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:omni_calc/core/models/calculator_module.dart';
import 'package:omni_calc/core/models/calculator_category.dart';
import 'package:omni_calc/core/theme/app_colors.dart';
import 'package:omni_calc/core/theme/app_theme_extension.dart';
import 'package:omni_calc/modules/loan_emi/loan_emi_provider.dart';

class LoanEmiModule extends CalculatorModule {
  const LoanEmiModule()
      : super(
          id: 'loan_emi',
          name: 'Loan & Mortgage (EMI)',
          description: 'Calculate EMI, flat vs reducing rates, and amortization',
          icon: Icons.account_balance,
          category: CalculatorCategory.finance,
          primaryColor: AppColors.amberAccent,
        );

  @override
  Widget buildUI(BuildContext context) {
    return const LoanEmiScreen();
  }
}

class LoanEmiScreen extends ConsumerWidget {
  const LoanEmiScreen({super.key});

  static String formatCurrency(double val) {
    return val.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loanEmiProvider);
    final notifier = ref.read(loanEmiProvider.notifier);
    final theme = context.omniTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBg,
      appBar: AppBar(
        title: const Text('Loan & Mortgage EMI', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interest Rate Type Segmented Toggle
              Container(
                decoration: BoxDecoration(
                  color: theme.surfaceBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _RateTypeButton(
                        label: 'Reducing Balance Rate',
                        isSelected: state.rateType == InterestRateType.reducing,
                        onTap: () => notifier.setRateType(InterestRateType.reducing),
                      ),
                    ),
                    Expanded(
                      child: _RateTypeButton(
                        label: 'Flat Rate',
                        isSelected: state.rateType == InterestRateType.flat,
                        onTap: () => notifier.setRateType(InterestRateType.flat),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Inputs Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _ValidatedSliderInput(
                      label: 'Principal Amount',
                      currentValue: state.principal,
                      min: 1000,
                      max: 20000000,
                      divisions: 1999,
                      isDecimal: false,
                      suffix: '',
                      activeColor: theme.loanEmiAccent,
                      onChanged: (val) => notifier.setPrincipal(val),
                    ),
                    const Divider(color: AppColors.slate600, height: 24),
                    _ValidatedSliderInput(
                      label: 'Annual Interest Rate',
                      currentValue: state.annualInterestRate,
                      min: 0.1,
                      max: 40.0,
                      divisions: 399,
                      isDecimal: true,
                      suffix: '%',
                      activeColor: theme.basicMathAccent,
                      onChanged: (val) => notifier.setInterestRate(val),
                    ),
                    const Divider(color: AppColors.slate600, height: 24),
                    _ValidatedSliderInput(
                      label: 'Tenure (Years)',
                      currentValue: state.tenureYears.toDouble(),
                      min: 1,
                      max: 40,
                      divisions: 39,
                      isDecimal: false,
                      suffix: ' Yrs',
                      activeColor: theme.scientificAccent,
                      onChanged: (val) => notifier.setTenure(val.toInt()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Result Summary & Doughnut Chart Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.cardBg, theme.cardBg.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate600.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Doughnut Chart
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 36,
                              startDegreeOffset: -90,
                              sections: [
                                PieChartSectionData(
                                  value: state.principalRatio * 100,
                                  color: theme.basicMathAccent,
                                  title: '',
                                  radius: 20,
                                ),
                                PieChartSectionData(
                                  value: state.interestRatio * 100,
                                  color: theme.loanEmiAccent,
                                  title: '',
                                  radius: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Monthly EMI Output
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Monthly EMI',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatCurrency(state.monthlyEmi),
                                style: TextStyle(
                                  color: theme.loanEmiAccent,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _BreakdownRow(
                                color: theme.basicMathAccent,
                                label: 'Principal',
                                amount: formatCurrency(state.principal),
                              ),
                              const SizedBox(height: 4),
                              _BreakdownRow(
                                color: theme.loanEmiAccent,
                                label: 'Total Interest',
                                amount: formatCurrency(state.totalInterest),
                              ),
                              const Divider(color: AppColors.slate600, height: 16),
                              _BreakdownRow(
                                color: AppColors.textSecondary,
                                label: 'Total Payable',
                                amount: formatCurrency(state.totalPayment),
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.loanEmiAccent),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: Icon(Icons.table_chart_outlined, color: theme.loanEmiAccent),
                        label: Text(
                          'View Amortization Schedule',
                          style: TextStyle(color: theme.loanEmiAccent),
                        ),
                        onPressed: () => _showAmortizationSheet(context, state),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAmortizationSheet(BuildContext context, LoanEmiState state) {
    final theme = context.omniTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surfaceBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final schedule = state.schedule;
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.slate600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Amortization Schedule (Monthly)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: const [
                      SizedBox(width: 40, child: Text('Mo', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
                      Expanded(child: Text('Principal', style: TextStyle(color: AppColors.textMuted, fontSize: 12), textAlign: TextAlign.right)),
                      Expanded(child: Text('Interest', style: TextStyle(color: AppColors.textMuted, fontSize: 12), textAlign: TextAlign.right)),
                      Expanded(child: Text('Balance', style: TextStyle(color: AppColors.textMuted, fontSize: 12), textAlign: TextAlign.right)),
                    ],
                  ),
                ),
                const Divider(color: AppColors.slate600, height: 1),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: schedule.length,
                    separatorBuilder: (_, __) => const Divider(color: AppColors.slate700, height: 1),
                    itemBuilder: (context, index) {
                      final row = schedule[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(width: 40, child: Text('${row.month}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                            Expanded(child: Text(formatCurrency(row.principalPaid), style: TextStyle(color: theme.basicMathAccent, fontSize: 13), textAlign: TextAlign.right)),
                            Expanded(child: Text(formatCurrency(row.interestPaid), style: TextStyle(color: theme.loanEmiAccent, fontSize: 13), textAlign: TextAlign.right)),
                            Expanded(child: Text(formatCurrency(row.remainingBalance), style: const TextStyle(color: AppColors.textPrimary, fontSize: 13), textAlign: TextAlign.right)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _RateTypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RateTypeButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.omniTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.loanEmiAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? theme.scaffoldBg : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ValidatedSliderInput extends StatefulWidget {
  final String label;
  final double currentValue;
  final double min;
  final double max;
  final int divisions;
  final bool isDecimal;
  final String suffix;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  const _ValidatedSliderInput({
    required this.label,
    required this.currentValue,
    required this.min,
    required this.max,
    required this.divisions,
    required this.isDecimal,
    required this.suffix,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  State<_ValidatedSliderInput> createState() => _ValidatedSliderInputState();
}

class _ValidatedSliderInputState extends State<_ValidatedSliderInput> {
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _formatValue(widget.currentValue));
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _ValidatedSliderInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && oldWidget.currentValue != widget.currentValue) {
      _textController.text = _formatValue(widget.currentValue);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  String _formatValue(double val) {
    return widget.isDecimal ? val.toStringAsFixed(1) : val.toStringAsFixed(0);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _commitValidation(_textController.text);
    }
  }

  void _commitValidation(String raw) {
    final parsed = double.tryParse(raw.replaceAll(',', '').trim());
    if (parsed == null) {
      _textController.text = _formatValue(widget.currentValue);
      return;
    }

    final clamped = parsed.clamp(widget.min, widget.max);
    _textController.text = _formatValue(clamped);
    widget.onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.omniTheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            Container(
              width: 130,
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: theme.scaffoldBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: widget.activeColor.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.numberWithOptions(decimal: widget.isDecimal),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          widget.isDecimal ? RegExp(r'^\d*\.?\d*') : RegExp(r'^\d*'),
                        ),
                      ],
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: widget.activeColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: _commitValidation,
                    ),
                  ),
                  if (widget.suffix.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        widget.suffix,
                        style: TextStyle(
                          color: widget.activeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: widget.activeColor,
            thumbColor: widget.activeColor,
            overlayColor: widget.activeColor.withOpacity(0.2),
            inactiveTrackColor: AppColors.slate600.withOpacity(0.3),
            trackHeight: 4,
          ),
          child: Slider(
            value: widget.currentValue.clamp(widget.min, widget.max),
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChanged: (val) {
              _textController.text = _formatValue(val);
              widget.onChanged(val);
            },
          ),
        ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final Color color;
  final String label;
  final String amount;
  final bool isBold;

  const _BreakdownRow({
    required this.color,
    required this.label,
    required this.amount,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: isBold ? 13 : 12)),
          ],
        ),
        Text(
          amount,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}