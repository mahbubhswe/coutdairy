import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/account_activation_service.dart';
import '../services/payment_service.dart';
import '../../../utils/app_config.dart';

class AccountActivationController extends GetxController {
  int get activationCharge => AppConfigService.config?.activationCharge ?? 0;

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

  Future<void> activateYearly() async {
    final amount = activationCharge.toDouble();
    final success = await PaymentService.payNow(amount: amount);

    if (success) {
      try {
        await AccountActivationService.markAccountActivated(days: 365);
        Get.back();
        Get.snackbar(
          'সফল হয়েছে',
          'এক বছরের জন্য আপনার অ্যাকাউন্ট সক্রিয় হয়েছে।',
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
