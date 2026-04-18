import 'package:flutter/material.dart';

class LavifyColors {
  static const Color background = Color(0xFF060B14);
  static const Color backgroundSoft = Color(0xFF0C1320);
  static const Color surface = Color(0xFF101827);
  static const Color surfaceAlt = Color(0xFF162033);
  static const Color panel = Color(0xCC0F1726);
  static const Color primary = Color(0xFF6AA8FF);
  static const Color primaryStrong = Color(0xFF3D7BFF);
  static const Color accent = Color(0xFF88D6FF);
  static const Color textPrimary = Color(0xFFF4F7FC);
  static const Color textSecondary = Color(0xFF8F9CB2);
  static const Color success = Color(0xFF34D39A);
  static const Color border = Color(0xFF24324A);

  static const Color lightBackground = Color(0xFFF3EEE7);
  static const Color lightSurface = Color(0xFFFFFBF7);
  static const Color lightSurfaceAlt = Color(0xFFF7F0E8);
  static const Color lightTextPrimary = Color(0xFF202938);
  static const Color lightTextSecondary = Color(0xFF7C736A);
  static const Color lightBorder = Color(0xFFE0D3C3);
  static const Color lightNavy = Color(0xFF314664);
  static const Color lightNavyStrong = Color(0xFF263754);
  static const Color lightGold = Color(0xFFD6B47B);
}

