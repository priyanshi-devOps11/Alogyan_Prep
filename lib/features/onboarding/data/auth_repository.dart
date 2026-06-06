import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provide the repository globally via Riverpod
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance);
});

class AuthRepository {
  final FirebaseAuth _auth;
  AuthRepository(this._auth);

  // Stream to track user authentication status changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login with Email and Password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An unknown error occurred.');
    }
  }

  // Sign out
  Future<void> signOut() async => await _auth.signOut();
}