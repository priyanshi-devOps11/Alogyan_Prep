abstract class AuthRepository {
  Future<String> signInWithEmail({required String email, required String password});
  Future<String> registerWithEmail({required String email, required String password});
  Future<String> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendEmailVerification();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> saveOnboardingProfile({required String uid, required Map<String, dynamic> data});
  String? get currentUserId;
  String? get currentUserEmail;
  String? get currentUserDisplayName;
  bool get isEmailVerified;
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}