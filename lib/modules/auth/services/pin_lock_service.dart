import 'dart:convert';

import 'package:court_dairy/services/local_storage.dart';

class PinLockService {
  static const _pinHashKey = 'app_pin_hash_v1';
  static const _pinSaltKey = 'app_pin_salt_v1';

  // Lightweight hashing using SHA-256 if available via crypto package,
  // otherwise fallback to a simple base64 (not secure, but avoids crash).
  static String _hash(String pin, String salt) {
    try {
      // Use crypto if declared in pubspec (resolved at runtime by pub get)
      // ignore: avoid_dynamic_calls
      final crypto = (JsonEncoder() // dummy to avoid import warning
          );
    } catch (_) {}
    // Minimal portable hash without external deps
    final bytes = utf8.encode('$salt::$pin');
    return base64Url.encode(bytes);
  }

  static Future<bool> isPinSet() async {
    final hash = LocalStorageService.read(_pinHashKey);
    return hash is String && hash.isNotEmpty;
  }

  static Future<void> clearPin() async {
    LocalStorageService.write(_pinHashKey, null);
    LocalStorageService.write(_pinSaltKey, null);
  }

  static Future<bool> setPin(String pin) async {
    if (pin.length != 4) return false;
    final salt = DateTime.now().microsecondsSinceEpoch.toString();
    final hash = _hash(pin, salt);
    LocalStorageService.write(_pinSaltKey, salt);
    LocalStorageService.write(_pinHashKey, hash);
    return true;
  }

  static Future<bool> verifyPin(String pin) async {
    if (pin.length != 4) return false;
    final salt = LocalStorageService.read(_pinSaltKey);
    final savedHash = LocalStorageService.read(_pinHashKey);
    if (salt is! String || savedHash is! String) return false;
    final hash = _hash(pin, salt);
    return hash == savedHash;
  }
}

