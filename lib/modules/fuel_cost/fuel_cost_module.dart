import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omni_calc/core/models/calculator_module.dart';
import 'package:omni_calc/core/models/calculator_category.dart';
import 'package:omni_calc/core/theme/app_colors.dart';
import 'package:omni_calc/core/theme/app_theme_extension.dart';
import 'fuel_cost_provider.dart';

class FuelCostModule extends CalculatorModule {
  const FuelCostModule()
      : super(
          id: 'fuel_cost',
          name: 'Fuel Cost & Trip Mileage',
          description: 'Trip consumption, passenger cost splitting, and km/L vs MPG',
          icon: Icons.local_gas_station_rounded,
          category: CalculatorCategory.everyday,
          primaryColor: AppColors.amber,
        );

  @override
  Widget buildUI(BuildContext context) {
    return const FuelCostScreen();
  }
}

class FuelCostScreen extends ConsumerStatefulWidget {
  const FuelCostScreen({super.key});

  @override
  ConsumerState<FuelCostScreen> createState() => _FuelCostScreenState();
}

class _FuelCostScreenState extends ConsumerState<FuelCostScreen> {
  final FocusNode _distanceFocusNode = FocusNode();
  final FocusNode _efficiencyFocusNode = FocusNode();
  final FocusNode _fuelPriceFocusNode = FocusNode();

  @override
  void dispose() {
    _distanceFocusNode.dispose();
    _efficiencyFocusNode.dispose();
    _fuelPriceFocusNode.dispose();
    super.dispose();
  }

  static String _formatNum(double val, {int decimals = 2}) {
    String s = val.toStringAsFixed(decimals);
    return s.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fuelCostProvider);
    final notifier = ref.read(fuelCostProvider.notifier);
    final theme = context.omniTheme;

    final isKm = state.unit == FuelEfficiencyUnit.kmPerLiter;

