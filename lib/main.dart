// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:omni_calc/screens/dashboard_screen.dart';
import 'package:omni_calc/core/providers/favorites_provider.dart';
import 'package:omni_calc/core/theme/app_colors.dart';
import 'package:omni_calc/core/theme/app_theme_extension.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const OmniCalcApp(),
    ),
  );
}

class OmniCalcApp extends StatelessWidget {
  const OmniCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniCalc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.slate900,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.slate900,
          centerTitle: false,
        ),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.tealAccent,
          surface: AppColors.slate800,
        ),
        extensions: const <ThemeExtension<dynamic>>[
          OmniTheme.dark,
        ],
      ),
      home: const DashboardScreen(),
    );
  }
}