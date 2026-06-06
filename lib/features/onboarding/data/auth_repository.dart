import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Absolute paths mapping your internal architecture files directly
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod Provider Configuration
// ─────────────────────────────────────────────────────────────────────────────

/// Exposes the concrete implementation of AuthRepository globally.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// ─────────────────────────────────────────────────────────────────────────────
// Abstract Contract (Interface)
// ─────────────────────────────────────────────────────────────────────────────

/// Abstract contract for authentication operations.
abstract class AuthRepository {
  Future<String> signInWithEmail({
    required String email,
    required String password,
  });

  Future<String> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  String? get currentUserId;
  String? get currentUserEmail;
}

// ─────────────────────────────────────────────────────────────────────────────
// Typed Exception
// ─────────────────────────────────────────────────────────────────────────────

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

// ─────────────────────────────────────────────────────────────────────────────
// Concrete Firebase Implementation (The code you provided)
// ─────────────────────────────────────────────────────────────────────────────

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'students';

  // ── Sign In ───────────────────────────────────────────────────────────────

  @override
  Future<String> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    } catch (_) {
      throw const AuthException('Something went wrong. Please try again.');
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────

  @override
  Future<String> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;

      // Update Firebase Auth display name
      await user.updateDisplayName(displayName.trim());

      // Persist profile to Firestore
      final profile = StudentProfile(
        uid: user.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        createdAt: DateTime.now(),
        onboardingCompleted: true,
      );
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .set(profile.toMap());

      return user.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    } catch (_) {
      throw const AuthException('Registration failed. Please try again.');
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {
      throw const AuthException('Sign out failed. Please try again.');
    }
  }

  // ── Password Reset ────────────────────────────────────────────────────────

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  // ── Current User ──────────────────────────────────────────────────────────

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  String? get currentUserEmail => _auth.currentUser?.email;

  // ── Error Mapping ─────────────────────────────────────────────────────────

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}