import 'package:court_dairy/services/app_firebase.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../constants/app_collections.dart';
import '../../../models/lawyer.dart';
import '../../../services/firebase_export.dart';
import '../../auth/controllers/auth_controller.dart';

class LayoutService {
  final _firestore = AppFirebase().firestore;

  /// Backward-compatible alias for older callers
  Stream<Lawyer?> getLawyer() => getLawyerInfo();

  /// Returns a stream of Lawyer info for the current user.
  Stream<Lawyer?> getLawyerInfo() {
    final user = Get.find<AuthController>().user.value;
    if (user == null) {
      if (kDebugMode) print("No authenticated user found for getShopInfo");
      return Stream.value(null);
    }

    final lawyerDocRef = _firestore
        .collection(AppCollections.lawyers)
        .doc(user.uid);

    return lawyerDocRef.snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null) return null;
      try {
        return _parseLawyer(data, snapshot.id);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to parse Lawyer document (${snapshot.id}): $e');
        }
        return null;
      }
    });
  }

  Lawyer _parseLawyer(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    int parseInt(dynamic v, [int fallback = 0]) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    double parseDouble(dynamic v, [double fallback = 0]) {
      if (v is double) return v;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? fallback;
      return fallback;
    }

    List<String> parseStringList(dynamic v) {
      if (v is List) return v.whereType<String>().toList();
      return const [];
    }

    return Lawyer(
      docId: id,
      address: (map['address'] ?? '').toString(),
      fcmToken: (map['fcmToken'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      smsBalance: parseInt(map['smsBalance']),
      balance: parseDouble(map['balance']),
      isActive: map['isActive'] == true,
      subFor: parseInt(map['subFor']),
      subStartsAt: parseDate(map['subStartsAt']),
      courts: parseStringList(map['courts']),
      judges: parseStringList(map['judges']),
    );
  }
}
