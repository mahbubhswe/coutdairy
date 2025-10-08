import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class Themes {
  // Brand palette (inspired by WhatsApp)
  static const Color _brandPrimary = Color(0xFF075E54);
  static const Color _brandSecondary = Color(0xFF00A884);

  // Light palette
  static const Color _lightBackground = Color(0xFFF0F2F5);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceVariant = Color(0xFFE5E8EB);
  static const Color _lightOnSurface = Color(0xFF111B21);
  static const Color _lightOnSurfaceVariant = Color(0xFF54656F);
  static const Color _lightOutline = Color(0xFFD1D7DB);
  static const Color _lightOutlineVariant = Color(0xFFBEC5CA);
  static const Color _lightInverseSurface = Color(0xFF1F2C34);

  // Dark palette
  static const Color _darkBackground = Color(0xFF0A1114);
  static const Color _darkSurface = Color(0xFF0F181B);
  static const Color _darkSurfaceVariant = Color(0xFF27343B);
  static const Color _darkOnSurface = Color(0xFFE9EDF1);
  static const Color _darkOnSurfaceVariant = Color(0xFF8696A0);
  static const Color _darkOutline = Color(0xFF2F3B41);
  static const Color _darkOutlineVariant = Color(0xFF3A4A53);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: _brandPrimary,
      onPrimary: Colors.white,
      primaryContainer: _brandSecondary,
      onPrimaryContainer: Colors.white,
      secondary: _brandSecondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFDCF5EB),
      onSecondaryContainer: _brandPrimary,
      tertiary: Color(0xFF3B4B54),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFD4E3E8),
      onTertiaryContainer: Color(0xFF1A2A32),
      error: Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      background: _lightBackground,
      onBackground: _lightOnSurface,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      surfaceVariant: _lightSurfaceVariant,
      onSurfaceVariant: _lightOnSurfaceVariant,
      outline: _lightOutline,
      outlineVariant: _lightOutlineVariant,
      shadow: Colors.black54,
      scrim: Colors.black54,
      inverseSurface: _lightInverseSurface,
      onInverseSurface: Colors.white,
      inversePrimary: _brandSecondary,
      surfaceTint: _brandPrimary,
    ),
    scaffoldBackgroundColor: _lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightBackground,
      foregroundColor: _lightOnSurface,
      elevation: 0.1,
      scrolledUnderElevation: 0.1,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black12,
      iconTheme: IconThemeData(color: _lightOnSurface),
      titleTextStyle: TextStyle(
        color: _lightOnSurface,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: _lightOnSurface,
      unselectedLabelColor: _lightOnSurfaceVariant,
      labelStyle: TextStyle(fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: _brandSecondary, width: 2.0),
      ),
      dividerColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      color: _lightSurface,
      shadowColor: Colors.black12,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 1.0, vertical: 2.0),
    ),
    inputDecorationTheme: _buildInputDecorationTheme(
      isDark: false,
      surface: _lightSurface,
      accent: _brandSecondary,
      onSurface: _lightOnSurface,
    ),
    elevatedButtonTheme: _buildElevatedButtonTheme(
      isDark: false,
      surface: _lightSurface,
      primary: _brandSecondary,
      onPrimary: Colors.white,
      onSurface: _lightOnSurface,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _brandPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _brandSecondary,
      foregroundColor: Colors.white,
      elevation: 3.0,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: _brandPrimary,
      selectionColor: Color(0x33111B21),
      selectionHandleColor: _brandSecondary,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      backgroundColor: _brandPrimary.withOpacity(0.92),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      showCloseIcon: true,
      closeIconColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeThroughPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeThroughPageTransitionsBuilder(),
        TargetPlatform.windows: FadeThroughPageTransitionsBuilder(),
        TargetPlatform.linux: FadeThroughPageTransitionsBuilder(),
      },
    ),
    textTheme: GoogleFonts.hindSiliguriTextTheme(),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: _brandSecondary,
      onPrimary: Colors.black,
      primaryContainer: _brandPrimary,
      onPrimaryContainer: Colors.white,
      secondary: _brandSecondary,
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF133029),
      onSecondaryContainer: Colors.white,
      tertiary: Color(0xFF3B4B54),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFF24313A),
      onTertiaryContainer: Colors.white,
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      errorContainer: Color(0xFF8C1D18),
      onErrorContainer: Color(0xFFF9DEDC),
      background: _darkBackground,
      onBackground: _darkOnSurface,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      surfaceVariant: _darkSurfaceVariant,
      onSurfaceVariant: _darkOnSurfaceVariant,
      outline: _darkOutline,
      outlineVariant: _darkOutlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: _lightSurface,
      onInverseSurface: _lightOnSurface,
      inversePrimary: _brandSecondary,
      surfaceTint: _brandSecondary,
    ),
    scaffoldBackgroundColor: _darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkBackground,
      foregroundColor: _darkOnSurface,
      elevation: 0.1,
      scrolledUnderElevation: 0.1,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      iconTheme: IconThemeData(color: _darkOnSurface),
      titleTextStyle: TextStyle(
        color: _darkOnSurface,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: _darkOnSurface,
      unselectedLabelColor: _darkOnSurfaceVariant,
      labelStyle: TextStyle(fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: _brandSecondary, width: 2.0),
      ),
      dividerColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      color: _darkSurface,
      shadowColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 1.0, vertical: 2.0),
    ),
    inputDecorationTheme: _buildInputDecorationTheme(
      isDark: true,
      surface: const Color(0xFF23282C),
      accent: _brandSecondary,
      onSurface: _darkOnSurface,
    ),
    elevatedButtonTheme: _buildElevatedButtonTheme(
      isDark: true,
      surface: _darkSurface,
      primary: _brandSecondary,
      onPrimary: Colors.black,
      onSurface: _darkOnSurface,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkOnSurface,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _brandSecondary,
      foregroundColor: Colors.black,
      elevation: 3.0,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: _brandSecondary,
      selectionColor: Color(0x331F2C34),
      selectionHandleColor: _brandSecondary,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      backgroundColor: _darkSurfaceVariant,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      showCloseIcon: true,
      closeIconColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeThroughPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeThroughPageTransitionsBuilder(),
        TargetPlatform.windows: FadeThroughPageTransitionsBuilder(),
        TargetPlatform.linux: FadeThroughPageTransitionsBuilder(),
      },
    ),
    textTheme: GoogleFonts.hindSiliguriTextTheme(
      ThemeData.dark().textTheme.apply(bodyColor: _darkOnSurface),
    ),
  );

  static InputDecorationTheme _buildInputDecorationTheme({
    required bool isDark,
    required Color surface,
    required Color accent,
    required Color onSurface,
  }) {
    final Color idleFill = Color.alphaBlend(
      accent.withOpacity(isDark ? 0.26 : 0.10),
      surface,
    );
    final Color focusFill = Color.alphaBlend(
      accent.withOpacity(isDark ? 0.38 : 0.16),
      surface,
    );

    OutlineInputBorder outline(double radius) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide.none,
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: idleFill,
      focusColor: focusFill,
      hoverColor: focusFill,
      border: outline(14),
      enabledBorder: outline(14),
      focusedBorder: outline(14),
      errorBorder: outline(14),
      focusedErrorBorder: outline(14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      labelStyle: TextStyle(
        color: onSurface.withOpacity(isDark ? 0.72 : 0.68),
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(color: onSurface.withOpacity(0.5)),
      prefixIconColor: onSurface.withOpacity(0.6),
      suffixIconColor: onSurface.withOpacity(0.6),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme({
    required bool isDark,
    required Color surface,
    required Color primary,
    required Color onPrimary,
    required Color onSurface,
  }) {
    final Color disabledBackground = Color.alphaBlend(
      onSurface.withOpacity(isDark ? 0.24 : 0.12),
      surface,
    );
    final Color pressedBackground = Color.alphaBlend(
      Colors.black.withOpacity(isDark ? 0.18 : 0.1),
      primary,
    );

    return ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(const Size.fromHeight(56)),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        elevation: MaterialStateProperty.all(0),
        textStyle: MaterialStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return disabledBackground;
          }
          if (states.contains(MaterialState.pressed)) {
            return pressedBackground;
          }
          return primary;
        }),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return onSurface.withOpacity(0.6);
          }
          return onPrimary;
        }),
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.black.withOpacity(isDark ? 0.14 : 0.08);
          }
          if (states.contains(MaterialState.hovered) ||
              states.contains(MaterialState.focused)) {
            return Colors.black.withOpacity(isDark ? 0.08 : 0.05);
          }
          return null;
        }),
      ),
    );
  }
}
