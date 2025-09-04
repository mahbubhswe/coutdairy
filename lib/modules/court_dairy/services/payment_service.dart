import 'package:flutter/material.dart';
import 'package:flutter_bkash/flutter_bkash.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class PaymentService {
  static final FlutterBkash _bkash = FlutterBkash(
    bkashCredentials: const BkashCredentials(
      username: '01607415159',
      password: 'pJez!)58xD>',
      appKey: 'ms9YsMA6JHUH3D9V1BWuQm9ltc',
      appSecret: 'RJJZCZ75XxkGZGA5eFmLVju63y1KkLwZrrEJaKjX13Y07qiXARVS',
      isSandbox: false,
    ),
  );

  static final Uuid _uuid = const Uuid();

  static Future<bool> payNow({
    required double amount,
  }) async {
    final String merchantInvoiceNumber = _uuid.v1();

    try {
      final result = await _bkash.pay(
        context:Get.context!,
        amount: amount,
        merchantInvoiceNumber: merchantInvoiceNumber,
      );

      if (result.merchantInvoiceNumber == merchantInvoiceNumber) {
        return true;
      }
      return false;
    } on BkashFailure catch (e) {
      debugPrint("Bkash Failure: ${e.message}");
      return false;
    } catch (e) {
      debugPrint("Unexpected Error: $e");
      return false;
    }
  }
}
