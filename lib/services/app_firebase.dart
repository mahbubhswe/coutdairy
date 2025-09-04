import 'package:flutter/foundation.dart';
import 'firebase_export.dart';

class AppFirebase {
  // Singleton pattern
  static final AppFirebase _instance = AppFirebase._internal();
  factory AppFirebase() => _instance;
  AppFirebase._internal();

  // 🔐 Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseAuth get auth => _auth;

  // 📦 Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseFirestore get firestore => _firestore;

  // 🗂️ Storage
  final FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseStorage get storage => _storage;

  // 🔔 Messaging (FCM)
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  FirebaseMessaging get messaging => _messaging;

  // ⚙️ Cloud Functions
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  FirebaseFunctions get functions => _functions;

  // 🔑 Google Sign-In
  // TODO: Implement Google Sign-In with the new API
  // final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // 👤 Current user shortcut
  User? get currentUser => _auth.currentUser;

  // 🧹 Sign out helper
  Future<void> signOut() async {
    // TODO: Implement Google Sign-Out with the new API
    // await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // 🧪 FCM token getter
  Future<String?> getFcmToken() async {
    return await _messaging.getToken();
  }

  /// ✅ Sign in with Google — returns (UserCredential?, isNewUser)
  Future<(UserCredential?, bool)> signInWithGoogle() async {
    try {
      // TODO: Implement Google Sign-In with the new API
      // This is a placeholder implementation
      return (null, false);
    } catch (e) {
      if (kDebugMode) {
        print("Google Sign-In error: $e");
      }
      return (null, false);
    }
  }
}
