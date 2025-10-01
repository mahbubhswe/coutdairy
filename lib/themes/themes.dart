import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class Themes {
  // ===== Colors derived from your FIRST theme =====
  // Light
  static const Color _lightBackground = Colors.white;
  static const Color _lightSurface = Colors.white;
  static const Color _lightOnSurface = Colors.black;
  static const Color _lightPrimary = Colors.black; // e.g. indicators/icons
  static const Color _lightSecondary = AppColors.fixedPrimary; // FAB / CTA
  static const Color _lightOutline = Colors.black26;

  // Dark
  // Inspired by Google's dark theme color palette
  static const Color _darkBackground = Color(0xFF202124);
  static const Color _darkSurface = Color(0xFF303134); // surface containers
  static const Color _darkOnSurface = Color(0xFFE8EAED); // primary text color
  static const Color _darkPrimary = Color(0xFFE8EAED); // indicators/icons
  static const Color _darkSecondary =
      AppColors.fixedPrimary; // brand for FAB/CTA
  static const Color _darkOutline = Color(0xFF5F6368);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _lightPrimary,
      secondary: _lightSecondary,
      background: _lightBackground,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      outline: _lightOutline,
    ),
    scaffoldBackgroundColor: _lightBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0.1,
      scrolledUnderElevation: 0.1,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      labelStyle: TextStyle(fontWeight: FontWeight.w400),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: Colors.black, width: 2.0),
      ),

      dividerColor: Colors.transparent,
    ),

    cardTheme: const CardThemeData(
      color: Colors.white,
      shadowColor: Colors.black26,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 1.0, vertical: 2.0),
    ),

    inputDecorationTheme: _buildInputDecorationTheme(
      isDark: false,
      surface: _lightSurface,
      accent: _lightSecondary,
      onSurface: _lightOnSurface,
    ),
    elevatedButtonTheme: _buildElevatedButtonTheme(
      isDark: false,
      surface: _lightSurface,
      primary: _lightSecondary,
      onPrimary: Colors.white,
      onSurface: _lightOnSurface,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _lightSecondary, // AppColors.fixedPrimary
      foregroundColor: Colors.white,
      elevation: 3.0,
    ),

    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.black,
      selectionColor: Color(0x33212121),
      selectionHandleColor: _lightSecondary,
    ),

    // Note: Flutter ThemeData does not have `dropdownButtonTheme`.
    // Per-widget styling handled via wrappers and InputDecoration.
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      backgroundColor: Colors.black87,
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
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimary,
      secondary: _darkSecondary,
      background: _darkBackground,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      outline: _darkOutline,
    ),
    scaffoldBackgroundColor: _darkBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor: _darkBackground,
      foregroundColor: _darkOnSurface,
      elevation: 0.1,
      scrolledUnderElevation: 0.1,
      surfaceTintColor: Colors.transparent,
      shadowColor: _darkOutline,
      iconTheme: IconThemeData(color: _darkOnSurface),
      titleTextStyle: TextStyle(
        color: _darkOnSurface,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    tabBarTheme: const TabBarThemeData(
      labelColor: _darkOnSurface,
      unselectedLabelColor: Color(0xFF9AA0A6),
      labelStyle: TextStyle(fontWeight: FontWeight.w400),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: _darkOnSurface, width: 2.0),
      ),
      dividerColor: Colors.transparent,
    ),

    cardTheme: const CardThemeData(
      color: _darkSurface,
      shadowColor: Colors.black54,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 1.0, vertical: 2.0),
    ),

    inputDecorationTheme: _buildInputDecorationTheme(
      isDark: true,
      surface: _darkSurface,
      accent: _darkSecondary,
      onSurface: _darkOnSurface,
    ),
    elevatedButtonTheme: _buildElevatedButtonTheme(
      isDark: true,
      surface: _darkSurface,
      primary: _darkSecondary,
      onPrimary: Colors.white,
      onSurface: _darkOnSurface,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkOnSurface,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _darkSecondary,
      foregroundColor: Colors.white,
      elevation: 3.0,
    ),

    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: _darkSecondary,
      selectionColor: Color(0x338AB4F8),
      selectionHandleColor: _darkSecondary,
    ),

    // Note: Flutter ThemeData does not have `dropdownButtonTheme`.
    // Per-widget styling handled via wrappers and InputDecoration.
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      backgroundColor: const Color(0xFF2C2D30),
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

    textTheme: GoogleFonts.hindSiliguriTextTheme(ThemeData.dark().textTheme),
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      labelStyle: TextStyle(
        color: onSurface.withOpacity(isDark ? 0.72 : 0.68),
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: onSurface.withOpacity(0.5),
      ),
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
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        elevation: MaterialStateProperty.all(0),
        textStyle: MaterialStateProperty.all(
          const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
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
