import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../data/auth_repository.dart';
import '../data/onboarding_model.dart';

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repo;

  @override
  AuthState build() {
    _repo = ref.read(authRepositoryProvider);
    final uid = _repo.currentUserId;
    final email = _repo.currentUserEmail;
    if (uid != null && email != null) {
      return AuthState.authenticated(
        userId: uid,
        email: email,
        displayName: _repo.currentUserDisplayName,
      );
    }
    return const AuthState.unauthenticated();
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final uid = await _repo.signInWithEmail(email: email, password: password);
      state = AuthState.authenticated(userId: uid, email: email);
    } on AuthException catch (e) {
      state = const AuthState.unauthenticated().copyWithError(e.message);
    }
  }

  Future<bool> registerWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final uid =
      await _repo.registerWithEmail(email: email, password: password);
      // Send email verification
      await _repo.sendEmailVerification();
      state = AuthState.authenticated(userId: uid, email: email);
      return true;
    } on AuthException catch (e) {
      state = const AuthState.unauthenticated().copyWithError(e.message);
      return false;
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState.loading();
    try {
      final uid = await _repo.signInWithGoogle();
      state = AuthState.authenticated(
        userId: uid,
        email: _repo.currentUserEmail ?? '',
        displayName: _repo.currentUserDisplayName,
      );
    } on AuthException catch (e) {
      state = const AuthState.unauthenticated().copyWithError(e.message);
    }
  }

  Future<void> saveOnboardingProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _repo.saveOnboardingProfile(uid: uid, data: data);
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState.unauthenticated();
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      await _repo.sendPasswordResetEmail(email);
      return true;
    } on AuthException {
      return false;
    }
  }

  void clearError() {
    if (state.hasError) state = const AuthState.unauthenticated();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);