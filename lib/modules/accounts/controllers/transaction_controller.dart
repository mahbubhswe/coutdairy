import 'package:get/get.dart';

import '../../../models/transaction.dart';
import '../../../services/app_firebase.dart';
import '../services/transaction_service.dart';

class TransactionController extends GetxController {
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTransactions();
  }

  void _loadTransactions() {
    final user = AppFirebase().currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    TransactionService.getTransactions(user.uid).listen((data) {
      transactions.value = data;
      isLoading.value = false;
    });
  }
}
