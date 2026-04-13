import 'package:flutter/material.dart';

class LavifyColors {
  static const Color background = Color(0xFF09111F);
  static const Color surface = Color(0xFF101C31);
  static const Color surfaceAlt = Color(0xFF162845);
  static const Color primary = Color(0xFF22C1FF);
  static const Color primaryStrong = Color(0xFF2F6BFF);
  static const Color textPrimary = Color(0xFFF7FAFC);
  static const Color textSecondary = Color(0xFF9FB0C7);
  static const Color success = Color(0xFF28D17C);
  static const Color border = Color(0xFF243754);
}

class LavifyTheme {
  static ThemeData get theme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      scaffoldBackgroundColor: LavifyColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: LavifyColors.primary,
        secondary: LavifyColors.primaryStrong,
        surface: LavifyColors.surface,
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(
          fontSize: 52,
          fontWeight: FontWeight.w800,
          color: LavifyColors.textPrimary,
          height: 1.0,
        ),
        headlineMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: LavifyColors.textPrimary,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: LavifyColors.textPrimary,
        ),
        bodyLarge: const TextStyle(
          fontSize: 18,
          height: 1.6,
          color: LavifyColors.textSecondary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: LavifyColors.textSecondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        foregroundColor: LavifyColors.textPrimary,
        backgroundColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          foregroundColor: LavifyColors.textPrimary,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ).copyWith(
          animationDuration: const Duration(milliseconds: 90),
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Color(0x1422C1FF)),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          side: const BorderSide(color: LavifyColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          foregroundColor: LavifyColors.textPrimary,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          animationDuration: const Duration(milliseconds: 90),
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Color(0x1022C1FF)),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
    );
  }
}
