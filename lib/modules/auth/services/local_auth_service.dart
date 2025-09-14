import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import '../../../services/local_storage.dart';

class LocalAuthService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const _key = 'local_auth_enabled';

  static bool isEnabled() {
    return LocalStorageService.read(_key) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    LocalStorageService.write(_key, value);
  }

  static Future<bool> isAvailable() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      return isSupported || canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final canCheck = isSupported || canCheckBiometrics;
      if (!canCheck) return false;
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LocalAuth authenticate() error: $e');
      }
      return false;
    }
  }
}
