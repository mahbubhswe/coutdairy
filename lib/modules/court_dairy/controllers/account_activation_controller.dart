import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/account_activation_service.dart';
import '../services/payment_service.dart';
import '../../../utils/app_config.dart';

class AccountActivationController extends GetxController {
  int get monthlyCharge => AppConfigService.config?.activationCharge ?? 0;

  final ScrollController scrollController = ScrollController();
  Timer? _scrollTimer;

  @override
  void onInit() {
    super.onInit();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    const duration = Duration(milliseconds: 100); // slower interval
    const scrollStep = 0.5; // smaller pixel step

    _scrollTimer = Timer.periodic(duration, (timer) {
      if (!scrollController.hasClients) return;

      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.offset;

      if (currentScroll >= maxScroll) {
        scrollController.jumpTo(0);
      } else {
        scrollController.animateTo(
          currentScroll + scrollStep,
          duration: duration,
          curve: Curves.linear,
        );
      }
    });
  }

  Future<void> activateForMonths({required int months}) async {
    final double total;
    if (months == 6) {
      total = monthlyCharge * 6 * 0.90; // 10% off
    } else if (months == 12) {
      total = monthlyCharge * 12 * 0.75; // 25% off
    } else {
      total = monthlyCharge * months.toDouble();
    }

    final success = await PaymentService.payNow(amount: total);

    if (success) {
      try {
        await AccountActivationService.markAccountActivated(days: months * 30);
        Get.back();
        Get.snackbar(
          'সফল হয়েছে',
          '$months মাসের জন্য আপনার অ্যাকাউন্ট সক্রিয় হয়েছে।',
          backgroundColor: Colors.white,
          colorText: Colors.green,
        );
      } catch (e) {
        Get.snackbar(
          'ত্রুটি',
          'অ্যাকাউন্ট অ্যাক্টিভেট করতে সমস্যা হয়েছে।',
          backgroundColor: Colors.white,
          colorText: Colors.red,
        );
      }
    } else {
      Get.snackbar(
        'ব্যর্থ হয়েছে',
        'পেমেন্ট সফল হয়নি। আবার চেষ্টা করুন।',
        backgroundColor: Colors.white,
        colorText: Colors.red,
      );
    }
  }

  @override
  void onClose() {
    _scrollTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }
}
