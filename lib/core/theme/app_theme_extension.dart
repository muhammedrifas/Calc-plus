import 'package:flutter/material.dart';
import 'app_colors.dart';

class OmniTheme extends ThemeExtension<OmniTheme> {
  final Color scaffoldBg;
  final Color surfaceBg;
  final Color cardBg;
  final Color buttonDefaultBg;
  final Color buttonClearBg;
  final Color buttonActionBg;

  // Module Accents
  final Color basicMathAccent;
  final Color scientificAccent;
  final Color loanEmiAccent;
  final Color investmentAccent; 

  const OmniTheme({
    required this.scaffoldBg,
    required this.surfaceBg,
    required this.cardBg,
    required this.buttonDefaultBg,
    required this.buttonClearBg,
    required this.buttonActionBg,
    required this.basicMathAccent,
    required this.scientificAccent,
    required this.loanEmiAccent,
    required this.investmentAccent,
  });

  static const dark = OmniTheme(
    scaffoldBg: AppColors.slate900,
    surfaceBg: AppColors.slate800,
    cardBg: AppColors.slate800,
    buttonDefaultBg: AppColors.slate700,
    buttonClearBg: AppColors.clearBgRed,
    buttonActionBg: AppColors.actionBg,
    basicMathAccent: AppColors.tealAccent,
    scientificAccent: AppColors.purpleAccent,
    loanEmiAccent: AppColors.amberAccent,
    investmentAccent: AppColors.emeraldAccent,
  );

  @override
  OmniTheme copyWith({
    Color? scaffoldBg,
    Color? surfaceBg,
    Color? cardBg,
    Color? buttonDefaultBg,
    Color? buttonClearBg,
    Color? buttonActionBg,
    Color? basicMathAccent,
    Color? scientificAccent,
    Color? loanEmiAccent,
    Color? investmentAccent,
  }) {
    return OmniTheme(
      scaffoldBg: scaffoldBg ?? this.scaffoldBg,
      surfaceBg: surfaceBg ?? this.surfaceBg,
      cardBg: cardBg ?? this.cardBg,
      buttonDefaultBg: buttonDefaultBg ?? this.buttonDefaultBg,
      buttonClearBg: buttonClearBg ?? this.buttonClearBg,
      buttonActionBg: buttonActionBg ?? this.buttonActionBg,
      basicMathAccent: basicMathAccent ?? this.basicMathAccent,
      scientificAccent: scientificAccent ?? this.scientificAccent,
      loanEmiAccent: loanEmiAccent ?? this.loanEmiAccent,
      investmentAccent: investmentAccent ?? this.investmentAccent,
    );
  }

  @override
  OmniTheme lerp(ThemeExtension<OmniTheme>? other, double t) {
    if (other is! OmniTheme) return this;
    return OmniTheme(
      scaffoldBg: Color.lerp(scaffoldBg, other.scaffoldBg, t)!,
      surfaceBg: Color.lerp(surfaceBg, other.surfaceBg, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      buttonDefaultBg: Color.lerp(buttonDefaultBg, other.buttonDefaultBg, t)!,
      buttonClearBg: Color.lerp(buttonClearBg, other.buttonClearBg, t)!,
      buttonActionBg: Color.lerp(buttonActionBg, other.buttonActionBg, t)!,
      basicMathAccent: Color.lerp(basicMathAccent, other.basicMathAccent, t)!,
      scientificAccent: Color.lerp(scientificAccent, other.scientificAccent, t)!,
      loanEmiAccent: Color.lerp(loanEmiAccent, other.loanEmiAccent, t)!,
      investmentAccent: Color.lerp(investmentAccent, other.investmentAccent, t)!,
    );
  }
}

extension OmniThemeContext on BuildContext {
  OmniTheme get omniTheme => Theme.of(this).extension<OmniTheme>() ?? OmniTheme.dark;
}