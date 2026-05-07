import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LavifyColors {
  // ── Dark palette ──
  static const Color background = Color(0xFF0A0B0F);
  static const Color backgroundSoft = Color(0xFF13141A);   // bgElev
  static const Color surface = Color(0xFF1A1C24);          // surf
  static const Color surfaceAlt = Color(0xFF22252F);       // surfElev
  static const Color panel = Color(0xF013141A);            // sheet — 95% bgElev

  // ── Primary blue ──
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryStrong = Color(0xFF1E5FE0);
  static const Color primarySoft = Color(0x243B82F6);      // 14% opacity
  static const Color primaryGlow = Color(0x593B82F6);      // 35% opacity
  static const Color accent = primary;                     // legacy alias

  // ── Dark text ──
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x9EFFFFFF);    // 62% white
  static const Color textMuted = Color(0x61FFFFFF);        // 38% white

  // ── Dark border ──
  static const Color border = Color(0x14FFFFFF);           // 8% white
  static const Color borderStrong = Color(0x23FFFFFF);     // 14% white

  // ── Status ──
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // ── Light palette ──
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF4F5F7);
  static const Color lightSurfaceAlt = Color(0xFFECEDF1);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0x9E000000); // 62% black
  static const Color lightTextMuted = Color(0x61000000);     // 38% black
  static const Color lightBorder = Color(0x14000000);        // 8% black
  static const Color lightBorderStrong = Color(0x23000000);  // 14% black
  static const Color lightSuccess = Color(0xFF059669);
  static const Color lightDanger = Color(0xFFDC2626);

  // ── Legacy light aliases ──
  static const Color lightNavy = Color(0xFF1E5FE0);
  static const Color lightNavyStrong = Color(0xFF1847B8);
  static const Color lightGold = Color(0xFFF59E0B);
}

class LavifyTheme {
  static TextTheme _buildTextTheme({
    required Color headlineColor,
    required Color bodyColor,
    required Color labelColor,
  }) {
    final raw = TextTheme(
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
    return GoogleFonts.interTextTheme(raw);
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
        outline: LavifyColors.border,
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
        backgroundColor: const Color(0xF013141A),
        indicatorColor: const Color(0x143B82F6),
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
        fillColor: LavifyColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: LavifyColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: LavifyColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: LavifyColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: LavifyColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: LavifyColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ).copyWith(
          animationDuration: const Duration(milliseconds: 120),
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Color(0x1A000000)),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
          side: const BorderSide(color: LavifyColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          foregroundColor: LavifyColors.textPrimary,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          animationDuration: const Duration(milliseconds: 120),
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Color(0x143B82F6)),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
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
        primary: LavifyColors.primary,
        secondary: LavifyColors.primaryStrong,
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
        backgroundColor: const Color(0xFFF4F5F7),
        indicatorColor: const Color(0x143B82F6),
        height: 72,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? LavifyColors.primary
                : LavifyColors.lightTextSecondary,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LavifyColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: LavifyColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: LavifyColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: LavifyColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: LavifyColors.lightTextMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ).copyWith(
          animationDuration: const Duration(milliseconds: 120),
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Color(0x1AFFFFFF)),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
          side: const BorderSide(color: LavifyColors.lightBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          foregroundColor: LavifyColors.lightTextPrimary,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          animationDuration: const Duration(milliseconds: 120),
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Color(0x143B82F6)),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
    );
  }

  // ── Helper methods ──

  static bool isLight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light;

  static Color surfaceColor(BuildContext context) =>
      isLight(context) ? LavifyColors.lightSurface : LavifyColors.surface;

  static Color surfaceAltColor(BuildContext context) =>
      isLight(context) ? LavifyColors.lightSurfaceAlt : LavifyColors.surfaceAlt;

  static Color borderColor(BuildContext context) =>
      isLight(context) ? LavifyColors.lightBorder : LavifyColors.border;

  static Color textPrimaryColor(BuildContext context) =>
      isLight(context) ? LavifyColors.lightTextPrimary : LavifyColors.textPrimary;

  static Color textSecondaryColor(BuildContext context) =>
      isLight(context) ? LavifyColors.lightTextSecondary : LavifyColors.textSecondary;

  static Color softFillColor(BuildContext context) =>
      isLight(context) ? const Color(0x143B82F6) : const Color(0x143B82F6);

  static Color softFillStrongColor(BuildContext context) =>
      isLight(context) ? const Color(0x1F3B82F6) : Colors.white.withAlpha(10);

  static Color overlayPanelColor(BuildContext context) =>
      isLight(context) ? const Color(0xFFFAFAFB) : LavifyColors.panel;

  static Color navRailColor(BuildContext context) =>
      isLight(context) ? const Color(0xFFF4F5F7) : const Color(0xF013141A);

  static Color navRailBorderColor(BuildContext context) =>
      isLight(context) ? LavifyColors.lightBorder : LavifyColors.border;

  static Color navSelectedColor(BuildContext context) =>
      isLight(context) ? const Color(0x143B82F6) : const Color(0x203B82F6);

  static Color navInactiveColor(BuildContext context) => isLight(context)
      ? LavifyColors.lightTextSecondary
      : LavifyColors.textSecondary;

  static Color selectedTileColor(BuildContext context) =>
      isLight(context) ? const Color(0x143B82F6) : const Color(0x203B82F6);

  static Color selectedTileSoftColor(BuildContext context) =>
      isLight(context) ? const Color(0x0F3B82F6) : Colors.white.withAlpha(7);

  static Color codePanelColor(BuildContext context) =>
      isLight(context) ? LavifyColors.lightNavyStrong : const Color(0xFF08111D);

  static Color codePanelTextColor(BuildContext context) =>
      isLight(context) ? const Color(0xFFF4F8FC) : LavifyColors.textPrimary;

  static BoxDecoration pageDecoration(BuildContext context) {
    return BoxDecoration(
      color: isLight(context) ? LavifyColors.lightBackground : LavifyColors.background,
    );
  }

  static LinearGradient premiumPanelGradient(BuildContext context) {
    if (isLight(context)) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFECEDF1), Color(0xFFF4F5F7)],
      );
    }

    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF22252F), Color(0xFF1A1C24)],
    );
  }

  static LinearGradient subtleGlowGradient(BuildContext context) {
    if (isLight(context)) {
      return const LinearGradient(
        colors: [Color(0x1F3B82F6), Color(0x0F3B82F6)],
      );
    }

    return const LinearGradient(
      colors: [Color(0x283B82F6), Color(0x080A0B0F)],
    );
  }

  static List<BoxShadow> panelShadow(
    BuildContext context, {
    bool floating = true,
  }) {
    if (isLight(context)) {
      return [
        BoxShadow(
          color: const Color(0x121D2432),
          blurRadius: floating ? 18 : 10,
          offset: Offset(0, floating ? 10 : 5),
        ),
      ];
    }

    return [
      BoxShadow(
        color: const Color(0x38000000),
        blurRadius: floating ? 20 : 12,
        offset: Offset(0, floating ? 12 : 6),
      ),
    ];
  }
}
