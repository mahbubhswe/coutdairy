
import 'package:court_dairy/constants/app_collections.dart';
import 'package:court_dairy/services/firebase_export.dart';
import 'package:court_dairy/services/local_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../services/app_firebase.dart';
import 'app_config.dart';

class AppSmsSender {
  static final Dio _dio = Dio();
  static final _firestore = AppFirebase().firestore;

  /// Validates if a string is a valid Bangladeshi phone number (11 digits, starts with 01)
  static bool _isValidBdPhone(String phone) {
    final regex = RegExp(r'^(?:\+?88)?01[3-9]\d{8}$');
    return regex.hasMatch(phone);
  }

  static Future<void> sendSms({
    required String phone,
    required double balance,
  }) async {
    final user = Get.find<AuthController>().user.value;
    if (user == null) {
      if (kDebugMode) print('User not logged in');
      return;
    }
    final config = AppConfigService.config;

    if (config == null) {
      if (kDebugMode) print('AppConfig not loaded');
      return;
    }

    if (!_isValidBdPhone(phone)) {
      if (kDebugMode) print('Invalid BD phone number: $phone');
      return;
    }

    final amount = NumberFormat("##,##,###", "bn").format(balance);
    final message = 'Your balance is BDT $amount';
    final apiKey = config.smsApiKey;
    final senderId = config.smsSenderId;
    final shopName = LocalStorageService.read('shopName') ?? '';
    final shopPhone = LocalStorageService.read('phone') ?? '';

    try {
      final response = await _dio.get(
        'https://bulksmsbd.net/api/smsapi',
        queryParameters: {
          'api_key': apiKey,
          'type': 'text',
          'number': '88$phone',
          'senderid': senderId,
          'message': '$message\n$shopName\n$shopPhone',
        },
      );

      final responseCode = response.data['response_code'];

      if (responseCode == 202) {
        await _firestore
            .collection(AppCollections.lawyers)
            .doc(user.uid)
            .update({
          'smsBalance': FieldValue.increment(-1),
        });
      } else {
        if (kDebugMode) {
          print('SMS failed: ${response.data}');
        }
        Get.snackbar('SMS', 'Failed to send message');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending SMS: $e');
      }
      Get.snackbar('SMS', 'Error while sending message');
    }
  }
}
