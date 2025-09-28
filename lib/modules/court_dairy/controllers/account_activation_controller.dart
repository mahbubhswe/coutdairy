import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/account_activation_service.dart';
import '../services/payment_service.dart';
import '../../../utils/app_config.dart';

class AccountActivationController extends GetxController {
  int get _configuredCharge => AppConfigService.config?.activationCharge ?? 0;
  int get _configuredValidity =>
      AppConfigService.config?.activationValidity ?? 0;

  /// Returns the yearly payable amount derived from the configured charge.
  ///
  /// If the backend provides a monthly charge (e.g. ৩০ দিনের জন্য ৯৯ টাকা),
  /// we convert it to a one-year equivalent so that the UI and payment flow
  /// always reflect a yearly plan as requested by the product requirements.
  int get annualActivationCharge {
    final charge = _configuredCharge;
    final validity = _configuredValidity;

    if (charge <= 0) return 0;
    if (validity <= 0) return charge;

    final perDayRate = charge / validity;
    final yearlyAmount = perDayRate * annualActivationValidity;
    return yearlyAmount.ceil();
  }

  /// The user can activate the account only for one year at a time.
  int get annualActivationValidity => 365;

  /// Backwards compatible aliases used by the UI layer.
  int get activationCharge => annualActivationCharge;
  int get activationValidity => annualActivationValidity;

  /// Raw configuration fetched from the backend, useful for audit labels.
  int get configuredCharge => _configuredCharge;
  int get configuredValidity => _configuredValidity;

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

  Future<void> activatePlan() async {
    if (annualActivationCharge <= 0) {
      Get.snackbar(
        'ত্রুটি',
        'অ্যাক্টিভেশন চার্জ কনফিগার করা হয়নি।',
        backgroundColor: Colors.white,
        colorText: Colors.red,
      );
      return;
    }

    final amount = annualActivationCharge.toDouble();
    final validity = annualActivationValidity;
    final success = await PaymentService.payNow(amount: amount);

    if (success) {
      try {
        await AccountActivationService.markAccountActivated(days: validity);
        Get.back();
        Get.snackbar(
          'সফল হয়েছে',
          '${_durationLabel(validity)} জন্য আপনার অ্যাকাউন্ট সক্রিয় হয়েছে।',
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

  String _durationLabel(int days) {
    if (days >= 365) {
      return 'এক বছরের';
    } else if (days >= 30) {
      return 'এক মাসের';
    } else if (days > 0) {
      return '${_toBanglaDigits(days.toString())} দিনের';
    }

    return 'সীমিত সময়ের';
  }

  String _toBanglaDigits(String value) {
    const englishToBangla = {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
    };

    return value
        .split('')
        .map((char) => englishToBangla[char] ?? char)
        .join();
  }

  @override
  void onClose() {
    _scrollTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }
}
