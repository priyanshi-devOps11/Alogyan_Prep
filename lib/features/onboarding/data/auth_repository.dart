import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_model.dart';

// ── Whitelisted test credentials ─────────────────────────────────────────────
// These MUST be registered in:
// Firebase Console → Authentication → Sign-in method → Phone →
const String _kWhitelistPhone        = '+918081438778';
const String _kWhitelistOtp          = '123456';
const String _kWhitelistVerificationId = 'whitelisted-test-session';

// ── Exception ─────────────────────────────────────────────────────────────────
class AuthException implements Exception {
  final String message;
  final bool isDeveloperError;
  const AuthException(this.message, {this.isDeveloperError = false});
  @override String toString() => message;
}

// ── Abstract contract ─────────────────────────────────────────────────────────
abstract class AuthRepository {
  Future<String> signInWithEmail({required String email, required String password});
  Future<String> registerWithEmail({required String email, required String password});
  Future<void>   sendVerificationEmail();
  Future<bool>   checkEmailVerified();
  Future<String> signInWithGoogle();
  Future<void>   sendPhoneOtp({
    required String phoneNumber,
    required void Function(String) onCodeSent,
    required void Function(String) onError,
  });
  Future<String> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  });
  Future<void>       signOut();
  Future<void>       sendPasswordResetEmail(String email);
  Future<void>       saveUserModel(UserModel user, {bool isNew});
  Future<UserModel?> fetchUserModel(String uid);
  String? get currentUserId;
  String? get currentUserEmail;
  String? get currentUserDisplayName;
  bool    get isEmailVerified;
}

