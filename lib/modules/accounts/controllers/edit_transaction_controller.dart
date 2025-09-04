import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/transaction.dart';
import '../../../services/app_firebase.dart';
import '../../../utils/activation_guard.dart';
import '../services/transaction_service.dart';

class EditTransactionController extends GetxController {
  final Transaction transaction;
  EditTransactionController(this.transaction);

  final RxnString type = RxnString();
  final amount = TextEditingController();
  final RxnString paymentMethod = RxnString();
  final note = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool enableBtn = false.obs;

  @override
  void onInit() {
    super.onInit();
    type.value = transaction.type;
    amount.text = transaction.amount.toString();
    paymentMethod.value = transaction.paymentMethod;
    note.text = transaction.note ?? '';

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

  Future<bool> updateTransaction() async {
    if (!enableBtn.value || isLoading.value) return false;
    if (!ActivationGuard.check()) return false;
    try {
      isLoading.value = true;
      final user = AppFirebase().currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      final updated = Transaction(
        docId: transaction.docId,
        type: type.value!,
        amount: double.tryParse(amount.text.trim()) ?? 0,
        note: note.text.trim().isEmpty ? null : note.text.trim(),
        paymentMethod: paymentMethod.value!,
        createdAt: transaction.createdAt,
        partyId: transaction.partyId,
      );

      await TransactionService.updateTransaction(updated, user.uid);
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
