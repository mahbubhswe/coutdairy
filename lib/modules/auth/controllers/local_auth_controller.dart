import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../services/local_auth_service.dart';

class LocalAuthController extends GetxController with WidgetsBindingObserver {
  final isEnabled = false.obs;
  final isAuthenticated = true.obs;

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
      if (!success) return;
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
    final didAuth = await LocalAuthService.authenticate();
    isAuthenticated.value = didAuth;
    if (!didAuth) {
      SystemNavigator.pop();
    }
  }
}
