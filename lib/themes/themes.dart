import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';

class Themes {
  // WhatsApp colors (Light)
  static const Color _waLightPrimary   = Color(0xFF128C7E); // App bar green
  static const Color _waLightSecondary = Color(0xFF25D366); // CTA/FAB green
  static const Color _waLightTertiary  = Color(0xFF34B7F1); // Link blue
  static const Color _waLightBackground= Color(0xFFFFFFFF);
  static const Color _waLightSurface   = Color(0xFFFFFFFF);
  static const Color _waLightOutline   = Color(0xFFDBDBDB);

  // WhatsApp colors (Dark - matches screenshot)
  static const Color _waDarkBackground = Color(0xFF0B141A); // main bg
  static const Color _waDarkSurface    = Color(0xFF111B21); // cards/list rows
  static const Color _waDarkPrimary    = Color(0xFF0B141A); // app bar bg
  static const Color _waDarkSecondary  = Color(0xFF00A884); // action green
  static const Color _waDarkTertiary   = Color(0xFF53BDEB); // link blue
  static const Color _waDarkOutline    = Color(0xFF2A3942); // dividers

  // -------- LIGHT THEME --------
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _waLightPrimary,
      secondary: _waLightSecondary,
      background: _waLightBackground,
      surface: _waLightSurface,
      onSurface: Colors.black,
    ).copyWith(
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
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicatorColor: Colors.white,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
    ),
    cardTheme:const  CardThemeData(
      color: _waLightSurface,
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _waLightSecondary, foregroundColor: Colors.white)),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _waLightTertiary)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _waLightSecondary, foregroundColor: Colors.white, elevation: 2),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.black,
      selectionColor: Color(0x3325D366),
      selectionHandleColor: _waLightSecondary,
    ),
    dividerColor: _waLightOutline,
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: _waLightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _waLightOutline)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _waLightOutline)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _waLightSecondary, width: 2)),
    ),
    listTileTheme: const ListTileThemeData(iconColor: Colors.black87),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _waLightSurface, selectedItemColor: _waLightSecondary),
    dialogTheme: const DialogThemeData(backgroundColor: _waLightSurface),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
      TargetPlatform.iOS:     FadeThroughPageTransitionsBuilder(),
      TargetPlatform.macOS:   FadeThroughPageTransitionsBuilder(),
      TargetPlatform.windows: FadeThroughPageTransitionsBuilder(),
      TargetPlatform.linux:   FadeThroughPageTransitionsBuilder(),
    }),
    textTheme: GoogleFonts.hindSiliguriTextTheme(),
  );

  // -------- DARK THEME (WhatsApp 1:1) --------
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _waDarkPrimary,
      secondary: _waDarkSecondary,
      background: _waDarkBackground,
      surface: _waDarkSurface,
      onSurface: Colors.white,
    ).copyWith(
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
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
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
        borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      // WhatsApp style bright green CTA like "Link a device"
      style: ElevatedButton.styleFrom(
        backgroundColor: _waLightSecondary, // 25D366
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w700))),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _waDarkTertiary)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _waLightSecondary, foregroundColor: Colors.white, elevation: 2),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.white,
      selectionColor: Color(0x3300A884),
      selectionHandleColor: _waDarkSecondary,
    ),
    dividerColor: _waDarkOutline,
    listTileTheme: const ListTileThemeData(
      iconColor: Colors.white70,
      tileColor: _waDarkSurface,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _waDarkSurface,
      selectedItemColor: _waDarkSecondary,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed),
    dialogTheme: const DialogThemeData(backgroundColor: _waDarkSurface),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: _waDarkSurface,
      hintStyle: TextStyle(color: Colors.white70),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _waDarkOutline)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _waDarkOutline)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _waDarkSecondary, width: 2)),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => _waDarkSecondary.withOpacity(s.contains(WidgetState.selected) ? 1 : .6))),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(_waDarkSecondary),
      trackColor: WidgetStateProperty.all(_waDarkSecondary.withOpacity(.35))),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
      TargetPlatform.iOS:     FadeThroughPageTransitionsBuilder(),
      TargetPlatform.macOS:   FadeThroughPageTransitionsBuilder(),
      TargetPlatform.windows: FadeThroughPageTransitionsBuilder(),
      TargetPlatform.linux:   FadeThroughPageTransitionsBuilder(),
    }),
    textTheme: GoogleFonts.hindSiliguriTextTheme(ThemeData.dark().textTheme),
  );
}
