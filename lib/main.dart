import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'modules/court_dairy/screens/splash_screen.dart';
import 'navigation/app_transitions.dart';
import 'services/app_initializer.dart';
import 'services/initial_bindings.dart';
import 'themes/theme_controller.dart';
import 'themes/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.initialize();

  // Optional but recommended for modern UI:
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Build a SystemUiOverlayStyle from the active ThemeData
  SystemUiOverlayStyle _overlayFor(ThemeData theme) {
    // Match the navigation bar color to the screen background
    final navColor = theme.scaffoldBackgroundColor;
    final navIconsBrightness =
        ThemeData.estimateBrightnessForColor(navColor) == Brightness.dark
            ? Brightness.light
            : Brightness.dark;

    return SystemUiOverlayStyle(
      // Status bar
      statusBarColor: Colors.transparent, // keeps content edge-to-edge
      statusBarIconBrightness: theme.brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
      statusBarBrightness: theme.brightness == Brightness.dark
          ? Brightness.dark
          : Brightness.light, // iOS

      // Android system navigation bar
      systemNavigationBarColor: navColor,
      systemNavigationBarIconBrightness: navIconsBrightness,
      systemNavigationBarDividerColor: Colors.transparent,

      // (Optional) disable extra contrast overlays so colors match your theme
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());

    return GetMaterialApp(
      title: 'Court Diary',
      debugShowCheckedModeBanner: false,
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      themeMode: themeController.themeMode,
      initialBinding: InitialBindings(),
      home: const SplashScreen(),
      // Apply shared-axis transitions to all Get routes
      customTransition:  SharedAxisCustomTransition(
        transitionType: SharedAxisTransitionType.horizontal,
      ),
      transitionDuration: const Duration(milliseconds: 300),

      // This runs on every build and after theme changes
      builder: (context, child) {
        final theme = Theme.of(context);
        SystemChrome.setSystemUIOverlayStyle(_overlayFor(theme));
        return child!;
      },
    );
  }
}
