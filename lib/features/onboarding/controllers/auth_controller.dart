import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alogyan_prep/features/onboarding/data/auth_repository.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;
  AuthController(this._authRepository) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password, Function onSuccess) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      state = const AsyncValue.data(null);
      onSuccess();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}