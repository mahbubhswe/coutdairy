import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/local_auth_service.dart';

class LocalAuthController extends GetxController with WidgetsBindingObserver {
  final isEnabled = false.obs;
  final isAuthenticated = true.obs;
  final isAuthenticating = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    isEnabled.value = LocalAuthService.isEnabled();
    if (isEnabled.value) {
      lock();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && isEnabled.value) {
      lock();
    }
  }

  Future<void> toggle(bool value) async {
    if (value) {
      final success = await LocalAuthService.authenticate();
      if (!success) {
        Get.snackbar(
          "ত্রুটি",
          "অথেন্টিকেশন ব্যর্থ হয়েছে।",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.black,
        );
        return;
      }
    }
    isEnabled.value = value;
    await LocalAuthService.setEnabled(value);
    if (value) {
      lock();
    }
  }

  void lock() {
    isAuthenticated.value = false;
    authenticate();
  }

  Future<void> authenticate() async {
    isAuthenticating.value = true;
    final didAuth = await LocalAuthService.authenticate();
    isAuthenticated.value = didAuth;
    isAuthenticating.value = false;
    if (!didAuth) {
      Get.snackbar(
        "ত্রুটি",
        "অথেন্টিকেশন ব্যর্থ হয়েছে।",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
  }
}