class LavifyTheme {
  static TextTheme _buildTextTheme({
    required Color headlineColor,
    required Color bodyColor,
    required Color labelColor,
  }) {
    return TextTheme(
      headlineLarge: TextStyle(
        inherit: true,
        fontSize: 56,
        fontWeight: FontWeight.w800,
        color: headlineColor,
        letterSpacing: -1.6,
        height: 0.94,
        backgroundColor: Colors.transparent,
        decorationColor: Colors.transparent,
      ),
      headlineMedium: TextStyle(
        inherit: true,
        fontSize: 31,
        fontWeight: FontWeight.w700,
        color: headlineColor,
        letterSpacing: -0.9,
        height: 1.04,
        backgroundColor: Colors.transparent,
        decorationColor: Colors.transparent,
      ),
      titleLarge: TextStyle(
        inherit: true,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: headlineColor,
        letterSpacing: -0.4,
        height: 1.08,
        backgroundColor: Colors.transparent,
        decorationColor: Colors.transparent,
      ),
      bodyLarge: TextStyle(
        inherit: true,
        fontSize: 16,
        height: 1.6,
        color: bodyColor,
        letterSpacing: 0,
        backgroundColor: Colors.transparent,
        decorationColor: Colors.transparent,
      ),
      bodyMedium: TextStyle(
        inherit: true,
        fontSize: 13.5,
        height: 1.55,
        color: bodyColor,
        letterSpacing: 0,
        backgroundColor: Colors.transparent,
        decorationColor: Colors.transparent,
      ),
      bodySmall: TextStyle(
        inherit: true,
        fontSize: 12.5,
        height: 1.4,
        color: bodyColor,
        letterSpacing: 0,
        backgroundColor: Colors.transparent,
        decorationColor: Colors.transparent,
      ),
      labelLarge: TextStyle(
        inherit: true,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: labelColor,
        letterSpacing: 0,
        height: 1.1,
        backgroundColor: Colors.transparent,
        decorationColor: Colors.transparent,
      ),
      labelSmall: TextStyle(
        inherit: true,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: labelColor,
        letterSpacing: 0.2,
        height: 1.1,
        backgroundColor: Colors.transparent,
        decorationColor: Colors.transparent,
      ),
    );
  }

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
        outline: const Color(0xFF2A3954),
      ),
      textTheme: _buildTextTheme(
        headlineColor: LavifyColors.textPrimary,
        bodyColor: LavifyColors.textSecondary,
        labelColor: LavifyColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        foregroundColor: LavifyColors.textPrimary,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xE30D1524),
        indicatorColor: const Color(0x1F6AA8FF),
        height: 72,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? LavifyColors.textPrimary
                : LavifyColors.textSecondary,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xCC101826),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: LavifyColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: LavifyColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: LavifyColors.primary, width: 1.2),
        ),
        hintStyle: const TextStyle(color: Color(0xFF68778F)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              foregroundColor: LavifyColors.textPrimary,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ).copyWith(
              animationDuration: const Duration(milliseconds: 120),
              splashFactory: NoSplash.splashFactory,
              overlayColor: const WidgetStatePropertyAll(Color(0x146AA8FF)),
              shadowColor: const WidgetStatePropertyAll(Colors.transparent),
              surfaceTintColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
              side: const BorderSide(color: LavifyColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              foregroundColor: LavifyColors.textPrimary,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ).copyWith(
              animationDuration: const Duration(milliseconds: 120),
              splashFactory: NoSplash.splashFactory,
              overlayColor: const WidgetStatePropertyAll(Color(0x106AA8FF)),
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
        primary: LavifyColors.lightNavy,
        secondary: LavifyColors.lightGold,
        surface: LavifyColors.lightSurface,
        outline: LavifyColors.lightBorder,
      ),
      textTheme: _buildTextTheme(
        headlineColor: LavifyColors.lightTextPrimary,
        bodyColor: LavifyColors.lightTextSecondary,
        labelColor: LavifyColors.lightTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        foregroundColor: LavifyColors.lightTextPrimary,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xF0314664),
        indicatorColor: const Color(0x26FFFFFF),
        height: 72,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? Colors.white
                : const Color(0xFFD6DDEA),
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xCCFFF8F0),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: LavifyColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: LavifyColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(
            color: LavifyColors.lightNavy,
            width: 1.2,
          ),
        ),
        hintStyle: const TextStyle(color: Color(0xFF8B7F73)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ).copyWith(
              animationDuration: const Duration(milliseconds: 120),
              splashFactory: NoSplash.splashFactory,
              overlayColor: const WidgetStatePropertyAll(Color(0x14314664)),
              shadowColor: const WidgetStatePropertyAll(Colors.transparent),
              surfaceTintColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
              side: const BorderSide(color: LavifyColors.lightBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              foregroundColor: LavifyColors.lightTextPrimary,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ).copyWith(
              animationDuration: const Duration(milliseconds: 120),
              splashFactory: NoSplash.splashFactory,
              overlayColor: const WidgetStatePropertyAll(Color(0x10314664)),
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

  static Color surfaceAltColor(BuildContext context) =>
      isLight(context) ? LavifyColors.lightSurfaceAlt : LavifyColors.surfaceAlt;

  static Color borderColor(BuildContext context) =>
      isLight(context) ? LavifyColors.lightBorder : LavifyColors.border;

  static Color textPrimaryColor(BuildContext context) => isLight(context)
      ? LavifyColors.lightTextPrimary
      : LavifyColors.textPrimary;

  static Color textSecondaryColor(BuildContext context) => isLight(context)
      ? LavifyColors.lightTextSecondary
      : LavifyColors.textSecondary;

  static Color softFillColor(BuildContext context) =>
      isLight(context) ? const Color(0xFFF9F2EA) : Colors.white.withAlpha(8);

  static Color softFillStrongColor(BuildContext context) =>
      isLight(context) ? const Color(0xFFF4ECE1) : Colors.white.withAlpha(6);

  static Color overlayPanelColor(BuildContext context) =>
      isLight(context) ? const Color(0xF7FFF8F2) : LavifyColors.panel;

  static Color navRailColor(BuildContext context) =>
      isLight(context) ? const Color(0xF1314664) : const Color(0xD20A101B);

  static Color navRailBorderColor(BuildContext context) =>
      isLight(context) ? const Color(0x667F91AB) : const Color(0x22FFFFFF);

  static Color navSelectedColor(BuildContext context) =>
      isLight(context) ? const Color(0x2CFFFFFF) : const Color(0x206AA8FF);

  static Color navInactiveColor(BuildContext context) => isLight(context)
      ? const Color(0xFFD9E0EA)
      : const Color(0xFFC0CADB);

  static Color selectedTileColor(BuildContext context) =>
      isLight(context) ? const Color(0x16314664) : const Color(0x266AA8FF);

  static Color selectedTileSoftColor(BuildContext context) =>
      isLight(context) ? const Color(0x14D6B47B) : Colors.white.withAlpha(7);

  static Color codePanelColor(BuildContext context) =>
      isLight(context) ? LavifyColors.lightNavyStrong : const Color(0xFF08111D);

  static Color codePanelTextColor(BuildContext context) =>
      isLight(context) ? const Color(0xFFF4F8FC) : LavifyColors.textPrimary;

  static BoxDecoration pageDecoration(BuildContext context) {
    if (isLight(context)) {
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7F1E8), Color(0xFFF2ECE3), Color(0xFFEDE5DA)],
        ),
      );
    }

    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF050911),
          Color(0xFF0A1220),
          Color(0xFF07101A),
        ],
      ),
    );
  }

  static LinearGradient premiumPanelGradient(BuildContext context) {
    if (isLight(context)) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFCF8), Color(0xFFF3ECE4)],
      );
    }

    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xD9162132),
        Color(0xCC0A101B),
      ],
    );
  }

  static LinearGradient subtleGlowGradient(BuildContext context) {
    if (isLight(context)) {
      return const LinearGradient(
        colors: [Color(0x22D6B47B), Color(0x10D6B47B)],
      );
    }

    return const LinearGradient(
      colors: [Color(0x286AA8FF), Color(0x08060812)],
    );
  }

  static List<BoxShadow> panelShadow(
    BuildContext context, {
    bool floating = true,
  }) {
    if (isLight(context)) {
      return [
        BoxShadow(
          color: const Color(0x181D2432),
          blurRadius: floating ? 36 : 22,
          offset: Offset(0, floating ? 16 : 9),
        ),
        BoxShadow(
          color: const Color(0x12FFFFFF),
          blurRadius: floating ? 14 : 8,
          spreadRadius: -2,
        ),
      ];
    }

    return [
      BoxShadow(
        color: const Color(0x50000000),
        blurRadius: floating ? 40 : 24,
        offset: Offset(0, floating ? 20 : 10),
      ),
      BoxShadow(
        color: const Color(0x126AA8FF),
        blurRadius: floating ? 30 : 16,
      ),
    ];
  }
}
