import 'package:court_dairy/services/app_firebase.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../constants/app_collections.dart';
import '../../../models/lawyer.dart';
import '../../auth/controllers/auth_controller.dart';

class LayoutService {
  final _firestore = AppFirebase().firestore;

  /// Returns a stream of Shop info for the current user/shop.
  Stream<Lawyer?> getShopInfo() {
    final user = Get.find<AuthController>().user.value;
    if (user == null) {
      if (kDebugMode) print("No authenticated user found for getShopInfo");
      return Stream.value(null);
    }

    final shopDocRef =
        _firestore.collection(AppCollections.lawyers).doc(user.uid);

    return shopDocRef.snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Lawyer.fromMap(snapshot.data()!);
      } else {
        return null;
      }
    });
  }


}
