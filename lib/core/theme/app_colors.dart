import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds & Surfaces (Slate Palette)
  static const Color slate900 = Color(0xFF0F172A); // App Background
  static const Color slate800 = Color(0xFF1E293B); // Cards / Sheet / Keypad
  static const Color slate700 = Color(0xFF334155); // Default Buttons / Borders
  static const Color slate600 = Color(0xFF475569); // Dividers / Inactive Tracks

  // Accents & Functional Colors
  static const Color tealAccent = Colors.tealAccent;
  static const Color purpleAccent = Colors.deepPurpleAccent;
  static const Color amberAccent = Colors.amberAccent;
  static const Color redAccent = Color(0xFFF87171);
  static const Color emeraldAccent = Color(0xFF34D399);

  // Keypad Containers & Tints
  static const Color operatorBgTeal = Color(0xFF1F4444);
  static const Color operatorBgPurple = Color(0xFF2E294E);
  static const Color clearBgRed = Color(0xFF3F2128);
  static const Color actionBg = Color(0xFF2B374A);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textMuted = Colors.white54;
}