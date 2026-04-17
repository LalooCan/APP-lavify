import 'package:flutter/material.dart';

class LavifyColors {
  static const Color background = Color(0xFF081120);
  static const Color surface = Color(0xFF111C31);
  static const Color surfaceAlt = Color(0xFF172742);
  static const Color primary = Color(0xFF5AC8FA);
  static const Color primaryStrong = Color(0xFF3478F6);
  static const Color textPrimary = Color(0xFFF8FBFF);
  static const Color textSecondary = Color(0xFF9DAFC5);
  static const Color success = Color(0xFF28D17C);
  static const Color border = Color(0xFF273754);

  static const Color lightBackground = Color(0xFFF3F6FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF7F9FD);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF66768F);
  static const Color lightBorder = Color(0xFFD8E0EC);
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
        outline: const Color(0xFF30415E),
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(
          fontSize: 54,
          fontWeight: FontWeight.w800,
          color: LavifyColors.textPrimary,
          letterSpacing: -1.4,
          height: 0.98,
        ),
        headlineMedium: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: LavifyColors.textPrimary,
          letterSpacing: -0.8,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: LavifyColors.textPrimary,
          letterSpacing: -0.4,
        ),
        bodyLarge: const TextStyle(
          fontSize: 17,
          height: 1.55,
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
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xF2111C31),
        indicatorColor: const Color(0x1F5AC8FA),
        height: 74,
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
        fillColor: const Color(0xFF16263F),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: LavifyColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: LavifyColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: LavifyColors.primary, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
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
        outline: LavifyColors.lightBorder,
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(
          fontSize: 54,
          fontWeight: FontWeight.w800,
          color: LavifyColors.lightTextPrimary,
          letterSpacing: -1.4,
          height: 0.98,
        ),
        headlineMedium: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: LavifyColors.lightTextPrimary,
          letterSpacing: -0.8,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: LavifyColors.lightTextPrimary,
          letterSpacing: -0.4,
        ),
        bodyLarge: const TextStyle(
          fontSize: 17,
          height: 1.55,
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
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xF6FFFFFF),
        indicatorColor: const Color(0x123478F6),
        height: 74,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? LavifyColors.lightTextPrimary
                : LavifyColors.lightTextSecondary,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F9FD),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: LavifyColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: LavifyColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: LavifyColors.primaryStrong,
            width: 1.2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
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
      isLight(context) ? const Color(0xFFF7F9FD) : Colors.white.withAlpha(10);

  static Color softFillStrongColor(BuildContext context) =>
      isLight(context) ? const Color(0xFFF1F5FB) : Colors.white.withAlpha(7);

  static Color overlayPanelColor(BuildContext context) =>
      isLight(context) ? const Color(0xF2FFFFFF) : const Color(0xD4141E32);

  static Color navRailColor(BuildContext context) =>
      isLight(context) ? const Color(0xEEFFFFFF) : const Color(0xD70D1728);

  static Color navRailBorderColor(BuildContext context) =>
      isLight(context) ? LavifyColors.lightBorder : const Color(0x1FFFFFFF);

  static Color navSelectedColor(BuildContext context) =>
      isLight(context) ? const Color(0x143478F6) : const Color(0x235AC8FA);

  static Color navInactiveColor(BuildContext context) => isLight(context)
      ? LavifyColors.lightTextSecondary
      : const Color(0xFFD6D1E8);

  static Color selectedTileColor(BuildContext context) =>
      isLight(context) ? const Color(0x162F6BFF) : const Color(0x331D5FFF);

  static Color selectedTileSoftColor(BuildContext context) =>
      isLight(context) ? const Color(0x1022C1FF) : Colors.white.withAlpha(8);

  static Color codePanelColor(BuildContext context) =>
      isLight(context) ? const Color(0xFF112033) : LavifyColors.background;

  static Color codePanelTextColor(BuildContext context) =>
      isLight(context) ? const Color(0xFFF4F8FC) : LavifyColors.textPrimary;

  static BoxDecoration pageDecoration(BuildContext context) {
    if (isLight(context)) {
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFD), Color(0xFFF1F5FB), Color(0xFFE9F0F9)],
        ),
      );
    }

    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF07101C), Color(0xFF10233F), Color(0xFF0A1322)],
      ),
    );
  }

  static List<BoxShadow> panelShadow(
    BuildContext context, {
    bool floating = true,
  }) {
    if (isLight(context)) {
      return [
        BoxShadow(
          color: const Color(0x120F172A),
          blurRadius: floating ? 38 : 24,
          offset: Offset(0, floating ? 18 : 10),
        ),
      ];
    }

    return [
      BoxShadow(
        color: const Color(0x28000000),
        blurRadius: floating ? 34 : 22,
        offset: Offset(0, floating ? 18 : 10),
      ),
    ];
  }
}