    return Scaffold(
      backgroundColor: theme.scaffoldBg,
      appBar: AppBar(
        title: const Text('Fuel Cost & Mileage', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unit Segmented Toggle
              Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _UnitTabButton(
                        label: 'Metric (km & km/L)',
                        isSelected: isKm,
                        onTap: () => notifier.setUnit(FuelEfficiencyUnit.kmPerLiter),
                      ),
                    ),
                    Expanded(
                      child: _UnitTabButton(
                        label: 'Imperial (Miles & MPG)',
                        isSelected: !isKm,
                        onTap: () => notifier.setUnit(FuelEfficiencyUnit.mpgUS),
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
                    _NumericInputCard(
                      label: 'Trip Distance',
                      value: state.distance,
                      placeholderHint: isKm ? '150' : '95',
                      suffix: state.unit.distanceUnit,
                      activeColor: theme.primary,
                      isDecimal: true,
                      focusNode: _distanceFocusNode,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_efficiencyFocusNode);
                      },
                      onChanged: notifier.setDistance,
                    ),
                    Divider(color: theme.divider, height: 20),
                    _NumericInputCard(
                      label: 'Vehicle Fuel Efficiency',
                      value: state.efficiency,
                      placeholderHint: isKm ? '15.0' : '35.0',
                      suffix: state.unit.label,
                      activeColor: theme.secondary,
                      isDecimal: true,
                      focusNode: _efficiencyFocusNode,
                      textInputAction: state.calculateCost ? TextInputAction.next : TextInputAction.done,
                      onSubmitted: (_) {
                        if (state.calculateCost) {
                          FocusScope.of(context).requestFocus(_fuelPriceFocusNode);
                        } else {
                          _efficiencyFocusNode.unfocus();
                        }
                      },
                      onChanged: notifier.setEfficiency,
                    ),
                    Divider(color: theme.divider, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Round Trip (2× Distance)', style: TextStyle(color: theme.textSecondary, fontSize: 14)),
                        Switch(
                          value: state.isRoundTrip,
                          activeColor: theme.primary,
                          onChanged: notifier.toggleRoundTrip,
                        ),
                      ],
                    ),
                    Divider(color: theme.divider, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Include Fuel Price & Cost', style: TextStyle(color: theme.textSecondary, fontSize: 14)),
                        Switch(
                          value: state.calculateCost,
                          activeColor: theme.primary,
                          onChanged: notifier.toggleCalculateCost,
                        ),
                      ],
                    ),
                    if (state.calculateCost) ...[
                      const SizedBox(height: 12),
                      _NumericInputCard(
                        label: 'Fuel Price (per ${state.unit.volumeUnit})',
                        value: state.fuelPrice,
                        placeholderHint: isKm ? '105' : '3.80',
                        suffix: '/${state.unit.volumeUnit}',
                        activeColor: theme.chartSecondary,
                        isDecimal: true,
                        focusNode: _fuelPriceFocusNode,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _fuelPriceFocusNode.unfocus(),
                        onChanged: notifier.setFuelPrice,
                      ),
                      Divider(color: theme.divider, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Number of Passengers', style: TextStyle(color: theme.textSecondary, fontSize: 14)),
                          Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: theme.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 16),
                                  color: theme.textSecondary,
                                  onPressed: state.passengers > 1
                                      ? () => notifier.setPassengers(state.passengers - 1)
                                      : null,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text(
                                    '${state.passengers}',
                                    style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 16),
                                  color: theme.textSecondary,
                                  onPressed: () => notifier.setPassengers(state.passengers + 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Results Summary Card
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
                    Text(
                      state.calculateCost ? 'Total Fuel Expense' : 'Fuel Required',
                      style: TextStyle(color: theme.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    if (!state.hasRequiredInputs) ...[
                      Text(
                        'Enter distance and efficiency',
                        style: TextStyle(
                          color: theme.textMuted,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ] else ...[
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          state.calculateCost && state.totalFuelCost != null
                              ? _formatNum(state.totalFuelCost!)
                              : '${_formatNum(state.fuelRequired!, decimals: 2)} ${state.unit.volumeUnit}',
                          style: TextStyle(
                            color: state.calculateCost ? theme.chartSecondary : theme.primary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (state.calculateCost && state.totalFuelCost != null && state.passengers > 1) ...[
                        _ResultMetricRow(
                          label: 'Cost Per Passenger (${state.passengers} people)',
                          value: _formatNum(state.costPerPassenger!),
                          accentColor: theme.primary,
                        ),
                        const SizedBox(height: 10),
                      ],

                      _ResultMetricRow(
                        label: 'Total Distance',
                        value: '${_formatNum(state.effectiveDistance, decimals: 1)} ${state.unit.distanceUnit}',
                        accentColor: theme.secondary,
                      ),
                      const SizedBox(height: 10),

                      _ResultMetricRow(
                        label: 'Fuel Volume Needed',
                        value: '${_formatNum(state.fuelRequired!, decimals: 2)} ${state.unit.volumeUnit}',
                        accentColor: theme.chartPrimary,
                      ),

                      if (state.calculateCost && state.costPerDistanceUnit != null) ...[
                        const SizedBox(height: 10),
                        _ResultMetricRow(
                          label: 'Cost per ${state.unit.distanceUnit}',
                          value: _formatNum(state.costPerDistanceUnit!),
                          accentColor: theme.textSecondary,
                        ),
                      ],
                    ],
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

class _UnitTabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnitTabButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.omniTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
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

class _NumericInputCard extends StatefulWidget {
  final String label;
  final double? value;
  final String placeholderHint;
  final String suffix;
  final Color activeColor;
  final bool isDecimal;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<double?> onChanged;

  const _NumericInputCard({
    required this.label,
    required this.value,
    required this.placeholderHint,
    required this.suffix,
    required this.activeColor,
    required this.isDecimal,
    required this.focusNode,
    required this.textInputAction,
    this.onSubmitted,
    required this.onChanged,
  });

  @override
  State<_NumericInputCard> createState() => _NumericInputCardState();
}

class _NumericInputCardState extends State<_NumericInputCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value != null ? _format(widget.value!) : '');
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _NumericInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onFocusChange);
      widget.focusNode.addListener(_onFocusChange);
    }
    // Only update controller if external state changed while not focused
    if (!widget.focusNode.hasFocus && oldWidget.value != widget.value) {
      final formatted = widget.value != null ? _format(widget.value!) : '';
      if (_controller.text != formatted) {
        _controller.text = formatted;
      }
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    super.dispose();
  }

  String _format(double val) {
    if (widget.isDecimal) {
      String s = val.toStringAsFixed(2);
      s = s.replaceAll(RegExp(r'0+$'), '');
      if (s.endsWith('.')) s = s.substring(0, s.length - 1);
      return s;
    }
    return val.toStringAsFixed(0);
  }

  void _onFocusChange() {
    if (!widget.focusNode.hasFocus) {
      _commitValidation(_controller.text);
    }
  }

  void _commitValidation(String raw) {
    final trimmed = raw.replaceAll(',', '').trim();
    if (trimmed.isEmpty) {
      _controller.clear();
      widget.onChanged(null);
      return;
    }

    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      _controller.text = widget.value != null ? _format(widget.value!) : '';
      return;
    }

    widget.onChanged(parsed);
    _controller.text = _format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.omniTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.label,
            style: TextStyle(color: theme.textSecondary, fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 130,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: theme.scaffoldBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: widget.activeColor.withOpacity(0.5)),
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: widget.focusNode,
                  keyboardType: TextInputType.numberWithOptions(decimal: widget.isDecimal),
                  textInputAction: widget.textInputAction,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      widget.isDecimal ? RegExp(r'^\d*\.?\d*') : RegExp(r'^\d*'),
                    ),
                  ],
                  textAlign: TextAlign.right,
                  textAlignVertical: TextAlignVertical.center,
                  // Solid, fully opaque text — never faded
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    // Clue placeholder visible ONLY when field is completely empty
                    hintText: widget.placeholderHint,
                    hintStyle: TextStyle(
                      color: theme.textMuted.withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onSubmitted: (val) {
                    _commitValidation(val);
                    widget.onSubmitted?.call(val);
                  },
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultMetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _ResultMetricRow({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.omniTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: theme.textSecondary, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: accentColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}