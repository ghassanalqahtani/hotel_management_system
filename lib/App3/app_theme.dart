import 'package:flutter/material.dart';

class AppColors {
  static const Color black = Color(0xFF1C1C1E);
  static const Color gold = Color(0xFFC9A24D);
  static const Color goldDark = Color(0xFF9A7B2F);
  static const Color goldLight = Color(0xFFFFF6E0);
  static const Color background = Color(0xFFF5F5F7);
  static const Color danger = Color(0xFFB3261E);
  static const Color shadow = Color(0x1A000000);
  static const Color goldBorder = Color(0x66C9A24D);
}

class AppTheme {
  static ThemeData get theme {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.black,
      onPrimary: Colors.white,
      secondary: AppColors.gold,
      onSecondary: AppColors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.gold,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.goldDark),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.black,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
      ),
    );
  }
}

AppBar buildAppBar(String title, {List<Widget>? actions}) {
  return AppBar(
    title: Text(title),
    centerTitle: true,
    backgroundColor: AppColors.black,
    foregroundColor: Colors.white,
    elevation: 0,
    actions: actions,
  );
}