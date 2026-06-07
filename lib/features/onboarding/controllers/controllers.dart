import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/onboarding_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. Repository provider
// ─────────────────────────────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((ref) => FirebaseAuthRepository());

// ─────────────────────────────────────────────────────────────────────────────
// 2. Splash slides controller (dark Scapia-style PageView)
// ─────────────────────────────────────────────────────────────────────────────
class SplashState {
  final int index;
  final int total;
  const SplashState({required this.index, required this.total});
  bool get isLast => index == total - 1;
  SplashState copyWith({int? index}) => SplashState(index: index ?? this.index, total: total);
}

class SplashNotifier extends Notifier<SplashState> {
  late final PageController pageController;

  @override
  SplashState build() {
    pageController = PageController();
    ref.onDispose(pageController.dispose);
    return SplashState(index: 0, total: OnboardingSlidesData.slides.length);
  }

  void onPageChanged(int i) => state = state.copyWith(index: i);

  void next() {
    if (state.isLast) return;
    pageController.nextPage(
        duration: const Duration(milliseconds: 420), curve: Curves.easeInOutCubic);
  }

  void skipToLast() => pageController.animateToPage(
      state.total - 1,
      duration: const Duration(milliseconds: 480), curve: Curves.easeInOutCubic);
}

final splashProvider = NotifierProvider<SplashNotifier, SplashState>(SplashNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// 3. Onboarding flow controller (profile-building steps)
// ─────────────────────────────────────────────────────────────────────────────
class FlowState {
  final OnboardingStep step;
  final OnboardingProfile profile;
  final bool isLoading;

  static const _profileSteps = [
    OnboardingStep.name, OnboardingStep.verifyEmail, OnboardingStep.dateOfBirth,
    OnboardingStep.educationGoal, OnboardingStep.learningStyle, OnboardingStep.currentJourney,
  ];
  static const _fractionSteps = [
    OnboardingStep.name, OnboardingStep.verifyEmail,
    OnboardingStep.dateOfBirth, OnboardingStep.educationGoal,
  ];

  const FlowState({this.step = OnboardingStep.splash,
    this.profile = const OnboardingProfile(), this.isLoading = false});

  int get profileIdx   => _profileSteps.indexOf(step);
  int get totalProfile => _profileSteps.length;
  double get progress  { final i = profileIdx; return i < 0 ? 0.0 : (i + 1) / totalProfile; }
  String? get fraction { final i = _fractionSteps.indexOf(step); return i < 0 ? null : '${i+1}/${_fractionSteps.length}'; }

  FlowState copyWith({OnboardingStep? step, OnboardingProfile? profile, bool? isLoading}) =>
      FlowState(step: step ?? this.step, profile: profile ?? this.profile, isLoading: isLoading ?? this.isLoading);
}

class FlowNotifier extends Notifier<FlowState> {
  @override FlowState build() => const FlowState();

  void goTo(OnboardingStep s) => state = state.copyWith(step: s);

  void next() {
    final steps = FlowState._profileSteps;
    final cur = state.step;
    if (cur == OnboardingStep.splash)   { state = state.copyWith(step: OnboardingStep.welcome); return; }
    if (cur == OnboardingStep.welcome)  { state = state.copyWith(step: OnboardingStep.name);    return; }
    final i = steps.indexOf(cur);
    if (i >= 0 && i < steps.length - 1) state = state.copyWith(step: steps[i + 1]);
    else if (i == steps.length - 1)     state = state.copyWith(step: OnboardingStep.planReady);
  }

  void back() {
    final steps = FlowState._profileSteps;
    final cur = state.step;
    if (cur == OnboardingStep.welcome)  { state = state.copyWith(step: OnboardingStep.splash);  return; }
    if (cur == OnboardingStep.planReady){ state = state.copyWith(step: steps.last);             return; }
    final i = steps.indexOf(cur);
    if (i > 0)      state = state.copyWith(step: steps[i - 1]);
    else if (i == 0)state = state.copyWith(step: OnboardingStep.welcome);
  }

  void setName(String first, String last)   => state = state.copyWith(profile: state.profile.copyWith(firstName: first, lastName: last));
  void setEmail(String email)                => state = state.copyWith(profile: state.profile.copyWith(email: email));
  void setDob(DateTime dob)                  => state = state.copyWith(profile: state.profile.copyWith(dateOfBirth: dob));
  void setGoal(String id)                    => state = state.copyWith(profile: state.profile.copyWith(examGoalId: id));
  void setLearning(String id)                => state = state.copyWith(profile: state.profile.copyWith(learningStyleId: id));
  void setJourney(String id)                 => state = state.copyWith(profile: state.profile.copyWith(journeyLevelId: id));
  void setLoading(bool v)                    => state = state.copyWith(isLoading: v);
}

final flowProvider = NotifierProvider<FlowNotifier, FlowState>(FlowNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// 4. Auth controller
// ─────────────────────────────────────────────────────────────────────────────
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repo;

  @override
  AuthState build() {
    _repo = ref.read(authRepositoryProvider);
    final uid = _repo.currentUserId;
    if (uid != null) return AuthState.authenticated(userId: uid, email: _repo.currentUserEmail ?? '', displayName: _repo.currentUserDisplayName);
    return const AuthState.unauthenticated();
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = const AuthState.loading();
    try {
      final uid = await _repo.signInWithEmail(email: email, password: password);
      state = AuthState.authenticated(userId: uid, email: email);
      return true;
    } on AuthException catch (e) { state = const AuthState.unauthenticated().copyWithError(e.message); return false; }
  }

  Future<bool> register({required String email, required String password}) async {
    state = const AuthState.loading();
    try {
      final uid = await _repo.registerWithEmail(email: email, password: password);
      await _repo.sendEmailVerification();
      state = AuthState.authenticated(userId: uid, email: email);
      return true;
    } on AuthException catch (e) { state = const AuthState.unauthenticated().copyWithError(e.message); return false; }
  }

  Future<bool> googleSignIn() async {
    state = const AuthState.loading();
    try {
      final uid = await _repo.signInWithGoogle();
      state = AuthState.authenticated(userId: uid, email: _repo.currentUserEmail ?? '', displayName: _repo.currentUserDisplayName);
      return true;
    } on AuthException catch (e) { state = const AuthState.unauthenticated().copyWithError(e.message); return false; }
  }

  Future<void> saveProfile({required String uid, required Map<String, dynamic> data}) async {
    try { await _repo.saveProfile(uid: uid, data: data); } catch (_) {}
  }

  Future<void> signOut() async { await _repo.signOut(); state = const AuthState.unauthenticated(); }
  Future<bool> resetPassword(String email) async { try { await _repo.sendPasswordResetEmail(email); return true; } catch (_) { return false; } }
  void clearError() { if (state.hasError) state = const AuthState.unauthenticated(); }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);