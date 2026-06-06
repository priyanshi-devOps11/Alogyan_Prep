import 'package:flutter_riverpod/flutter_riverpod.dart';

// Clean absolute package dependencies mapping your structural files
import 'package:alogyan_prep/features/onboarding/data/auth_repository.dart';
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth mode — login vs register toggle
// ─────────────────────────────────────────────────────────────────────────────

enum AuthMode { login, register }

final authModeProvider = StateProvider<AuthMode>((ref) => AuthMode.login);

// ─────────────────────────────────────────────────────────────────────────────
// Auth Notifier — manages the full auth lifecycle
// ─────────────────────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);

    // Check if already authenticated on startup
    final uid = _repository.currentUserId;
    final email = _repository.currentUserEmail;

    if (uid != null && email != null) {
      return AuthState.authenticated(userId: uid, email: email);
    }
    return const AuthState.unauthenticated();
  }

  // ── Sign In ───────────────────────────────────────────────────────────────

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final uid = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      state = AuthState.authenticated(userId: uid, email: email);
    } on AuthException catch (e) {
      state = const AuthState.unauthenticated().copyWithError(e.message);
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AuthState.loading();
    try {
      final uid = await _repository.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AuthState.authenticated(userId: uid, email: email);
    } on AuthException catch (e) {
      state = const AuthState.unauthenticated().copyWithError(e.message);
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await _repository.signOut();
      state = const AuthState.unauthenticated();
    } on AuthException catch (e) {
      state = state.copyWithError(e.message);
    }
  }

  // ── Password Reset ────────────────────────────────────────────────────────

  Future<bool> sendPasswordReset(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email);
      return true;
    } on AuthException {
      return false;
    }
  }

  /// Clears any lingering error so the UI can reset its state.
  void clearError() {
    if (state.hasError) {
      state = const AuthState.unauthenticated();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);