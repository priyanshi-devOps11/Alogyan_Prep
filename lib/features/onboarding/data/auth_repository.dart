import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod Provider Configuration
// ─────────────────────────────────────────────────────────────────────────────

/// Exposes the concrete implementation of AuthRepository globally.
/// Presentation layer elements will read this provider to execute auth logic.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(
    firebaseAuth: firebase_auth.FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Abstract Contract (Your Contract Interface)
// ─────────────────────────────────────────────────────────────────────────────

/// Abstract contract for authentication operations.
/// The presentation layer depends only on this interface — never on Firebase directly.
/// This makes the feature fully testable and swappable.
abstract class AuthRepository {
  /// Signs in an existing student with email and password.
  /// Throws [AuthException] on failure.
  Future<String> signInWithEmail({
    required String email,
    required String password,
  });

  /// Creates a new student account and persists a Firestore profile.
  /// Throws [AuthException] on failure.
  Future<String> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Signs out the currently authenticated student.
  Future<void> signOut();

  /// Sends a password-reset email to the given address.
  Future<void> sendPasswordResetEmail(String email);

  /// Returns the UID of the currently authenticated user, or null.
  String? get currentUserId;

  /// Returns the email of the currently authenticated user, or null.
  String? get currentUserEmail;
}

// ─────────────────────────────────────────────────────────────────────────────
// Typed Exception
// ─────────────────────────────────────────────────────────────────────────────

/// Typed exception — never expose raw Firebase error codes to the UI layer.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

// ─────────────────────────────────────────────────────────────────────────────
// Concrete Backend Infrastructure Implementation
// ─────────────────────────────────────────────────────────────────────────────

class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  String? get currentUserEmail => _firebaseAuth.currentUser?.email;

  @override
  Future<String> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw const AuthException('User payload missing following authentication.');
      }
      return credential.user!.uid;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_handleFirebaseError(e.code, e.message));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<String> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Automatically populate client profile tracking structural schema inside Firestore
      await _firestore.collection('students').doc(uid).set({
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'createdAt': DateTime.now().toIso8601String(),
        'onboardingCompleted': true,
      });

      return uid;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_handleFirebaseError(e.code, e.message));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_handleFirebaseError(e.code, e.message));
    }
  }

  // ── Error Handler Wrapper ──────────────────────────────────────────────────
  String _handleFirebaseError(String code, String? fallbackMessage) {
    switch (code) {
      case 'user-not-found':
        return 'No student account found mapping that email.';
      case 'wrong-password':
        return 'Incorrect authentication password password. Please try again.';
      case 'email-already-in-use':
        return 'This email address is already registered under another account.';
      case 'invalid-email':
        return 'The formatted email syntax structure provided is invalid.';
      case 'weak-password':
        return 'The input password payload fails security strength constraints.';
      case 'user-disabled':
        return 'This student profile execution profile context has been disabled.';
      default:
        return fallbackMessage ?? 'Authentication pipeline processing failure encountered.';
    }
  }
}