import '../../../constants/app_collections.dart';
import '../../../models/court_case.dart';
import '../../../services/app_firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CaseService {
  static final _firestore = AppFirebase().firestore;

  static Future<void> addCase(CourtCase courtCase, String userId) async {
    final docRef = _firestore
        .collection(AppCollections.lawyers)
        .doc(userId)
        .collection(AppCollections.cases)
        .doc();
    courtCase.docId = docRef.id;
    await docRef.set(courtCase.toMap());
  }

  static Future<void> updateCase(CourtCase courtCase, String userId) async {
    final docId = courtCase.docId;
    if (docId == null || docId.isEmpty) {
      throw Exception('Case document ID is required for update');
    }
    await _firestore
        .collection(AppCollections.lawyers)
        .doc(userId)
        .collection(AppCollections.cases)
        .doc(docId)
        .update(courtCase.toMap());
  }

  static Stream<List<CourtCase>> getCases(String userId) {
    return _firestore
        .collection(AppCollections.lawyers)
        .doc(userId)
        .collection(AppCollections.cases)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CourtCase.fromMap(doc.data(), docId: doc.id))
            .toList());
  }

  static Future<void> deleteCase(String docId, String userId) async {
    await _firestore
        .collection(AppCollections.lawyers)
        .doc(userId)
        .collection(AppCollections.cases)
        .doc(docId)
        .delete();
  }

  static Future<void> addHearingDate(
      String docId, String userId, Timestamp date) async {
    // Backward-compat shim: treat as setting next hearing date
    await setNextHearingDate(docId, userId, date);
  }

  static Future<void> removeHearingDate(
      String docId, String userId, Timestamp date) async {
    // Backward-compat shim: clear next hearing date if matches
    final docRef = _firestore
        .collection(AppCollections.lawyers)
        .doc(userId)
        .collection(AppCollections.cases)
        .doc(docId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final data = snap.data() as Map<String, dynamic>?;
      final next = data?['nextHearingDate'];
      if (next == date) {
        tx.update(docRef, {'nextHearingDate': null});
      }
    });
  }

  static Future<void> addCourtOrder(
      String docId, String userId, String order) async {
    // Backward-compat shim: set next court order
    await setCourtNextOrder(docId, userId, order);
  }

  static Future<void> removeCourtOrder(
      String docId, String userId, String order) async {
    // Backward-compat shim: clear next order if matches
    final docRef = _firestore
        .collection(AppCollections.lawyers)
        .doc(userId)
        .collection(AppCollections.cases)
        .doc(docId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final data = snap.data() as Map<String, dynamic>?;
      final next = data?['courtNextOrder'];
      if (next == order) {
        tx.update(docRef, {'courtNextOrder': null});
      }
    });
  }

  static Future<void> updateCaseStatus(
      String docId, String userId, String status) async {
    await _firestore
        .collection(AppCollections.lawyers)
        .doc(userId)
        .collection(AppCollections.cases)
        .doc(docId)
        .update({'caseStatus': status});
  }

  static Future<void> updateNextHearingDate(
      String docId, String userId, Timestamp newDate) async {
    await setNextHearingDate(docId, userId, newDate);
  }

  static Future<void> setNextHearingDate(
      String docId, String userId, Timestamp newDate) async {
    final docRef = _firestore
        .collection(AppCollections.lawyers)
        .doc(userId)
        .collection(AppCollections.cases)
        .doc(docId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final data = snap.data() as Map<String, dynamic>?;
      final currentNext = data?['nextHearingDate'];
      final updates = <String, dynamic>{
        'nextHearingDate': newDate,
      };
      if (currentNext != null) {
        updates['lastHearingDate'] = currentNext;
      }
      tx.update(docRef, updates);
    });
  }

  static Future<void> setCourtNextOrder(
      String docId, String userId, String order) async {
    final docRef = _firestore
        .collection(AppCollections.lawyers)
        .doc(userId)
        .collection(AppCollections.cases)
        .doc(docId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final data = snap.data() as Map<String, dynamic>?;
      final currentNext = data?['courtNextOrder'];
      final updates = <String, dynamic>{
        'courtNextOrder': order,
      };
      if (currentNext != null && (currentNext as String).isNotEmpty) {
        updates['courtLastOrder'] = currentNext;
      }
      tx.update(docRef, updates);
    });
  }
}
