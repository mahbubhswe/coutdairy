import 'package:court_dairy/services/firebase_export.dart';

import '../../../constants/app_collections.dart';
import '../../../services/app_firebase.dart';

class BuySmsService {
  static final _firestore = AppFirebase().firestore;

  static Future<void> addSmsBalance({required int count}) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    await _firestore.collection(AppCollections.lawyers).doc(user.uid).update({
      'smsBalance': FieldValue.increment(count),
    });
  }
}
