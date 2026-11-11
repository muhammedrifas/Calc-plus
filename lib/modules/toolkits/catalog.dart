import 'package:flutter/material.dart';
import '../../core/models/calculator_category.dart';
import '../../core/theme/app_colors.dart';
import 'toolkit_module.dart';
import 'percentages.dart';
import 'shopping.dart';
import 'earnings.dart';
import 'business.dart';
import 'budget.dart';
import 'returns.dart';
import 'surfaces.dart';
import 'volume_materials.dart';
import 'pace.dart';
import 'power_cost.dart';
import 'geometry.dart';
import 'ratios.dart';
import 'digital.dart';
import 'training.dart';
import 'circuits.dart';
import 'statistics.dart';
import 'fractions.dart';
import 'integers.dart';
import 'calendar.dart';
import 'writing.dart';
import 'shifts.dart';

final toolkitModules = <ToolkitModule>[
  ToolkitModule(
    id: 'percentages', name: 'Percentages',
    description: 'Find a share, percentage change, percentage difference or original value.',
    category: CalculatorCategory.everyday, icon: Icons.percent,
    primaryColor: AppColors.teal, modes: percentagesModes,
  ),
  ToolkitModule(
    id: 'shopping', name: 'Shopping & Bills',
    description: 'Compare unit prices, stack discounts, add or remove tax, and split a tip.',
    category: CalculatorCategory.everyday, icon: Icons.shopping_cart,
    primaryColor: AppColors.amber, modes: shoppingModes,
  ),
  ToolkitModule(
    id: 'earnings', name: 'Salary & Work',
    description: 'Convert gross pay, calculate overtime, commission, raises and shift hours.',
    category: CalculatorCategory.finance, icon: Icons.work,
    primaryColor: AppColors.emerald, modes: earningsModes,
  ),
  ToolkitModule(
    id: 'business', name: 'Business Pricing',
    description: 'Set selling prices by markup or gross margin and estimate break-even sales.',
    category: CalculatorCategory.finance, icon: Icons.store,
    primaryColor: AppColors.amber, modes: businessModes,
  ),
  ToolkitModule(
    id: 'budget', name: 'Savings & Budget',
    description: 'Estimate an emergency fund, savings timeline, debt-to-income and credit utilization.',
    category: CalculatorCategory.finance, icon: Icons.savings,
    primaryColor: AppColors.teal, modes: budgetModes,
  ),
  ToolkitModule(
    id: 'returns', name: 'Interest & Returns',
    description: 'Calculate simple interest, compound growth, CAGR, ROI and inflation-adjusted returns.',
    category: CalculatorCategory.finance, icon: Icons.trending_up,
    primaryColor: AppColors.emerald, modes: returnsModes,
  ),
  ToolkitModule(
    id: 'surfaces', name: 'Paint, Tile & Flooring',
    description: 'Estimate wall paint, flooring packs, tile quantities and waste for a rectangular room.',
    category: CalculatorCategory.construction, icon: Icons.format_paint,
    primaryColor: AppColors.purple, modes: surfacesModes,
  ),
  ToolkitModule(
    id: 'volume_materials', name: 'Concrete, Soil & Mulch',
    description: 'Estimate rectangular and circular fill volumes, bag counts and bulk material weight.',
    category: CalculatorCategory.construction, icon: Icons.landscape,
    primaryColor: AppColors.emerald, modes: volumeMaterialsModes,
  ),
  ToolkitModule(
    id: 'pace', name: 'Pace, Speed & Finish Time',
    description: 'Plan a run, walk or ride using distance, pace and elapsed time.',
    category: CalculatorCategory.health, icon: Icons.directions_run,
    primaryColor: AppColors.rose, modes: paceModes,
  ),
  ToolkitModule(
    id: 'power_cost', name: 'Energy & Battery',
    description: 'Estimate appliance electricity cost, battery runtime, watt-hours and amp-hours.',
    category: CalculatorCategory.everyday, icon: Icons.battery_charging_full,
    primaryColor: AppColors.amber, modes: powerCostModes,
  ),
  ToolkitModule(
    id: 'geometry', name: 'Areas & Solids',
    description: 'Find perimeter, area, diagonal, surface area and volume for common shapes.',
    category: CalculatorCategory.construction, icon: Icons.category,
    primaryColor: AppColors.cyan, modes: geometryModes,
  ),
  ToolkitModule(
    id: 'ratios', name: 'Ratios & Proportions',
    description: 'Scale recipes, split a total by ratio or find a missing proportional value.',
    category: CalculatorCategory.everyday, icon: Icons.balance,
    primaryColor: AppColors.teal, modes: ratiosModes,
  ),
  ToolkitModule(
    id: 'digital', name: 'File Size & Transfer',
    description: 'Estimate download duration, throughput and storage capacity in decimal or binary units.',
    category: CalculatorCategory.developer, icon: Icons.storage,
    primaryColor: AppColors.cyan, modes: digitalModes,
  ),
  ToolkitModule(
    id: 'training', name: 'Strength Training',
    description: 'Calculate workout volume, total repetitions and weight plates per side.',
    category: CalculatorCategory.health, icon: Icons.fitness_center,
    primaryColor: AppColors.purple, modes: trainingModes,
  ),
  ToolkitModule(
    id: 'circuits', name: 'Circuit Arithmetic',
    description: 'Explore DC voltage, current, resistance, power and unloaded voltage dividers.',
    category: CalculatorCategory.developer, icon: Icons.bolt,
    primaryColor: AppColors.amber, modes: circuitsModes,
  ),
  ToolkitModule(
    id: 'statistics', name: 'Statistics & Averages',
    description: 'Mean, median, mode, range, mean absolute deviation, weighted average, sample variance and standard deviation.',
    category: CalculatorCategory.everyday, icon: Icons.bar_chart,
    primaryColor: AppColors.teal, modes: statisticsModes,
  ),
  ToolkitModule(
    id: 'fractions', name: 'Fractions & Mixed Numbers',
    description: 'Add, subtract, multiply, divide and simplify exact fractions.',
    category: CalculatorCategory.everyday, icon: Icons.calculate,
    primaryColor: AppColors.cyan, modes: fractionsModes,
  ),
  ToolkitModule(
    id: 'integers', name: 'Integer Tools',
    description: 'Number bases, GCD, LCM, ratio reduction, factorial, permutations and combinations.',
    category: CalculatorCategory.developer, icon: Icons.code,
    primaryColor: AppColors.purple, modes: integersModes,
  ),
  ToolkitModule(
    id: 'calendar', name: 'Calendar & Unix Time',
    description: 'ISO week number, day of year, leap year and UTC epoch timestamps.',
    category: CalculatorCategory.everyday, icon: Icons.calendar_today,
    primaryColor: AppColors.teal, modes: calendarModes,
  ),
  ToolkitModule(
    id: 'writing', name: 'Word Count',
    description: 'Count words, characters, sentences and paragraphs',
    category: CalculatorCategory.everyday, icon: Icons.edit,
    primaryColor: AppColors.purple, modes: writingModes,
  ),
  ToolkitModule(
    id: 'shifts', name: 'Shift & Time Sheet',
    description: 'Calculate paid hours for overnight shifts, deduct breaks and convert decimal hours.',
    category: CalculatorCategory.everyday, icon: Icons.schedule,
    primaryColor: AppColors.amber, modes: shiftsModes,
  ),
];
