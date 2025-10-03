import 'package:flutter/material.dart';
import 'package:flutter_bkash/flutter_bkash.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class PaymentService {
  // Recreate the gateway per attempt so the plugin never reuses a stale token state.
  static FlutterBkash _createGateway() => FlutterBkash(
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
    final context = Get.context;
    if (context == null) {
      debugPrint('Unexpected Error: No active context available for bKash payment.');
      return false;
    }

    final merchantInvoiceNumber = _uuid.v1();

    Future<bool> attemptPayment() async {
      final gateway = _createGateway();
      final result = await gateway.pay(
        context: context,
        amount: amount,
        merchantInvoiceNumber: merchantInvoiceNumber,
      );

      return result.merchantInvoiceNumber == merchantInvoiceNumber;
    }

    try {
      return await attemptPayment();
    } catch (error) {
      if (_looksLikeTokenInitError(error)) {
        debugPrint('Bkash token state invalid, retrying: $error');
        try {
          return await attemptPayment();
        } catch (secondError) {
          return _handlePaymentError(secondError);
        }
      }

      return _handlePaymentError(error);
    }
  }

  static bool _looksLikeTokenInitError(Object error) =>
      error.runtimeType.toString() == 'LateInitializationError';

  static bool _handlePaymentError(Object error) {
    if (error is BkashFailure) {
      debugPrint('Bkash Failure: ${error.message}');
      return false;
    }

    debugPrint('Unexpected Error: $error');
    return false;
  }
}
