import 'package:flutter/foundation.dart';
import '../constants/app_collections.dart';
import 'app_firebase.dart';

class FcmService {
  final _firestore = AppFirebase().firestore;
  final _messaging = AppFirebase().messaging;
  final _auth = AppFirebase().auth;

  /// Initialize the FCM token and set up refresh listener
  Future<void> initialize() async {
    final token = await _messaging.getToken();
    if (token != null) {
      if (kDebugMode) {
        print("🔑 Initial FCM token: $token");
      }
      await updateFcmToken(token: token);
    }
    await listenForTokenRefresh();
  }

  /// Listen only for FCM token refresh (no initial token fetch)
  Future<void> listenForTokenRefresh() async {
    _messaging.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) {
        print("🔁 FCM token refreshed: $newToken");
      }
      await updateFcmToken(token: newToken);
    });
  }

  /// Update the refreshed token in Firestore
  Future<void> updateFcmToken({required String token}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore
          .collection(AppCollections.lawyers)
          .doc(uid)
          .update({"fcmToken": token});
    } catch (e) {
      if (kDebugMode) {
        print("❌ Failed to update FCM token: $e");
      }
    }
  }
}
