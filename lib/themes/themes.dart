import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';

class Themes {
  // WhatsApp colors
  // Light
  static const Color _waLightPrimary = Color(0xFF128C7E); // App bar green
  static const Color _waLightSecondary = Color(0xFF25D366); // FAB green
  static const Color _waLightTertiary = Color(0xFF34B7F1); // Link blue
  static const Color _waLightBackground = Color(0xFFFFFFFF);
  static const Color _waLightSurface = Color(0xFFFFFFFF);
  static const Color _waLightOutline = Color(0xFFDBDBDB);

  // Dark
  static const Color _waDarkBackground = Color(0xFF121B22);
  static const Color _waDarkSurface = Color(0xFF1F2C34);
  static const Color _waDarkPrimary = Color(0xFF1F2C34); // App bar bg
  static const Color _waDarkSecondary = Color(0xFF00A884); // Action green
  static const Color _waDarkTertiary = Color(0xFF53BDEB); // Link blue
  static const Color _waDarkOutline = Color(0xFF2A3942);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _waLightPrimary,
      secondary: _waLightSecondary,
      background: _waLightBackground,
    ).copyWith(
      surface: _waLightSurface,
      onSurface: Colors.black,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      tertiary: _waLightTertiary,
      onTertiary: Colors.white,
      outline: _waLightOutline,
      primaryContainer: _waLightPrimary,
      secondaryContainer: _waLightSecondary,
      tertiaryContainer: _waLightTertiary,
      onPrimaryContainer: Colors.white,
      onSecondaryContainer: Colors.white,
      onTertiaryContainer: Colors.white,
    ),
    scaffoldBackgroundColor: _waLightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: _waLightPrimary,
      foregroundColor: Colors.white,
      elevation: 0.0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicatorColor: Colors.white,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      color: _waLightSurface,
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _waLightSecondary,
        foregroundColor: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        // Make dialog/action buttons clearly visible on light background
        foregroundColor: _waLightTertiary,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _waLightSecondary,
      foregroundColor: Colors.white,
      elevation: 2.0,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.black,
      selectionColor: Color(0x3325D366),
      selectionHandleColor: _waLightSecondary,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android:
          FadeThroughPageTransitionsBuilder(),
      TargetPlatform.iOS:
          FadeThroughPageTransitionsBuilder(),
      TargetPlatform.macOS:
          FadeThroughPageTransitionsBuilder(),
      TargetPlatform.windows:
          FadeThroughPageTransitionsBuilder(),
      TargetPlatform.linux:
          FadeThroughPageTransitionsBuilder(),
    }),
    textTheme: GoogleFonts.hindSiliguriTextTheme(),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _waDarkPrimary,
      secondary: _waDarkSecondary,
      background: _waDarkBackground,
    ).copyWith(
      surface: _waDarkSurface,
      onSurface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      tertiary: _waDarkTertiary,
      onTertiary: Colors.black,
      outline: _waDarkOutline,
      primaryContainer: _waDarkPrimary,
      secondaryContainer: _waDarkSecondary,
      tertiaryContainer: _waDarkTertiary,
      onPrimaryContainer: Colors.white,
      onSecondaryContainer: Colors.white,
      onTertiaryContainer: Colors.black,
    ),
    scaffoldBackgroundColor: _waDarkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: _waDarkPrimary,
      foregroundColor: Colors.white,
      elevation: 0.0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicatorColor: Colors.white,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      color: _waDarkSurface,
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _waDarkSecondary,
        foregroundColor: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        // Ensure Cancel/OK in dialogs & pickers are readable on dark surface
        foregroundColor: _waDarkTertiary,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _waDarkSecondary,
      foregroundColor: Colors.white,
      elevation: 2.0,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.white,
      selectionColor: Color(0x3300A884),
      selectionHandleColor: _waDarkSecondary,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android:
          FadeThroughPageTransitionsBuilder(),
      TargetPlatform.iOS:
          FadeThroughPageTransitionsBuilder(),
      TargetPlatform.macOS:
          FadeThroughPageTransitionsBuilder(),
      TargetPlatform.windows:
          FadeThroughPageTransitionsBuilder(),
      TargetPlatform.linux:
          FadeThroughPageTransitionsBuilder(),
    }),
    textTheme: GoogleFonts.hindSiliguriTextTheme(ThemeData.dark().textTheme),
  );
}
