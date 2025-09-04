import '../../../constants/app_collections.dart';
import '../../../models/transaction.dart';
import '../../../services/app_firebase.dart';

class TransactionService {
  static final _firestore = AppFirebase().firestore;

  static Future<void> addTransaction(Transaction transaction, String userId) async {
    await _firestore
        .collection(AppCollections.lawyers)
        .doc(userId)
        .collection(AppCollections.transactions)
        .add(transaction.toMap());
  }

  static Future<void> updateTransaction(
      Transaction transaction, String userId) async {
    if (transaction.docId == null) {
      throw Exception('Transaction document ID is required for update');
    }

    await _firestore
        .collection(AppCollections.lawyers)
        .doc(userId)
        .collection(AppCollections.transactions)
        .doc(transaction.docId)
        .update(transaction.toMap());
  }

  static Stream<List<Transaction>> getTransactions(String userId) {
    return _firestore
        .collection(AppCollections.lawyers)
        .doc(userId)
        .collection(AppCollections.transactions)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Transaction.fromMap(doc.data(), docId: doc.id))
            .toList());
  }

  static Future<void> deleteTransaction(String docId, String userId) async {
    await _firestore
        .collection(AppCollections.lawyers)
        .doc(userId)
        .collection(AppCollections.transactions)
        .doc(docId)
        .delete();
  }
}
