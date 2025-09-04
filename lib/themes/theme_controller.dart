import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/local_storage.dart';

class ThemeController extends GetxController {
  final _isDarkMode = true.obs; // default to dark mode

  /// Getter for current theme mode.
  bool get isDarkMode => _isDarkMode.value;
  ThemeMode get themeMode =>
      _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _loadTheme(); // Load saved theme preference
  }

  /// Toggle between Light and Dark mode and persist state.
  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    LocalStorageService.write("isDarkMode", _isDarkMode.value);
    Get.changeThemeMode(themeMode); // Efficiently update the theme
  }

  /// Load theme from storage.
  void _loadTheme() {
    bool? storedTheme = LocalStorageService.read("isDarkMode");
    _isDarkMode.value = storedTheme ?? true; // default to dark if unset
  }
}
