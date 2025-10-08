import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_config.dart';
import '../services/buy_sms_service.dart';
import '../services/payment_service.dart';

class BuySmsController extends GetxController {
  var smsCount = 32.obs;

  int get minSms => 32;
  int get maxSms => 320;
  int get step => 8;

  double get smsPrice => AppConfigService.config?.smsCharge ?? 0;

  double get totalPrice => smsCount.value * smsPrice;

  String get formattedSmsCount =>
      NumberFormat("##,##,###", "en").format(smsCount.value);

  String get formattedTotalPrice =>
      NumberFormat("##,##,###", "en").format(totalPrice);

  Future<void> buySms() async {
    final success = await PaymentService.payNow(
      amount: totalPrice,
    );

    if (success) {
      try {
        await BuySmsService.addSmsBalance(count: smsCount.value);
        Get.back();
        Get.snackbar(
          'Success',
          'SMS balance updated successfully',
          backgroundColor: Colors.white,
          colorText: Colors.green,
          duration: const Duration(seconds: 3),
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to update SMS balance',
          backgroundColor: Colors.white,
          colorText: Colors.red,
        );
      }
    } else {
      Get.snackbar(
        'Error',
        'Payment was not successful. Please try again.',
        backgroundColor: Colors.white,
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
