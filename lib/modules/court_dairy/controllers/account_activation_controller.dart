import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/account_activation_service.dart';
import '../services/payment_service.dart';
import '../../../utils/app_config.dart';

class AccountActivationController extends GetxController {
  static const int _targetValidityDays = 365;

  int get _configuredActivationCharge =>
      AppConfigService.config?.activationCharge ?? 0;
  int get _configuredActivationValidity =>
      AppConfigService.config?.activationValidity ?? 0;

  /// Returns the activation charge normalised to a one year plan.
  ///
  /// The backend stores the base charge and validity (for example a monthly
  /// subscription). To make sure the user only activates the account for a
  /// full year, we convert that configuration to a yearly payment by
  /// multiplying the base charge with the number of periods that fit into a
  /// year. The multiplier is rounded to the nearest whole number so that
  /// monthly (≈30 days) configurations map cleanly to twelve months.
  int get activationCharge {
    final charge = _configuredActivationCharge;
    final validity = _configuredActivationValidity;

    if (charge <= 0) return 0;
    if (validity <= 0) return charge;

    final multiplier = (_targetValidityDays / validity).round();
    final safeMultiplier = multiplier < 1 ? 1 : multiplier;

    return charge * safeMultiplier;
  }

  /// Users can only activate their account for exactly one year at a time.
  int get activationValidity => _targetValidityDays;

  int get baseActivationCharge => _configuredActivationCharge;
  int get baseActivationValidity => _configuredActivationValidity;

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
    final amount = activationCharge.toDouble();
    final validity = activationValidity > 0 ? activationValidity : 30;
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
