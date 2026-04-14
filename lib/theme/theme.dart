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

  static const Color lightBackground = Color(0xFFF4F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFE8F0FA);
  static const Color lightTextPrimary = Color(0xFF112033);
  static const Color lightTextSecondary = Color(0xFF5D718A);
  static const Color lightBorder = Color(0xFFD5E1EF);
}

class LavifyTheme {
  static ThemeData get darkTheme {
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
        style:
            ElevatedButton.styleFrom(
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
              surfaceTintColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
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
              surfaceTintColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      scaffoldBackgroundColor: LavifyColors.lightBackground,
      colorScheme: base.colorScheme.copyWith(
        primary: LavifyColors.primaryStrong,
        secondary: LavifyColors.primary,
        surface: LavifyColors.lightSurface,
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(
          fontSize: 52,
          fontWeight: FontWeight.w800,
          color: LavifyColors.lightTextPrimary,
          height: 1.0,
        ),
        headlineMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: LavifyColors.lightTextPrimary,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: LavifyColors.lightTextPrimary,
        ),
        bodyLarge: const TextStyle(
          fontSize: 18,
          height: 1.6,
          color: LavifyColors.lightTextSecondary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: LavifyColors.lightTextSecondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        foregroundColor: LavifyColors.lightTextPrimary,
        backgroundColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ).copyWith(
              animationDuration: const Duration(milliseconds: 90),
              splashFactory: NoSplash.splashFactory,
              overlayColor: const WidgetStatePropertyAll(Color(0x1422C1FF)),
              shadowColor: const WidgetStatePropertyAll(Colors.transparent),
              surfaceTintColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              side: const BorderSide(color: LavifyColors.lightBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              foregroundColor: LavifyColors.lightTextPrimary,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ).copyWith(
              animationDuration: const Duration(milliseconds: 90),
              splashFactory: NoSplash.splashFactory,
              overlayColor: const WidgetStatePropertyAll(Color(0x1022C1FF)),
              shadowColor: const WidgetStatePropertyAll(Colors.transparent),
              surfaceTintColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
            ),
      ),
    );
  }

  static bool isLight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light;

  static Color surfaceColor(BuildContext context) =>
      isLight(context) ? LavifyColors.lightSurface : LavifyColors.surface;

  static Color surfaceAltColor(BuildContext context) => isLight(context)
      ? LavifyColors.lightSurfaceAlt
      : LavifyColors.surfaceAlt;

  static Color borderColor(BuildContext context) =>
      isLight(context) ? LavifyColors.lightBorder : LavifyColors.border;

  static Color textPrimaryColor(BuildContext context) => isLight(context)
      ? LavifyColors.lightTextPrimary
      : LavifyColors.textPrimary;

  static Color textSecondaryColor(BuildContext context) => isLight(context)
      ? LavifyColors.lightTextSecondary
      : LavifyColors.textSecondary;

  static Color softFillColor(BuildContext context) => isLight(context)
      ? const Color(0xFFF1F6FD)
      : Colors.white.withAlpha(10);

  static Color softFillStrongColor(BuildContext context) => isLight(context)
      ? const Color(0xFFE3EEF9)
      : Colors.white.withAlpha(6);

  static Color overlayPanelColor(BuildContext context) => isLight(context)
      ? const Color(0xF7FFFFFF)
      : const Color(0xCC0E1A2C);

  static Color navRailColor(BuildContext context) => isLight(context)
      ? const Color(0xF8FFFFFF)
      : const Color(0xCC0C1627);

  static Color navRailBorderColor(BuildContext context) => isLight(context)
      ? LavifyColors.lightBorder
      : const Color(0x1FFFFFFF);

  static Color navSelectedColor(BuildContext context) => isLight(context)
      ? const Color(0x1622C1FF)
      : const Color(0x1F2CCBFF);

  static Color navInactiveColor(BuildContext context) => isLight(context)
      ? LavifyColors.lightTextSecondary
      : const Color(0xFFD6D1E8);

  static BoxDecoration pageDecoration(BuildContext context) {
    if (isLight(context)) {
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF7FBFF),
            Color(0xFFEAF3FF),
            Color(0xFFF4F8FC),
          ],
        ),
      );
    }

    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF07101D),
          Color(0xFF102446),
          Color(0xFF09111F),
        ],
      ),
    );
  }
}
