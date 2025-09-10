import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'modules/auth/controllers/auth_controller.dart';
import 'modules/auth/controllers/local_auth_controller.dart';
import 'modules/auth/screens/auth_view.dart';
import 'modules/layout/screens/layout_screen.dart';
import 'navigation/app_transitions.dart';
import 'services/app_initializer.dart';
import 'services/initial_bindings.dart';
import 'themes/theme_controller.dart';
import 'themes/themes.dart';
import 'utils/exact_alarm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.initialize();

  // Optional but recommended for modern UI:
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static bool _askedExactAlarmOnce = false;

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
      home: const _AuthGate(),
      // Apply shared-axis transitions to all Get routes
      customTransition:  SharedAxisCustomTransition(
        transitionType: SharedAxisTransitionType.horizontal,
      ),
      transitionDuration: const Duration(milliseconds: 300),

      // This runs on every build and after theme changes
      builder: (context, child) {
        final theme = Theme.of(context);
        SystemChrome.setSystemUIOverlayStyle(_overlayFor(theme));
        if (!_askedExactAlarmOnce) {
          _askedExactAlarmOnce = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            askForExactAlarmPermissionIfNeeded();
          });
        }
        return child!;
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final localAuth = Get.find<LocalAuthController>();
    return Obx(() {
      if (auth.user.value != null) {
        if (localAuth.isEnabled.value && !localAuth.isAuthenticated.value) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return LayoutScreen();
      } else {
        return const AuthScreen();
      }
    });
  }
}
