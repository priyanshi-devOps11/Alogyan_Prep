import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_model.dart';

// ── Abstract contract ─────────────────────────────────────────────────────────
abstract class AuthRepository {
  // Email + password
  Future<String> signInWithEmail({required String email, required String password});
  Future<String> registerWithEmail({required String email, required String password});
  Future<void> sendVerificationEmail();
  Future<bool> checkEmailVerified();

  // Google
  Future<String> signInWithGoogle();

  // Phone OTP
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  });
  Future<String> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  });

  // Common
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);

  // Firestore user profile
  Future<void> saveUserModel(UserModel user);
  Future<UserModel?> fetchUserModel(String uid);
  Future<void> updateLastLogin(String uid);

  // Getters
  String? get currentUserId;
  String? get currentUserEmail;
  String? get currentUserDisplayName;
  bool get isEmailVerified;
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override String toString() => message;
}

// ── Firebase implementation ───────────────────────────────────────────────────
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance,
        _google = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final GoogleSignIn _google;

  static const _col = 'students';

  // ── Email sign in ──────────────────────────────────────────────────────────
  @override
  Future<String> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final c = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      await updateLastLogin(c.user!.uid);
      return c.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_map(e.code));
    }
  }

  // ── Email register ─────────────────────────────────────────────────────────
  @override
  Future<String> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final c = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      return c.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_map(e.code));
    }
  }

  // ── Send verification email ────────────────────────────────────────────────
  @override
  Future<void> sendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (_) {}
  }

  // ── Check email verified ───────────────────────────────────────────────────
  @override
  Future<bool> checkEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (_) {
      return false;
    }
  }

  // ── Google sign in ─────────────────────────────────────────────────────────
  @override
  Future<String> signInWithGoogle() async {
    try {
      await _google.signOut(); // Force account picker
      final googleUser = await _google.signIn();
      if (googleUser == null) throw const AuthException('Google sign-in cancelled.');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final c = await _auth.signInWithCredential(credential);
      await updateLastLogin(c.user!.uid);
      return c.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_map(e.code));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const AuthException(
          'Google sign-in failed. Make sure SHA-1 is added to Firebase.');
    }
  }

  // ── Phone OTP — send ───────────────────────────────────────────────────────
  @override
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (_) {
        // Auto-verification on some Android devices
      },
      verificationFailed: (e) => onError(_map(e.code)),
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  // ── Phone OTP — verify ─────────────────────────────────────────────────────
  @override
  Future<String> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final c = await _auth.signInWithCredential(credential);
      await updateLastLogin(c.user!.uid);
      return c.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_map(e.code));
    }
  }

  // ── Sign out ───────────────────────────────────────────────────────────────
  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _google.signOut()]);
  }

  // ── Password reset ─────────────────────────────────────────────────────────
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_map(e.code));
    }
  }

  // ── Save UserModel to Firestore ────────────────────────────────────────────
  @override
  Future<void> saveUserModel(UserModel user) async {
    await _db.collection(_col).doc(user.uid).set(
      user.toFirestore(),
      SetOptions(merge: true),
    );
  }

  // ── Fetch UserModel from Firestore ─────────────────────────────────────────
  @override
  Future<UserModel?> fetchUserModel(String uid) async {
    try {
      final doc = await _db.collection(_col).doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  // ── Update last login timestamp ────────────────────────────────────────────
  @override
  Future<void> updateLastLogin(String uid) async {
    try {
      await _db.collection(_col).doc(uid).set(
        {'lastLoginAt': DateTime.now().toIso8601String()},
        SetOptions(merge: true),
      );
    } catch (_) {}
  }

  @override String? get currentUserId => _auth.currentUser?.uid;
  @override String? get currentUserEmail => _auth.currentUser?.email;
  @override String? get currentUserDisplayName => _auth.currentUser?.displayName;
  @override bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // ── Error mapping ──────────────────────────────────────────────────────────
  String _map(String code) => switch (code) {
    'user-not-found'         => 'No account found with this email.',
    'wrong-password'         => 'Incorrect password. Please try again.',
    'invalid-email'          => 'Please enter a valid email address.',
    'user-disabled'          => 'This account has been disabled.',
    'email-already-in-use'   => 'An account already exists with this email.',
    'weak-password'          => 'Password must be at least 8 characters.',
    'too-many-requests'      => 'Too many attempts. Please wait.',
    'network-request-failed' => 'No internet connection.',
    'invalid-credential'     => 'Invalid credentials. Please check and retry.',
    'invalid-verification-code' => 'Invalid OTP. Please check and retry.',
    'session-expired'        => 'OTP expired. Please request a new one.',
    _                        => 'Authentication failed. Please try again.',
  };
}