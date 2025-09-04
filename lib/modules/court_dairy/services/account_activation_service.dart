import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../constants/app_collections.dart';

class AccountActivationService {
  static Future<void> markAccountActivated({required int days}) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    await FirebaseFirestore.instance
        .collection(AppCollections.lawyers)
        .doc(user.uid)
        .update({
      'isActive': true,
      'subStartsAt': FieldValue.serverTimestamp(),
      'subFor': days,
    });
  }
}
