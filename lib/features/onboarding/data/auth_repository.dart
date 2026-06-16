import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_model.dart';

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
  Future<String> verifyPhoneOtp({required String verificationId, required String smsCode});
  Future<void>   signOut();
  Future<void>   sendPasswordResetEmail(String email);
  Future<void>   saveUserModel(UserModel user, {bool isNew});
  Future<UserModel?> fetchUserModel(String uid);
  String? get currentUserId;
  String? get currentUserEmail;
  String? get currentUserDisplayName;
  bool    get isEmailVerified;
}

// ── Firebase implementation ───────────────────────────────────────────────────
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth?    auth,
    FirebaseFirestore? db,
    GoogleSignIn?    google,
  })  : _auth   = auth   ?? FirebaseAuth.instance,
        _db     = db     ?? FirebaseFirestore.instance,
        _google = google ?? GoogleSignIn();

  final FirebaseAuth      _auth;
  final FirebaseFirestore _db;
  final GoogleSignIn      _google;

  static const _col = 'students';

  // ── Sign in ───────────────────────────────────────────────────────────────
  @override
  Future<String> signInWithEmail({required String email, required String password}) async {
    try {
      final c = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      _touch(c.user!.uid);
      return c.user!.uid;
    } on FirebaseAuthException catch (e) { throw AuthException(_map(e.code)); }
  }

  // ── Register ──────────────────────────────────────────────────────────────
  @override
  Future<String> registerWithEmail({required String email, required String password}) async {
    try {
      final c = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      return c.user!.uid;
    } on FirebaseAuthException catch (e) { throw AuthException(_map(e.code)); }
  }

  // ── Email verify ──────────────────────────────────────────────────────────
  @override
  Future<void> sendVerificationEmail() async {
    try { await _auth.currentUser?.sendEmailVerification(); } catch (_) {}
  }

  @override
  Future<bool> checkEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (_) { return false; }
  }

  // ── Google — bulletproof DEVELOPER_ERROR catch ────────────────────────────
  @override
  Future<String> signInWithGoogle() async {
    try {
      await _google.signOut(); // Force account picker
      final googleUser = await _google.signIn();
      if (googleUser == null) throw const AuthException('Google sign-in cancelled.');
      final ga = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: ga.accessToken, idToken: ga.idToken);
      final c = await _auth.signInWithCredential(credential);
      _touch(c.user!.uid);
      return c.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed' ||
          (e.message?.contains('DEVELOPER_ERROR') ?? false)) {
        throw const AuthException(
          '⚠️ Google Sign-In config error (DEVELOPER_ERROR).\n\n'
              'Fix: Add your debug SHA-1 fingerprint to Firebase Console → '
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
          '⚠️ Google Sign-In failed (Error 10 / DEVELOPER_ERROR).\n\n'
              'Add SHA-1 fingerprint to Firebase Console → Project Settings → '
              'Android App → Add fingerprint, then re-download google-services.json.',
          isDeveloperError: true,
        );
      }
      if (e is AuthException) rethrow;
      throw const AuthException('Google sign-in failed. Please try again.');
    }
  }

  // ── Phone OTP ─────────────────────────────────────────────────────────────
  @override
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String) onCodeSent,
    required void Function(String) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (cred) async {
        try { await _auth.signInWithCredential(cred); } catch (_) {}
      },
      verificationFailed: (e) => onError(_map(e.code)),
      codeSent: (vid, _) => onCodeSent(vid),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  @override
  Future<String> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final cred = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      final c = await _auth.signInWithCredential(cred);
      _touch(c.user!.uid);
      return c.user!.uid;
    } on FirebaseAuthException catch (e) { throw AuthException(_map(e.code)); }
  }

  // ── Sign out ──────────────────────────────────────────────────────────────
  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _google.signOut()]);
  }

  // ── Password reset ────────────────────────────────────────────────────────
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) { throw AuthException(_map(e.code)); }
  }

  // ── Firestore ─────────────────────────────────────────────────────────────
  @override
  Future<void> saveUserModel(UserModel user, {bool isNew = false}) async {
    await _db.collection(_col).doc(user.uid)
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
        SetOptions(merge: true)).catchError((_) {});
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
    _                           => 'Authentication failed. Please try again.',
  };
}