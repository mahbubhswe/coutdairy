
import 'package:court_dairy/services/firebase_export.dart';

class Lawyer {
  String? docId;
  final String address;
  final String fcmToken;
  final String phone;
  final int smsBalance;
  final double balance;
  final bool isActive;
  final DateTime subStartsAt;
  final DateTime subEndsAt;
  final List<String> courts;
  final List<String> judges;

  Lawyer({
    this.docId,
    required this.address,
    required this.fcmToken,
    required this.phone,
    required this.smsBalance,
    required this.balance,
    required this.isActive,
    required this.subEndsAt,
    required this.subStartsAt,
    this.courts = const [],
    this.judges = const [],
  });

  /// Convert to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'fcmToken': fcmToken,
      'phone': phone,
      'smsBalance': smsBalance,
      'balance': balance,
      'isActive': isActive,
      'subEndsAt': subEndsAt,
      'subStartsAt': subStartsAt,
      'courts': courts, // ✅ Save courts list
      'judges': judges,
    };
  }

  /// Create from Firestore Map
  factory Lawyer.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Lawyer(
      docId: docId,
      address: map['address'] ?? '',
      fcmToken: map['fcmToken'] ?? '',
      phone: map['phone'] ?? '',
      smsBalance: map['smsBalance'] ?? 0,
      balance: (map['balance'] ?? 0).toDouble(),
      isActive: map['isActive'] ?? false,
      subStartsAt: (map['subStartsAt'] as Timestamp).toDate(),
      subEndsAt: (map['subEndsAt'] as Timestamp).toDate(),
      courts: List<String>.from(map['courts'] ?? []), 
      judges: List<String>.from(map['judges'] ?? []),
    );
  }

}
