import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omni_calc/core/models/calculator_module.dart';
import 'package:omni_calc/core/models/calculator_category.dart';
import 'package:omni_calc/core/theme/app_colors.dart';
import 'package:omni_calc/core/theme/app_theme_extension.dart';
import 'bmr_tdee_provider.dart';

class BmrTdeeModule extends CalculatorModule {
  const BmrTdeeModule()
      : super(
          id: 'bmr_tdee',
          name: 'Calorie & TDEE Calculator',
          description: 'Basal Metabolic Rate (Mifflin-St Jeor) and daily calorie targets',
          icon: Icons.local_fire_department_rounded,
          category: CalculatorCategory.health,
          primaryColor: AppColors.rose,
        );

  @override
  Widget buildUI(BuildContext context) {
    return const BmrTdeeScreen();
  }
}

class BmrTdeeScreen extends ConsumerWidget {
  const BmrTdeeScreen({super.key});

  static String _formatCalories(double val) {
    return val.round().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bmrTdeeProvider);
    final notifier = ref.read(bmrTdeeProvider.notifier);
    final theme = context.omniTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBg,
      appBar: AppBar(
        title: const Text('BMR & Calorie Needs', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sex Segmented Selector
              Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _SexTabButton(
                        label: 'Male',
                        isSelected: state.sex == BmrSex.male,
                        onTap: () => notifier.setSex(BmrSex.male),
                      ),
                    ),
                    Expanded(
                      child: _SexTabButton(
                        label: 'Female',
                        isSelected: state.sex == BmrSex.female,
                        onTap: () => notifier.setSex(BmrSex.female),
                      ),
                    ),
                  ],
                ),
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
                    _SliderInputRow(
                      label: 'Age',
                      value: state.age.toDouble(),
                      min: 15,
                      max: 90,
                      divisions: 75,
                      suffix: ' yrs',
                      activeColor: theme.secondary,
                      onChanged: (val) => notifier.setAge(val.toInt()),
                    ),
                    Divider(color: theme.divider, height: 24),
                    _SliderInputRow(
                      label: 'Height',
                      value: state.heightCm,
                      min: 120,
                      max: 230,
                      divisions: 110,
                      suffix: ' cm',
                      activeColor: theme.primary,
                      onChanged: notifier.setHeight,
                    ),
                    Divider(color: theme.divider, height: 24),
                    _SliderInputRow(
                      label: 'Weight',
                      value: state.weightKg,
                      min: 35,
                      max: 200,
                      divisions: 165,
                      suffix: ' kg',
                      activeColor: theme.tertiary,
                      onChanged: notifier.setWeight,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Activity Level Dropdown Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Physical Activity Level', style: TextStyle(color: theme.textMuted, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButton<ActivityLevel>(
                      value: state.activityLevel,
                      dropdownColor: theme.surface,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: Icon(Icons.keyboard_arrow_down, color: theme.primary),
                      items: ActivityLevel.values.map((lvl) {
                        return DropdownMenuItem(
                          value: lvl,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${lvl.title} (${lvl.multiplier}x)',
                                style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                lvl.subtitle,
                                style: TextStyle(color: theme.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (lvl) {
                        if (lvl != null) notifier.setActivityLevel(lvl);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Results Overview Card
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
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Daily Maintenance (TDEE)', style: TextStyle(color: theme.textMuted, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              '${_formatCalories(state.tdee)} kcal',
                              style: TextStyle(color: theme.primary, fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Basal Rate (BMR)', style: TextStyle(color: theme.textMuted, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              '${_formatCalories(state.bmr)} kcal',
                              style: TextStyle(color: theme.secondary, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(color: theme.divider, height: 24),
                    Text('Calorie Targets by Goal',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.textPrimary)),
                    const SizedBox(height: 12),
                    _CalorieGoalRow(
                      label: 'Mild Weight Loss (-0.25 kg/wk)',
                      calories: state.mildWeightLoss,
                      accentColor: theme.secondary,
                    ),
                    const SizedBox(height: 8),
                    _CalorieGoalRow(
                      label: 'Standard Weight Loss (-0.5 kg/wk)',
                      calories: state.weightLoss,
                      accentColor: theme.chartSecondary,
                    ),
                    const SizedBox(height: 8),
                    _CalorieGoalRow(
                      label: 'Extreme Weight Loss (-1.0 kg/wk)',
                      calories: state.extremeWeightLoss,
                      accentColor: theme.error,
                    ),
                    const SizedBox(height: 8),
                    _CalorieGoalRow(
                      label: 'Mild Weight Gain (+0.25 kg/wk)',
                      calories: state.mildWeightGain,
                      accentColor: theme.primary,
                    ),
                    const SizedBox(height: 8),
                    _CalorieGoalRow(
                      label: 'Muscle Build / Bulk (+0.5 kg/wk)',
                      calories: state.weightGain,
                      accentColor: theme.tertiary,
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

class _CalorieGoalRow extends StatelessWidget {
  final String label;
  final double calories;
  final Color accentColor;

  const _CalorieGoalRow({
    required this.label,
    required this.calories,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.omniTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: theme.textSecondary, fontSize: 13)),
        Text(
          '${calories.round()} kcal',
          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}

class _SexTabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SexTabButton({required this.label, required this.isSelected, required this.onTap});

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
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? theme.scaffoldBg : theme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SliderInputRow extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String suffix;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  const _SliderInputRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.suffix,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  State<_SliderInputRow> createState() => _SliderInputRowState();
}

class _SliderInputRowState extends State<_SliderInputRow> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.round().toString());
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _SliderInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && oldWidget.value != widget.value) {
      _controller.text = widget.value.round().toString();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      final parsed = double.tryParse(_controller.text.trim());
      if (parsed == null) {
        _controller.text = widget.value.round().toString();
        return;
      }
      final clamped = parsed.clamp(widget.min, widget.max);
      _controller.text = clamped.round().toString();
      widget.onChanged(clamped);
    }
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
              width: 100,
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
                      controller: _controller,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.right,
                      style: TextStyle(color: widget.activeColor, fontSize: 14, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                      onSubmitted: (val) {
                        final parsed = double.tryParse(val.trim());
                        if (parsed != null) widget.onChanged(parsed.clamp(widget.min, widget.max));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(widget.suffix,
                        style: TextStyle(color: widget.activeColor, fontSize: 12, fontWeight: FontWeight.bold)),
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
            value: widget.value.clamp(widget.min, widget.max),
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChanged: (val) {
              _controller.text = val.round().toString();
              widget.onChanged(val);
            },
          ),
        ),
      ],
    );
  }
}