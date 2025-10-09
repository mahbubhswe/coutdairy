import 'package:get/get.dart';

import '../../../models/transaction.dart';
import '../../../services/app_firebase.dart';
import '../services/transaction_service.dart';

class TransactionController extends GetxController {
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedFilter = 'All'.obs;

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

  List<Transaction> get filteredTransactions {
    final filter = selectedFilter.value.toLowerCase();
    if (filter == 'all') return transactions;
    return transactions
        .where((tx) => tx.type.toLowerCase() == filter)
        .toList();
  }

  double get filteredTotal => filteredTransactions.fold<double>(
      0, (previousValue, element) => previousValue + element.amount);

  void setFilter(String value) {
    selectedFilter.value = value;
  }
}
