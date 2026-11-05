import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:omni_calc/screens/dashboard_screen.dart';
import 'package:omni_calc/core/providers/favorites_provider.dart';

void main() async {
  // Ensure widget binding is initialized before calling native async code
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
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
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          centerTitle: false,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.tealAccent,
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}