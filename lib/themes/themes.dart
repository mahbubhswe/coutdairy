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
  static const Color _darkSecondary = Color(0xFF8AB4F8); // accent for FAB/CTA
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

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightSecondary,
        foregroundColor: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colors.black),
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
      onSecondary: Colors.black,
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
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: _darkSecondary, width: 2.0),
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

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkSecondary,
        foregroundColor: _darkBackground,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _darkSecondary),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _darkSecondary,
      foregroundColor: _darkBackground,
      elevation: 3.0,
    ),

    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: _darkSecondary,
      selectionColor: Color(0x338AB4F8),
      selectionHandleColor: _darkSecondary,
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
}
