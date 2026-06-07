import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ─── Abstract contract ────────────────────────────────────────────────────────
abstract class AuthRepository {
  Future<String> signInWithEmail({required String email, required String password});
  Future<String> registerWithEmail({required String email, required String password});
  Future<String> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendEmailVerification();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> saveProfile({required String uid, required Map<String, dynamic> data});
  String? get currentUserId;
  String? get currentUserEmail;
  String? get currentUserDisplayName;
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override String toString() => message;
}

// ─── Firebase implementation ──────────────────────────────────────────────────
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _google = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _google;

  @override
  Future<String> signInWithEmail({required String email, required String password}) async {
    try {
      final c = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      return c.user!.uid;
    } on FirebaseAuthException catch (e) { throw AuthException(_map(e.code)); }
    catch (_) { throw const AuthException('Something went wrong. Please try again.'); }
  }

  @override
  Future<String> registerWithEmail({required String email, required String password}) async {
    try {
      final c = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      return c.user!.uid;
    } on FirebaseAuthException catch (e) { throw AuthException(_map(e.code)); }
    catch (_) { throw const AuthException('Registration failed. Please try again.'); }
  }

  @override
  Future<String> signInWithGoogle() async {
    try {
      final googleUser = await _google.signIn();
      if (googleUser == null) throw const AuthException('Google sign-in was cancelled.');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final c = await _auth.signInWithCredential(credential);
      return c.user!.uid;
    } on FirebaseAuthException catch (e) { throw AuthException(_map(e.code)); }
    catch (e) { if (e is AuthException) rethrow; throw const AuthException('Google sign-in failed.'); }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _google.signOut()]);
  }

  @override
  Future<void> sendEmailVerification() async {
    try { await _auth.currentUser?.sendEmailVerification(); } catch (_) {}
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try { await _auth.sendPasswordResetEmail(email: email.trim()); }
    on FirebaseAuthException catch (e) { throw AuthException(_map(e.code)); }
  }

  @override
  Future<void> saveProfile({required String uid, required Map<String, dynamic> data}) async {
    try { await _firestore.collection('students').doc(uid).set(data, SetOptions(merge: true)); }
    catch (_) { throw const AuthException('Failed to save profile.'); }
  }

  @override String? get currentUserId => _auth.currentUser?.uid;
  @override String? get currentUserEmail => _auth.currentUser?.email;
  @override String? get currentUserDisplayName => _auth.currentUser?.displayName;

  String _map(String code) => switch (code) {
    'user-not-found'                            => 'No account found with this email.',
    'wrong-password'                            => 'Incorrect password. Please try again.',
    'invalid-email'                             => 'Please enter a valid email address.',
    'user-disabled'                             => 'This account has been disabled.',
    'email-already-in-use'                      => 'An account already exists with this email.',
    'weak-password'                             => 'Password must be at least 6 characters.',
    'too-many-requests'                         => 'Too many attempts. Please wait.',
    'network-request-failed'                    => 'No internet connection.',
    'invalid-credential'                        => 'Invalid credentials. Please check and retry.',
    'account-exists-with-different-credential'  => 'Account exists with a different sign-in method.',
    _                                           => 'Authentication failed. Please try again.',
  };
}