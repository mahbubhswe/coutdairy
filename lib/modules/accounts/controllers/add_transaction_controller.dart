import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/transaction.dart';
import '../../../services/app_firebase.dart';
import '../services/transaction_service.dart';
import '../../../utils/activation_guard.dart';

class AddTransactionController extends GetxController {
  AddTransactionController({this.partyId});

  /// Optional: when opened from a Party, link the transaction
  final String? partyId;
  final RxnString type = RxnString();
  final amount = TextEditingController();
  final RxnString paymentMethod = RxnString();
  final note = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool enableBtn = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Set sensible defaults
    type.value = type.value ?? 'Deposit';
    paymentMethod.value = paymentMethod.value ?? 'Cash';
    amount.addListener(_validate);
    ever(type, (_) => _validate());
    ever(paymentMethod, (_) => _validate());
  }

  void _validate() {
    enableBtn.value =
        type.value != null &&
        amount.text.trim().isNotEmpty &&
        paymentMethod.value != null;
  }

  Future<bool> addTransaction() async {
    if (!enableBtn.value || isLoading.value) return false;
    if (!ActivationGuard.check()) return false;
    try {
      isLoading.value = true;
      final user = AppFirebase().currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      final transaction = Transaction(
        type: type.value!,
        amount: double.tryParse(amount.text.trim()) ?? 0,
        note: note.text.trim().isEmpty ? null : note.text.trim(),
        paymentMethod: paymentMethod.value!,
        createdAt: DateTime.now(),
        partyId: partyId,
      );

      await TransactionService.addTransaction(transaction, user.uid);
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    amount.dispose();
    note.dispose();
    super.onClose();
  }
}
