import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/new_user_dailog.dart';
import '../../layout/screens/layout_screen.dart';
import '../screens/auth_view.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final _authService = AuthService();
  final email = TextEditingController();
  final password = TextEditingController();
  final Rxn<User> user = Rxn<User>();
  final RxBool isLoading = false.obs;
  final RxBool isNewUser = false.obs;
  final RxString error = ''.obs;
  RxBool enableBtn = false.obs;

  @override
  void onInit() {
    user.bindStream(_authService.authState());
    email.addListener(_validateForm);
    password.addListener(_validateForm);
    super.onInit();
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }

  bool get isLoggedIn => user.value != null;
  String get getUid => user.value!.uid;

  void _validateForm() {
    error.value = '';
    final isValidEmail =
        RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(email.text.trim());
    final isValidPassword = password.text.trim().length >= 6;
    enableBtn.value = isValidEmail && isValidPassword;
  }

  Future<void> login() async {
    _setLoading(true);
    try {
      await _authService.login(
          email: email.text.trim(), password: password.text.trim());
      Get.offAll(() => LayoutScreen());
    } catch (e) {
      _showError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        user.value = userCredential.user;
        isNewUser.value = userCredential.additionalUserInfo?.isNewUser ?? false;
        if (isNewUser.value) {
          showNewUserDialog();
        }
      } else {
        _showError("Google Sign-In canceled or failed");
      }
    } catch (e) {
      _showError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> forgotPassword() async {
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$')
        .hasMatch(email.text.trim())) {
      _showError("Please enter a valid Gmail address to reset password");
      return;
    }
    try {
      _setLoading(true);
      await _authService.sendPasswordResetEmail(email.text.trim());
      await openGmailApp();
      _setLoading(false);
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAll(() => const AuthScreen());
  }

  Future<void> openGmailApp() async {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: 'android.intent.category.APP_EMAIL',
        package: 'com.google.android.gm',
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
      );

      try {
        await intent.launch();
      } catch (e) {
        Get.snackbar("Error", "Could not open Gmail app.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.black);
      }
    } else if (Platform.isIOS) {
      // Try opening Gmail using URL scheme
      const gmailUrl = 'googlegmail://';
      if (await canLaunchUrl(Uri.parse(gmailUrl))) {
        await launchUrl(Uri.parse(gmailUrl));
      } else {
        // Fallback to mail app
        const mailtoUrl = 'mailto:';
        if (await canLaunchUrl(Uri.parse(mailtoUrl))) {
          await launchUrl(Uri.parse(mailtoUrl));
        } else {
          Get.snackbar("Error", "No email app found to open.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.black);
        }
      }
    }
  }

  // 🔕 No snackbar here
  void _showError(Object e) {
    error.value = e.toString().replaceAll('Exception:', '').trim();
  }

  void _setLoading(bool value) => isLoading.value = value;
}
