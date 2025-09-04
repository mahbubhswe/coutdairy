
import 'package:court_dairy/services/firebase_export.dart';

class Transaction {
  String? docId;
  final String type;
  final double amount;
  final String? note;
  final String paymentMethod;
  final DateTime createdAt;
  final String? partyId;

  Transaction({
    this.docId,
    required this.type,
    required this.amount,
    this.note,
    required this.paymentMethod,
    required this.createdAt,
    this.partyId,
  });

  /// Convert Firestore Document to Model
  factory Transaction.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Transaction(
      docId: docId,
      type: map['type'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      note: map['note'],
      paymentMethod: map['paymentMethod'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      partyId: map['partyId']
    );
  }

  /// Convert Model to Map for Firestore
  Map<String, dynamic> toMap() {
    final map = {
      'type': type,
      'amount': amount,
      'note': note,
      'paymentMethod': paymentMethod,
      'createdAt': Timestamp.fromDate(createdAt),
    };
    
    // Only add partyId and employeeId if they are not null
    if (partyId != null) map['partyId'] = partyId;

    return map;
  }
}
