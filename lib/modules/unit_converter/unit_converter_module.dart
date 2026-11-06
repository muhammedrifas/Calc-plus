import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omni_calc/core/models/calculator_module.dart';
import 'package:omni_calc/core/models/calculator_category.dart';
import 'package:omni_calc/core/theme/app_colors.dart';
import 'package:omni_calc/core/theme/app_theme_extension.dart';
import 'unit_definitions.dart';
import 'unit_converter_provider.dart';

class UnitConverterModule extends CalculatorModule {
  const UnitConverterModule()
      : super(
          id: 'unit_converter',
          name: 'Universal Unit Converter',
          description: 'Multi-unit conversion for engineering, land, physics, and digital units',
          icon: Icons.swap_horiz_rounded,
          category: CalculatorCategory.everyday,
          primaryColor: AppColors.cyan,
        );

  @override
  Widget buildUI(BuildContext context) {
    return const UnitConverterScreen();
  }
}

class UnitConverterScreen extends ConsumerStatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  ConsumerState<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends ConsumerState<UnitConverterScreen> {
  late TextEditingController _sourceController;
  late TextEditingController _targetController;
  final FocusNode _sourceFocus = FocusNode();
  final FocusNode _targetFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final state = ref.read(unitConverterProvider);
    _sourceController = TextEditingController(text: _formatValue(state.sourceValue));
    _targetController = TextEditingController(text: _formatValue(state.targetValue));
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    _sourceFocus.dispose();
    _targetFocus.dispose();
    super.dispose();
  }

  String _formatValue(double val) {
    if (val.abs() >= 1e9 || (val.abs() > 0 && val.abs() < 1e-4)) {
      return val.toStringAsExponential(4);
    }
    String s = val.toStringAsFixed(6);
    s = s.replaceAll(RegExp(r'0+$'), '');
    if (s.endsWith('.')) s = s.substring(0, s.length - 1);
    return s.isEmpty ? '0' : s;
  }

  void _syncControllers(UnitConverterState state) {
    if (!_sourceFocus.hasFocus) {
      _sourceController.text = _formatValue(state.sourceValue);
    }
    if (!_targetFocus.hasFocus) {
      _targetController.text = _formatValue(state.targetValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unitConverterProvider);
    final notifier = ref.read(unitConverterProvider.notifier);
    final theme = context.omniTheme;

    _syncControllers(state);

    return Scaffold(
      backgroundColor: theme.scaffoldBg,
      appBar: AppBar(
        title: const Text('Unit Converter', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Horizontal Selector
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: UnitCategory.values.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = UnitCategory.values[index];
                  final isSelected = cat == state.category;
                  return ChoiceChip(
                    label: Text(cat.label),
                    selected: isSelected,
                    selectedColor: theme.secondary,
                    backgroundColor: theme.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? theme.scaffoldBg : theme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) notifier.selectCategory(cat);
                    },
                  );
                },
              ),
            ),

            // Conversion Inputs Card
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.divider.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        // Source Field
                        _UnitInputCard(
                          label: 'From',
                          unit: state.sourceUnit,
                          availableUnits: UnitRegistry.unitsByCategory[state.category]!,
                          controller: _sourceController,
                          focusNode: _sourceFocus,
                          onUnitChanged: notifier.setSourceUnit,
                          onValueChanged: (val) => notifier.setSourceValue(val),
                        ),

                        // Swap Button Divider
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Divider(color: theme.divider, height: 1),
                              Material(
                                color: theme.surface,
                                shape: const CircleBorder(),
                                child: IconButton(
                                  icon: Icon(Icons.swap_vert, color: theme.secondary),
                                  tooltip: 'Swap Units',
                                  onPressed: () => notifier.swapUnits(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Target Field
                        _UnitInputCard(
                          label: 'To',
                          unit: state.targetUnit,
                          availableUnits: UnitRegistry.unitsByCategory[state.category]!,
                          controller: _targetController,
                          focusNode: _targetFocus,
                          onUnitChanged: notifier.setTargetUnit,
                          onValueChanged: (val) => notifier.setTargetValue(val),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // All Equivalent Units List Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Text(
                      'All Equivalent Units (${state.category.label})',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // All Units Equivalence Grid
                  ...state.allCategoryConversions.entries.map((entry) {
                    final unit = entry.key;
                    final val = entry.value;
                    final isCurrentSource = unit.id == state.sourceUnit.id;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isCurrentSource
                            ? theme.secondary.withOpacity(0.12)
                            : theme.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrentSource
                              ? theme.secondary.withOpacity(0.4)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              unit.name,
                              style: TextStyle(
                                color: isCurrentSource ? theme.secondary : theme.textPrimary,
                                fontWeight: isCurrentSource ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 5,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${_formatValue(val)} ${unit.symbol}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: isCurrentSource ? theme.secondary : theme.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitInputCard extends StatelessWidget {
  final String label;
  final UnitDef unit;
  final List<UnitDef> availableUnits;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<UnitDef> onUnitChanged;
  final ValueChanged<double> onValueChanged;

  const _UnitInputCard({
    required this.label,
    required this.unit,
    required this.availableUnits,
    required this.controller,
    required this.focusNode,
    required this.onUnitChanged,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.omniTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: theme.textMuted, fontSize: 13)),
            DropdownButton<UnitDef>(
              value: unit,
              dropdownColor: theme.surface,
              underline: const SizedBox(),
              icon: Icon(Icons.keyboard_arrow_down, color: theme.secondary, size: 20),
              items: availableUnits.map((u) {
                return DropdownMenuItem(
                  value: u,
                  child: Text('${u.name} (${u.symbol})', style: TextStyle(color: theme.textPrimary)),
                );
              }).toList(),
              onChanged: (newUnit) {
                if (newUnit != null) onUnitChanged(newUnit);
              },
            ),
          ],
        ),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
          ],
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            suffixText: unit.symbol,
            suffixStyle: TextStyle(color: theme.secondary, fontSize: 16),
          ),
          onChanged: (val) {
            final parsed = double.tryParse(val.trim());
            if (parsed != null) onValueChanged(parsed);
          },
        ),
      ],
    );
  }
}