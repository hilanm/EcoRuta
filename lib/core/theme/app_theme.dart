import 'package:flutter/material.dart';

class AppColors {
  static const darkGreen = Color(0xFF1B5E20);
  static const green = Color(0xFF2E7D32);
  static const lightGreen = Color(0xFFA5D6A7);
  static const background = Color(0xFFF5F7F4);
  static const white = Color(0xFFFFFFFF);
  static const text = Color(0xFF263238);
  static const grey = Color(0xFF78909C);
  static const orange = Color(0xFFFF9800);
  static const shadow = Color(0x14000000);
  static const error = Color(0xFFB3261E);
}

class Gaps {
  static const double xs = 4, s = 8, m = 16, l = 24, xl = 32;
  static const double radius = 20;
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      secondary: AppColors.orange,
    ),
    scaffoldBackgroundColor: AppColors.background,
  );
  return base.copyWith(
    textTheme: base.textTheme
        .apply(bodyColor: AppColors.text, displayColor: AppColors.text),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.white,
      indicatorColor: AppColors.lightGreen,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
