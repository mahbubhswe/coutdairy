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
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 👤 Current user shortcut
  User? get currentUser => _auth.currentUser;

  // 🧹 Sign out helper
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // 🧪 FCM token getter
  Future<String?> getFcmToken() async {
    return await _messaging.getToken();
  }

  /// ✅ Sign in with Google — returns (UserCredential?, isNewUser)
  Future<(UserCredential?, bool)> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return (null, false);

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      return (userCredential, isNewUser);
    } catch (e) {
      if (kDebugMode) {
        print("Google Sign-In error: $e");
      }
      return (null, false);
    }
  }
}