// ── Firebase implementation ───────────────────────────────────────────────────
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth?     auth,
    FirebaseFirestore? db,
    GoogleSignIn?     google,
  })  : _auth   = auth   ?? FirebaseAuth.instance,
        _db     = db     ?? FirebaseFirestore.instance,
        _google = google ?? GoogleSignIn();

  final FirebaseAuth      _auth;
  final FirebaseFirestore _db;
  final GoogleSignIn      _google;

  static const _col = 'students';

  // ── Email sign in ─────────────────────────────────────────────────────────
  @override
  Future<String> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final c = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      _touch(c.user!.uid);
      return c.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_map(e.code));
    }
  }

  // ── Email register ────────────────────────────────────────────────────────
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

  @override
  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      debugPrint('[EMAIL] currentUser: ${user?.email}');
      debugPrint('[EMAIL] emailVerified: ${user?.emailVerified}');
      await user?.sendEmailVerification();
      debugPrint('[EMAIL] Verification email sent successfully');
    } catch (e) {
      debugPrint('[EMAIL] ERROR sending verification: $e');
    }
  }

  @override
  Future<bool> checkEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (_) { return false; }
  }

  // ── Google — bulletproof DEVELOPER_ERROR handler ──────────────────────────
  @override
  Future<String> signInWithGoogle() async {
    try {
      await _google.signOut(); // Force account picker every time
      final googleUser = await _google.signIn();
      if (googleUser == null) throw const AuthException('Google sign-in cancelled.');
      final ga = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: ga.accessToken,
        idToken:     ga.idToken,
      );
      final c = await _auth.signInWithCredential(cred);
      _touch(c.user!.uid);
      return c.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed' ||
          (e.message?.contains('DEVELOPER_ERROR') ?? false)) {
        throw const AuthException(
          '⚠️ Google Sign-In config error (DEVELOPER_ERROR).\n\n'
              'Fix: Add debug SHA-1 fingerprint to Firebase Console →\n'
              'Project Settings → Your Android App → Add fingerprint.\n\n'
              'Run: cd android && gradlew.bat signingReport',
          isDeveloperError: true,
        );
      }
      throw AuthException(_map(e.code));
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('DEVELOPER_ERROR') || msg.contains('ApiException: 10')) {
        throw const AuthException(
          '⚠️ Google Sign-In failed (DEVELOPER_ERROR 10).\n\n'
              'Add SHA-1 fingerprint to Firebase Console → Project Settings →\n'
              'Android App → Add fingerprint, then re-download google-services.json.',
          isDeveloperError: true,
        );
      }
      if (e is AuthException) rethrow;
      throw const AuthException('Google sign-in failed. Please try again.');
    }
  }

  // ── Phone OTP send — WHITELIST SHORT-CIRCUIT ──────────────────────────────
  // If the phone number matches our test number, we skip the network carrier
  // layer entirely and immediately fire onCodeSent with a static session id.
  // Firebase will resolve the matching OTP locally (from its test registry)
  // when verifyPhoneOtp is called — no SMS, no billing, no reCAPTCHA.
  @override
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String) onCodeSent,
    required void Function(String) onError,
  }) async {
    // ── HARDCODED FALLBACK: whitelisted test number ────────────────────────
    if (phoneNumber == _kWhitelistPhone) {
      // Immediately complete without any network call.
      // The static verificationId is a sentinel we check in verifyPhoneOtp.
      onCodeSent(_kWhitelistVerificationId);
      return;
    }

    // ── Live path: real Firebase Phone Auth ───────────────────────────────
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (cred) async {
        // Auto-retrieval on some Android devices — sign in silently
        try { await _auth.signInWithCredential(cred); } catch (_) {}
      },
      verificationFailed: (e) => onError(_map(e.code)),
      codeSent:           (vid, _) => onCodeSent(vid),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  // ── Phone OTP verify ──────────────────────────────────────────────────────
  @override
  Future<String> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      // ── WHITELIST: use Firebase test credentials directly ─────────────
      if (verificationId == _kWhitelistVerificationId) {
        // For whitelisted numbers, Firebase needs us to re-trigger
        // verifyPhoneNumber internally to get a real verificationId,
        // then sign in with the known test OTP.
        final completer = Completer<String>();

        await _auth.verifyPhoneNumber(
          phoneNumber: _kWhitelistPhone,
          timeout: const Duration(seconds: 30),
          verificationCompleted: (_) {},
          verificationFailed: (e) =>
              completer.completeError(AuthException(_map(e.code))),
          codeSent: (realVid, _) async {
            try {
              final cred = PhoneAuthProvider.credential(
                verificationId: realVid,
                smsCode: _kWhitelistOtp,
              );
              final c = await _auth.signInWithCredential(cred);
              _touch(c.user!.uid);
              completer.complete(c.user!.uid);
            } catch (e) {
              completer.completeError(
                  AuthException('Test sign-in failed: $e'));
            }
          },
          codeAutoRetrievalTimeout: (_) {},
        );

        return await completer.future;
      }

      // ── Live path ─────────────────────────────────────────────────────
      final cred = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final c = await _auth.signInWithCredential(cred);
      _touch(c.user!.uid);
      return c.user!.uid;

    } on FirebaseAuthException catch (e) {
      throw AuthException(_map(e.code));
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────────────
  @override
  Future<void> signOut() async {
    // Await each independently so one failure doesn't block the other
    try { await _google.signOut(); } catch (_) {}
    try { await _auth.signOut(); } catch (_) {}
  }

  // ── Password reset ────────────────────────────────────────────────────────
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_map(e.code));
    }
  }

  // ── Firestore ─────────────────────────────────────────────────────────────
  @override
  Future<void> saveUserModel(UserModel user, {bool isNew = false}) async {
    await _db
        .collection(_col)
        .doc(user.uid)
        .set(user.toFirestoreMap(isNew: isNew), SetOptions(merge: true));
  }

  @override
  Future<UserModel?> fetchUserModel(String uid) async {
    try {
      final doc = await _db.collection(_col).doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc.data()!);
    } catch (_) { return null; }
  }

  @override String? get currentUserId          => _auth.currentUser?.uid;
  @override String? get currentUserEmail        => _auth.currentUser?.email;
  @override String? get currentUserDisplayName  => _auth.currentUser?.displayName;
  @override bool    get isEmailVerified         => _auth.currentUser?.emailVerified ?? false;

  void _touch(String uid) {
    _db.collection(_col).doc(uid).set(
      {'lastUpdated': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    ).catchError((_) {});
  }

  String _map(String code) => switch (code) {
    'user-not-found'            => 'No account found with this email.',
    'wrong-password'            => 'Incorrect password. Please try again.',
    'invalid-email'             => 'Please enter a valid email address.',
    'user-disabled'             => 'This account has been disabled.',
    'email-already-in-use'      => 'An account already exists with this email.',
    'weak-password'             => 'Password does not meet strength requirements.',
    'too-many-requests'         => 'Too many attempts. Please wait.',
    'network-request-failed'    => 'No internet connection.',
    'invalid-credential'        => 'Invalid credentials. Please check and retry.',
    'invalid-verification-code' => 'Invalid OTP. Please check and retry.',
    'session-expired'           => 'OTP expired. Please request a new one.',
    'quota-exceeded'            => 'SMS quota exceeded. Try again later.',
    _                           => 'Authentication failed. Please try again.',
  };
}