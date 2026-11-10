import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omni_calc/core/models/calculator_module.dart';
import 'package:omni_calc/core/models/calculator_category.dart';
import 'package:omni_calc/core/theme/app_colors.dart';
import 'package:omni_calc/core/theme/app_theme_extension.dart';
import 'bmi_ibw_provider.dart';

class BmiIbwModule extends CalculatorModule {
  const BmiIbwModule()
      : super(
          id: 'bmi_ibw',
          name: 'BMI & Ideal Weight',
          description: 'Body Mass Index (WHO), healthy weight range, and Devine/Robinson IBW',
          icon: Icons.monitor_weight_outlined,
          category: CalculatorCategory.health,
          primaryColor: AppColors.teal,
        );

  @override
  Widget buildUI(BuildContext context) {
    return const BmiIbwScreen();
  }
}

class BmiIbwScreen extends ConsumerWidget {
  const BmiIbwScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bmiIbwProvider);
    final notifier = ref.read(bmiIbwProvider.notifier);
    final theme = context.omniTheme;

    final isMetric = state.system == MeasurementSystem.metric;
    final range = state.healthyWeightRange;

    Color categoryColor;
    if (state.category == BmiCategory.normalWeight) {
      categoryColor = theme.primary;
    } else if (state.category == BmiCategory.overweight ||
        state.category == BmiCategory.mildUnderweight) {
      categoryColor = theme.chartSecondary;
    } else {
      categoryColor = theme.error;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBg,
      appBar: AppBar(
        title: const Text('BMI & Ideal Weight', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Measurement Unit & Sex Toggles
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ToggleButton(
                              label: 'Metric',
                              isSelected: isMetric,
                              onTap: () => notifier.setSystem(MeasurementSystem.metric),
                            ),
                          ),
                          Expanded(
                            child: _ToggleButton(
                              label: 'Imperial',
                              isSelected: !isMetric,
                              onTap: () => notifier.setSystem(MeasurementSystem.imperial),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ToggleButton(
                              label: 'Male',
                              isSelected: state.sex == BiologicalSex.male,
                              onTap: () => notifier.setSex(BiologicalSex.male),
                            ),
                          ),
                          Expanded(
                            child: _ToggleButton(
                              label: 'Female',
                              isSelected: state.sex == BiologicalSex.female,
                              onTap: () => notifier.setSex(BiologicalSex.female),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

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
                      label: 'Height',
                      currentValue: state.displayHeight,
                      min: isMetric ? 100.0 : 40.0,
                      max: isMetric ? 240.0 : 95.0,
                      divisions: isMetric ? 140 : 110,
                      isDecimal: !isMetric,
                      suffix: ' ${state.heightUnit}',
                      activeColor: theme.secondary,
                      onChanged: notifier.setHeight,
                    ),
                    Divider(color: theme.divider, height: 24),
                    _ValidatedSliderInput(
                      label: 'Weight',
                      currentValue: state.displayWeight,
                      min: isMetric ? 30.0 : 65.0,
                      max: isMetric ? 250.0 : 550.0,
                      divisions: isMetric ? 440 : 485,
                      isDecimal: true,
                      suffix: ' ${state.weightUnit}',
                      activeColor: theme.primary,
                      onChanged: notifier.setWeight,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Results Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.divider.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Body Mass Index (BMI)', style: TextStyle(color: theme.textMuted, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              state.bmi.toStringAsFixed(1),
                              style: TextStyle(
                                color: categoryColor,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: categoryColor.withOpacity(0.4)),
                          ),
                          child: Text(
                            state.category.label,
                            style: TextStyle(
                              color: categoryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Visual BMI Gauge Spectrum
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 8,
                        child: Row(
                          children: [
                            Expanded(flex: 185, child: Container(color: theme.secondary)), // Underweight
                            Expanded(flex: 64, child: Container(color: theme.primary)), // Normal
                            Expanded(flex: 50, child: Container(color: theme.chartSecondary)), // Overweight
                            Expanded(flex: 100, child: Container(color: theme.error)), // Obese
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Healthy Range & IBW Estimates
                    _DetailRow(
                      label: 'Healthy Weight Range (WHO)',
                      value: '${range.$1.toStringAsFixed(1)} -${range.$2.toStringAsFixed(1)}${state.weightUnit}',
                      valueColor: theme.primary,
                    ),
                    Divider(color: theme.divider, height: 18),
                    _DetailRow(
                      label: 'Ideal Weight (Devine Formula)',
                      value: '${state.devineIbw.toStringAsFixed(1)}${state.weightUnit}',
                      valueColor: theme.textPrimary,
                    ),
                    Divider(color: theme.divider, height: 18),
                    _DetailRow(
                      label: 'Ideal Weight (Robinson Formula)',
                      value: '${state.robinsonIbw.toStringAsFixed(1)}${state.weightUnit}',
                      valueColor: theme.textPrimary,
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
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.omniTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: theme.textSecondary, fontSize: 13)),
        Text(
          value,
          style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.omniTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? theme.scaffoldBg : theme.textSecondary,
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
            Text(widget.label, style: TextStyle(color: theme.textSecondary, fontSize: 14)),
            Container(
              width: 120,
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
            inactiveTrackColor: theme.divider.withOpacity(0.3),
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