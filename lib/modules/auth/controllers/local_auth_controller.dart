import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/local_auth_service.dart';
import '../services/pin_lock_service.dart';
import '../screens/app_lock_screen.dart';

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
      // PIN-only mode: ensure a PIN exists or create one
      final pinSet = await PinLockService.isPinSet();
      bool ok = pinSet;
      if (!pinSet) {
        final created = await Get.to(() => const AppLockScreen(setupMode: true));
        ok = created == true;
      }
      if (!ok) {
        Get.snackbar(
          'অথেন্টিকেশন ব্যর্থ হয়েছে',
          'লক চালু করতে একটি অ্যাপ পিন সেট করুন।',
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
    bool didAuth = false;
    final pinSet = await PinLockService.isPinSet();
    if (pinSet) {
      final unlocked = await Get.to(() => const AppLockScreen());
      didAuth = unlocked == true;
    }
    isAuthenticated.value = didAuth;
    isAuthenticating.value = false;
    if (!didAuth) {
      Get.snackbar(
        'অথেন্টিকেশন ব্যর্থ হয়েছে',
        'আনলক করতে সেটিংস থেকে অ্যাপ পিন সেট করুন।',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
  }
}
