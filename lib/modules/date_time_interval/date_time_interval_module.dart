import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omni_calc/core/models/calculator_module.dart';
import 'package:omni_calc/core/models/calculator_category.dart';
import 'package:omni_calc/core/theme/app_colors.dart';
import 'package:omni_calc/core/theme/app_theme_extension.dart';
import 'date_time_interval_provider.dart';

class DateTimeIntervalModule extends CalculatorModule {
  const DateTimeIntervalModule()
      : super(
          id: 'date_time_interval',
          name: 'Date & Time Interval',
          description: 'Calendar duration, working days, and date offsets',
          icon: Icons.calendar_month_rounded,
          category: CalculatorCategory.everyday,
          primaryColor: AppColors.teal,
        );

  @override
  Widget buildUI(BuildContext context) {
    return const DateTimeIntervalScreen();
  }
}

class DateTimeIntervalScreen extends ConsumerWidget {
  const DateTimeIntervalScreen({super.key});

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String _formatNumber(int val) {
    return val.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dateTimeIntervalProvider);
    final notifier = ref.read(dateTimeIntervalProvider.notifier);
    final theme = context.omniTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBg,
      appBar: AppBar(
        title: const Text('Date & Time Interval', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode Selector (Difference vs Offset)
              Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _ModeTabButton(
                        label: 'Duration Between Dates',
                        isSelected: state.mode == DateCalcMode.difference,
                        onTap: () => notifier.setMode(DateCalcMode.difference),
                      ),
                    ),
                    Expanded(
                      child: _ModeTabButton(
                        label: 'Add / Subtract Days',
                        isSelected: state.mode == DateCalcMode.offset,
                        onTap: () => notifier.setMode(DateCalcMode.offset),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (state.mode == DateCalcMode.difference) ...[
                // Difference Input Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _DatePickerTile(
                        label: 'Start Date',
                        date: state.startDate,
                        onSelect: (picked) => notifier.setStartDate(picked),
                      ),
                      Divider(color: theme.divider, height: 20),
                      _DatePickerTile(
                        label: 'End Date',
                        date: state.endDate,
                        onSelect: (picked) => notifier.setEndDate(picked),
                      ),
                      Divider(color: theme.divider, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Include End Date in Total', style: TextStyle(color: theme.textSecondary, fontSize: 14)),
                          Switch(
                            value: state.includeEndDay,
                            activeColor: theme.primary,
                            onChanged: (val) => notifier.toggleIncludeEndDay(val),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Difference Output Card
                _buildDifferenceResult(context, state.intervalDifference),
              ] else ...[
                // Offset Input Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _DatePickerTile(
                        label: 'Start From',
                        date: state.baseDate,
                        onSelect: (picked) => notifier.setBaseDate(picked),
                      ),
                      Divider(color: theme.divider, height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _SignButton(
                              icon: Icons.add,
                              label: 'Add (+)',
                              isSelected: state.isAddition,
                              onTap: () => notifier.setIsAddition(true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SignButton(
                              icon: Icons.remove,
                              label: 'Subtract (-)',
                              isSelected: !state.isAddition,
                              onTap: () => notifier.setIsAddition(false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _NumberInputField(
                              label: 'Years',
                              value: state.offsetYears,
                              onChanged: notifier.setOffsetYears,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _NumberInputField(
                              label: 'Months',
                              value: state.offsetMonths,
                              onChanged: notifier.setOffsetMonths,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _NumberInputField(
                              label: 'Weeks',
                              value: state.offsetWeeks,
                              onChanged: notifier.setOffsetWeeks,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _NumberInputField(
                              label: 'Days',
                              value: state.offsetDays,
                              onChanged: notifier.setOffsetDays,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Offset Output Card
                _buildOffsetResult(context, state.calculatedOffsetDate),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifferenceResult(BuildContext context, DateIntervalResult result) {
    final theme = context.omniTheme;

    String primaryBreakdown = '';
    if (result.years > 0) primaryBreakdown += '${result.years} yr ';
    if (result.months > 0) primaryBreakdown += '${result.months} mo ';
    primaryBreakdown += '${result.days} days';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.divider.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Exact Calendar Duration', style: TextStyle(color: theme.textMuted, fontSize: 13)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              primaryBreakdown.trim(),
              style: TextStyle(
                color: theme.primary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MetricRow(
            icon: Icons.calendar_today,
            label: 'Total Calendar Days',
            value: '${_formatNumber(result.totalDays)} days',
            accentColor: theme.secondary,
          ),
          const SizedBox(height: 10),
          _MetricRow(
            icon: Icons.work_outline_rounded,
            label: 'Working Days (Mon - Fri)',
            value: '${_formatNumber(result.workingDays)} days',
            accentColor: theme.chartPrimary,
          ),
          const SizedBox(height: 10),
          _MetricRow(
            icon: Icons.weekend_outlined,
            label: 'Weekend Days (Sat - Sun)',
            value: '${_formatNumber(result.weekendDays)} days',
            accentColor: theme.chartSecondary,
          ),
          Divider(color: theme.divider, height: 24),
          Row(
            children: [
              Expanded(
                child: _SmallMetricCard(
                  label: 'Total Hours',
                  value: _formatNumber(result.totalHours),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SmallMetricCard(
                  label: 'Total Minutes',
                  value: _formatNumber(result.totalMinutes),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOffsetResult(BuildContext context, DateTime targetDate) {
    final theme = context.omniTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.divider.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resulting Target Date', style: TextStyle(color: theme.textMuted, fontSize: 13)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatDate(targetDate),
              style: TextStyle(
                color: theme.primary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Day of the year: ${targetDate.difference(DateTime(targetDate.year, 1, 1)).inDays + 1}',
            style: TextStyle(color: theme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onSelect;

  const _DatePickerTile({
    required this.label,
    required this.date,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.omniTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(1900),
          lastDate: DateTime(2200),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: theme.primary,
                  onPrimary: theme.scaffoldBg,
                  surface: theme.surface,
                  onSurface: theme.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onSelect(picked);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: theme.textMuted, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  DateTimeIntervalScreen._formatDate(date),
                  style: TextStyle(color: theme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Icon(Icons.edit_calendar_rounded, color: theme.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

class _ModeTabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeTabButton({required this.label, required this.isSelected, required this.onTap});

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

class _SignButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SignButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.omniTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary.withOpacity(0.15) : theme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? theme.primary : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? theme.primary : theme.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.primary : theme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberInputField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _NumberInputField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.omniTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(color: theme.textMuted, fontSize: 11)),
        const SizedBox(height: 6),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: theme.scaffoldBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.divider),
          ),
          alignment: Alignment.center,
          child: TextFormField(
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (text) {
              final parsed = int.tryParse(text) ?? 0;
              onChanged(parsed);
            },
          ),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.omniTheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: accentColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: TextStyle(color: theme.textSecondary, fontSize: 13)),
        ),
        Text(
          value,
          style: TextStyle(color: theme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _SmallMetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _SmallMetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = context.omniTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: theme.textMuted, fontSize: 11)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}