import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum DateCalcMode {
  difference,
  offset,
}

class DateIntervalResult {
  final int years;
  final int months;
  final int days;
  final int totalDays;
  final int workingDays;
  final int weekendDays;
  final int totalHours;
  final int totalMinutes;

  const DateIntervalResult({
    required this.years,
    required this.months,
    required this.days,
    required this.totalDays,
    required this.workingDays,
    required this.weekendDays,
    required this.totalHours,
    required this.totalMinutes,
  });
}

class DateTimeIntervalState {
  final DateCalcMode mode;

  // Difference Mode fields
  final DateTime startDate;
  final DateTime endDate;
  final bool includeEndDay;

  // Offset Mode fields
  final DateTime baseDate;
  final bool isAddition;
  final int offsetYears;
  final int offsetMonths;
  final int offsetWeeks;
  final int offsetDays;

  const DateTimeIntervalState({
    required this.mode,
    required this.startDate,
    required this.endDate,
    this.includeEndDay = false,
    required this.baseDate,
    this.isAddition = true,
    this.offsetYears = 0,
    this.offsetMonths = 0,
    this.offsetWeeks = 0,
    this.offsetDays = 7,
  });

  DateIntervalResult get intervalDifference {
    DateTime start = DateTime(startDate.year, startDate.month, startDate.day);
    DateTime end = DateTime(endDate.year, endDate.month, endDate.day);

    if (start.isAfter(end)) {
      final temp = start;
      start = end;
      end = temp;
    }

    int totalDays = end.difference(start).inDays + (includeEndDay ? 1 : 0);

    // Calculate Working Days & Weekend Days
    int workingDays = 0;
    int weekendDays = 0;
    DateTime cursor = start;
    final int loopBound = includeEndDay ? totalDays : totalDays;

    for (int i = 0; i < loopBound; i++) {
      if (cursor.weekday == DateTime.saturday || cursor.weekday == DateTime.sunday) {
        weekendDays++;
      } else {
        workingDays++;
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    // Precise Calendar Years, Months, and Days
    int years = end.year - start.year;
    int months = end.month - start.month;
    int days = end.day - start.day;

    if (includeEndDay) {
      days += 1;
    }

    if (days < 0) {
      months -= 1;
      final prevMonthLastDay = DateTime(end.year, end.month, 0).day;
      days += prevMonthLastDay;
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    final totalHours = totalDays * 24;
    final totalMinutes = totalHours * 60;

    return DateIntervalResult(
      years: years,
      months: months,
      days: days,
      totalDays: totalDays,
      workingDays: workingDays,
      weekendDays: weekendDays,
      totalHours: totalHours,
      totalMinutes: totalMinutes,
    );
  }

  DateTime get calculatedOffsetDate {
    final factor = isAddition ? 1 : -1;
    var targetYear = baseDate.year + (offsetYears * factor);
    var targetMonth = baseDate.month + (offsetMonths * factor);

    while (targetMonth > 12) {
      targetMonth -= 12;
      targetYear++;
    }
    while (targetMonth < 1) {
      targetMonth += 12;
      targetYear--;
    }

    final maxDaysInTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    final targetDay = baseDate.day > maxDaysInTargetMonth ? maxDaysInTargetMonth : baseDate.day;

    DateTime intermediate = DateTime(targetYear, targetMonth, targetDay);
    final daysToAdd = (offsetWeeks * 7 + offsetDays) * factor;

    return intermediate.add(Duration(days: daysToAdd));
  }

  DateTimeIntervalState copyWith({
    DateCalcMode? mode,
    DateTime? startDate,
    DateTime? endDate,
    bool? includeEndDay,
    DateTime? baseDate,
    bool? isAddition,
    int? offsetYears,
    int? offsetMonths,
    int? offsetWeeks,
    int? offsetDays,
  }) {
    return DateTimeIntervalState(
      mode: mode ?? this.mode,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      includeEndDay: includeEndDay ?? this.includeEndDay,
      baseDate: baseDate ?? this.baseDate,
      isAddition: isAddition ?? this.isAddition,
      offsetYears: offsetYears ?? this.offsetYears,
      offsetMonths: offsetMonths ?? this.offsetMonths,
      offsetWeeks: offsetWeeks ?? this.offsetWeeks,
      offsetDays: offsetDays ?? this.offsetDays,
    );
  }
}

final dateTimeIntervalProvider =
    StateNotifierProvider.autoDispose<DateTimeIntervalNotifier, DateTimeIntervalState>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return DateTimeIntervalNotifier(
    DateTimeIntervalState(
      mode: DateCalcMode.difference,
      startDate: today,
      endDate: today.add(const Duration(days: 30)),
      baseDate: today,
    ),
  );
});

class DateTimeIntervalNotifier extends StateNotifier<DateTimeIntervalState> {
  DateTimeIntervalNotifier(super.initialState);

  void setMode(DateCalcMode mode) => state = state.copyWith(mode: mode);
  void setStartDate(DateTime date) => state = state.copyWith(startDate: date);
  void setEndDate(DateTime date) => state = state.copyWith(endDate: date);
  void toggleIncludeEndDay(bool value) => state = state.copyWith(includeEndDay: value);

  void setBaseDate(DateTime date) => state = state.copyWith(baseDate: date);
  void setIsAddition(bool value) => state = state.copyWith(isAddition: value);
  void setOffsetYears(int val) => state = state.copyWith(offsetYears: val);
  void setOffsetMonths(int val) => state = state.copyWith(offsetMonths: val);
  void setOffsetWeeks(int val) => state = state.copyWith(offsetWeeks: val);
  void setOffsetDays(int val) => state = state.copyWith(offsetDays: val);
}