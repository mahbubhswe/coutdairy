import 'package:court_dairy/services/firebase_export.dart';

import '../../../constants/app_collections.dart';
import '../../../models/lawyer.dart';
import '../../../services/app_firebase.dart';

class AuthService {
  final _firebase = AppFirebase();
  final _auth = AppFirebase().auth;
  final _firestore = AppFirebase().firestore;

  // 🔐 Email/Password Login
  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // 🔐 Google Sign-In with Firestore user creation (if new)
  Future<UserCredential?> signInWithGoogle() async {
    final (userCredential, isNewUser) = await _firebase.signInWithGoogle();

    if (userCredential != null && isNewUser) {
      final user = userCredential.user!;
      final fcmToken = await AppFirebase().getFcmToken();
      if (fcmToken != null) {
        final now = DateTime.now();
        final after30Days = now.add(const Duration(days: 30));
        Lawyer newLawyer = Lawyer(
          address: "Dhaka, Bangladesh",
          fcmToken: fcmToken,
          phone: "01623131102",
          smsBalance: 0,
          balance: 0,
          subStartsAt: now,
          subEndsAt: after30Days,
          isActive: true,
          courts: [],
          judges: [],
        );

        await _firestore
            .collection(AppCollections.lawyers)
            .doc(user.uid)
            .set(newLawyer.toMap());
      }
    }

    return userCredential;
  }

  // 🔓 Logout
  Future<void> logout() => _firebase.signOut();

  // 🔄 Auth state stream
  Stream<User?> authState() => _auth.authStateChanges();

  // 👤 Current user
  User? get currentUser => _auth.currentUser;

  // 🔑 Password reset
  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }
}
