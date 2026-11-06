import 'package:flutter/material.dart';
import 'app_colors.dart';

class OmniTheme extends ThemeExtension<OmniTheme> {
  // Surfaces
  final Color scaffoldBg;
  final Color surface;
  final Color cardBg;
  final Color divider;

  // Semantic Accents
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color error;

  // Keypad & Controls
  final Color keypadSurface;
  final Color keypadDefault;
  final Color keypadOperator;
  final Color keypadAction;
  final Color keypadClear;

  // Charts & Comparisons
  final Color chartPrimary;
  final Color chartSecondary;
  final Color chartTertiary;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  const OmniTheme({
    required this.scaffoldBg,
    required this.surface,
    required this.cardBg,
    required this.divider,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.error,
    required this.keypadSurface,
    required this.keypadDefault,
    required this.keypadOperator,
    required this.keypadAction,
    required this.keypadClear,
    required this.chartPrimary,
    required this.chartSecondary,
    required this.chartTertiary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
  });

  static const dark = OmniTheme(
    scaffoldBg: AppColors.slate950,
    surface: AppColors.slate900,
    cardBg: AppColors.slate900,
    divider: AppColors.slate700,
    primary: AppColors.teal,
    secondary: AppColors.cyan,
    tertiary: AppColors.purple,
    error: AppColors.rose,
    keypadSurface: AppColors.slate900,
    keypadDefault: AppColors.slate800,
    keypadOperator: AppColors.operatorBg,
    keypadAction: AppColors.actionBg,
    keypadClear: AppColors.clearBg,
    chartPrimary: AppColors.teal,
    chartSecondary: AppColors.amber,
    chartTertiary: AppColors.purple,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
  );

  @override
  OmniTheme copyWith({
    Color? scaffoldBg,
    Color? surface,
    Color? cardBg,
    Color? divider,
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? error,
    Color? keypadSurface,
    Color? keypadDefault,
    Color? keypadOperator,
    Color? keypadAction,
    Color? keypadClear,
    Color? chartPrimary,
    Color? chartSecondary,
    Color? chartTertiary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
  }) {
    return OmniTheme(
      scaffoldBg: scaffoldBg ?? this.scaffoldBg,
      surface: surface ?? this.surface,
      cardBg: cardBg ?? this.cardBg,
      divider: divider ?? this.divider,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      error: error ?? this.error,
      keypadSurface: keypadSurface ?? this.keypadSurface,
      keypadDefault: keypadDefault ?? this.keypadDefault,
      keypadOperator: keypadOperator ?? this.keypadOperator,
      keypadAction: keypadAction ?? this.keypadAction,
      keypadClear: keypadClear ?? this.keypadClear,
      chartPrimary: chartPrimary ?? this.chartPrimary,
      chartSecondary: chartSecondary ?? this.chartSecondary,
      chartTertiary: chartTertiary ?? this.chartTertiary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
    );
  }

  @override
  OmniTheme lerp(ThemeExtension<OmniTheme>? other, double t) {
    if (other is! OmniTheme) return this;
    return OmniTheme(
      scaffoldBg: Color.lerp(scaffoldBg, other.scaffoldBg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      error: Color.lerp(error, other.error, t)!,
      keypadSurface: Color.lerp(keypadSurface, other.keypadSurface, t)!,
      keypadDefault: Color.lerp(keypadDefault, other.keypadDefault, t)!,
      keypadOperator: Color.lerp(keypadOperator, other.keypadOperator, t)!,
      keypadAction: Color.lerp(keypadAction, other.keypadAction, t)!,
      keypadClear: Color.lerp(keypadClear, other.keypadClear, t)!,
      chartPrimary: Color.lerp(chartPrimary, other.chartPrimary, t)!,
      chartSecondary: Color.lerp(chartSecondary, other.chartSecondary, t)!,
      chartTertiary: Color.lerp(chartTertiary, other.chartTertiary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
    );
  }
}

extension OmniThemeContext on BuildContext {
  OmniTheme get omniTheme => Theme.of(this).extension<OmniTheme>() ?? OmniTheme.dark;
}