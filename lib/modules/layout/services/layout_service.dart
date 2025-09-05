import 'dart:async';

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
  ///
  /// Previously this checked the current user only once, which caused the
  /// drawer to never load if auth wasn't ready yet. Now it reacts to auth
  /// changes and switches to the correct lawyer doc stream accordingly.
  Stream<Lawyer?> getLawyerInfo() {
    final auth = Get.find<AuthController>();

    // Bridge stream that follows auth.user and switches the Firestore
    // subscription when the user changes.
    final controller = StreamController<Lawyer?>();
    StreamSubscription? authSub;
    StreamSubscription? docSub;

    void listenToLawyerDoc(String uid) {
      docSub?.cancel();
      final lawyerDocRef = _firestore
          .collection(AppCollections.lawyers)
          .doc(uid);
      docSub = lawyerDocRef.snapshots().listen((snapshot) {
        if (!snapshot.exists) {
          controller.add(null);
          return;
        }
        final data = snapshot.data();
        if (data == null) {
          controller.add(null);
          return;
        }
        try {
          controller.add(_parseLawyer(data, snapshot.id));
        } catch (e) {
          if (kDebugMode) {
            print('Failed to parse Lawyer document (${snapshot.id}): $e');
          }
          controller.add(null);
        }
      }, onError: controller.addError);
    }

    authSub = auth.user.listen((user) {
      // Switch stream when auth changes
      if (user == null) {
        if (kDebugMode) print("No authenticated user found for getLawyerInfo");
        docSub?.cancel();
        controller.add(null);
      } else {
        listenToLawyerDoc(user.uid);
      }
    });

    controller.onCancel = () {
      docSub?.cancel();
      authSub?.cancel();
    };

    return controller.stream;
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
