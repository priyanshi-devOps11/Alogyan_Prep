import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/onboarding_model.dart';
import '../data/user_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Repository provider
// ─────────────────────────────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>(
      (ref) => FirebaseAuthRepository(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Splash controller (4 dark slides)
// ─────────────────────────────────────────────────────────────────────────────
class SplashState {
  final int index;
  final int total;
  const SplashState({required this.index, required this.total});
  bool get isLast => index == total - 1;
  SplashState copyWith({int? index}) =>
      SplashState(index: index ?? this.index, total: total);
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
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
  }

  void skipToLast() => pageController.animateToPage(
    state.total - 1,
    duration: const Duration(milliseconds: 480),
    curve: Curves.easeInOutCubic,
  );
}

final splashProvider =
NotifierProvider<SplashNotifier, SplashState>(SplashNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding flow state
// ─────────────────────────────────────────────────────────────────────────────
class FlowState {
  final OnboardingStep step;
  final OnboardingProfile profile;
  final bool isLoading;
  // Phone OTP state
  final String? phoneVerificationId;
  final bool otpSent;

  static const _profileSteps = [
    OnboardingStep.name,
    OnboardingStep.verifyEmail,
    OnboardingStep.dateOfBirth,
    OnboardingStep.educationGoal,
    OnboardingStep.learningStyle,
    OnboardingStep.currentJourney,
  ];
  static const _fractionSteps = [
    OnboardingStep.name,
    OnboardingStep.verifyEmail,
    OnboardingStep.dateOfBirth,
    OnboardingStep.educationGoal,
  ];

  const FlowState({
    this.step = OnboardingStep.splash,
    this.profile = const OnboardingProfile(),
    this.isLoading = false,
    this.phoneVerificationId,
    this.otpSent = false,
  });

  int get profileIdx => _profileSteps.indexOf(step);
  int get totalProfile => _profileSteps.length;
  double get progress {
    final i = profileIdx;
    return i < 0 ? 0.0 : (i + 1) / totalProfile;
  }

  String? get fraction {
    final i = _fractionSteps.indexOf(step);
    return i < 0 ? null : '${i + 1}/${_fractionSteps.length}';
  }

  FlowState copyWith({
    OnboardingStep? step,
    OnboardingProfile? profile,
    bool? isLoading,
    String? phoneVerificationId,
    bool? otpSent,
  }) =>
      FlowState(
        step: step ?? this.step,
        profile: profile ?? this.profile,
        isLoading: isLoading ?? this.isLoading,
        phoneVerificationId: phoneVerificationId ?? this.phoneVerificationId,
        otpSent: otpSent ?? this.otpSent,
      );
}

class FlowNotifier extends Notifier<FlowState> {
  @override
  FlowState build() => const FlowState();

  void goTo(OnboardingStep s) => state = state.copyWith(step: s);

  void next() {
    final steps = FlowState._profileSteps;
    final cur = state.step;
    if (cur == OnboardingStep.splash) {
      state = state.copyWith(step: OnboardingStep.welcome);
      return;
    }
    if (cur == OnboardingStep.welcome) {
      state = state.copyWith(step: OnboardingStep.name);
      return;
    }
    final i = steps.indexOf(cur);
    if (i >= 0 && i < steps.length - 1) {
      state = state.copyWith(step: steps[i + 1]);
    } else if (i == steps.length - 1) {
      state = state.copyWith(step: OnboardingStep.planReady);
    }
  }

  void back() {
    final steps = FlowState._profileSteps;
    final cur = state.step;
    if (cur == OnboardingStep.welcome) {
      state = state.copyWith(step: OnboardingStep.splash);
      return;
    }
    if (cur == OnboardingStep.planReady) {
      state = state.copyWith(step: steps.last);
      return;
    }
    final i = steps.indexOf(cur);
    if (i > 0) {
      state = state.copyWith(step: steps[i - 1]);
    } else if (i == 0) {
      state = state.copyWith(step: OnboardingStep.welcome);
    }
  }

  void setName(String first, String last) => state = state.copyWith(
      profile: state.profile.copyWith(firstName: first, lastName: last));
  void setEmail(String email) =>
      state = state.copyWith(profile: state.profile.copyWith(email: email));
  void setDob(DateTime dob) =>
      state = state.copyWith(profile: state.profile.copyWith(dateOfBirth: dob));
  void setGoal(String id) =>
      state = state.copyWith(profile: state.profile.copyWith(examGoalId: id));
  void setLearning(String id) =>
      state = state.copyWith(profile: state.profile.copyWith(learningStyleId: id));
  void setJourney(String id) =>
      state = state.copyWith(profile: state.profile.copyWith(journeyLevelId: id));
  void setLoading(bool v) => state = state.copyWith(isLoading: v);
  void setPhoneVerificationId(String id) =>
      state = state.copyWith(phoneVerificationId: id, otpSent: true);
  void resetOtp() => state = state.copyWith(otpSent: false, phoneVerificationId: null);
}

final flowProvider =
NotifierProvider<FlowNotifier, FlowState>(FlowNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Auth state
// ─────────────────────────────────────────────────────────────────────────────
enum AuthStatus { initial, loading, authenticated, unauthenticated, error, emailPendingVerification }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? errorMessage;
  final UserModel? userModel;

  const AuthState({
    required this.status,
    this.userId,
    this.email,
    this.displayName,
    this.errorMessage,
    this.userModel,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        userId = null,
        email = null,
        displayName = null,
        errorMessage = null,
        userModel = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        userId = null,
        email = null,
        displayName = null,
        errorMessage = null,
        userModel = null;

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        userId = null,
        email = null,
        displayName = null,
        errorMessage = null,
        userModel = null;

  AuthState.authenticated({
    required String userId,
    required String email,
    String? displayName,
    UserModel? userModel,
  })  : status = AuthStatus.authenticated,
        userId = userId,
        email = email,
        displayName = displayName,
        errorMessage = null,
        userModel = userModel;

  AuthState copyWithError(String msg) => AuthState(
    status: AuthStatus.error,
    userId: userId,
    email: email,
    displayName: displayName,
    errorMessage: msg,
    userModel: userModel,
  );

  AuthState copyWithPendingVerification(String userId, String email) => AuthState(
    status: AuthStatus.emailPendingVerification,
    userId: userId,
    email: email,
    displayName: displayName,
    userModel: userModel,
  );

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get hasError => status == AuthStatus.error;
  bool get isPendingVerification => status == AuthStatus.emailPendingVerification;
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth Notifier
// ─────────────────────────────────────────────────────────────────────────────
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repo;

  @override
  AuthState build() {
    _repo = ref.read(authRepositoryProvider);
    final uid = _repo.currentUserId;
    if (uid != null) {
      // Load user model in background
      Future.microtask(() => _loadUserModel(uid));
      return AuthState.authenticated(
        userId: uid,
        email: _repo.currentUserEmail ?? '',
        displayName: _repo.currentUserDisplayName,
      );
    }
    return const AuthState.unauthenticated();
  }

  Future<void> _loadUserModel(String uid) async {
    final user = await _repo.fetchUserModel(uid);
    if (user != null && state.isAuthenticated) {
      state = AuthState.authenticated(
        userId: uid,
        email: user.email,
        displayName: user.displayName,
        userModel: user,
      );
    }
  }

  // ── Sign in with email ─────────────────────────────────────────────────────
  Future<bool> signIn({required String email, required String password}) async {
    state = const AuthState.loading();
    try {
      final uid = await _repo.signInWithEmail(email: email, password: password);
      final userModel = await _repo.fetchUserModel(uid);
      state = AuthState.authenticated(
        userId: uid,
        email: email,
        displayName: userModel?.displayName,
        userModel: userModel,
      );
      return true;
    } on AuthException catch (e) {
      state = const AuthState.unauthenticated().copyWithError(e.message);
      return false;
    }
  }

  // ── Register with email → send verification → wait ───────────────────────
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final uid = await _repo.registerWithEmail(email: email, password: password);
      // Send verification email
      await _repo.sendVerificationEmail();
      // Move to "pending verification" state — user must verify before proceeding
      state = state.copyWithPendingVerification(uid, email);
      return true;
    } on AuthException catch (e) {
      state = const AuthState.unauthenticated().copyWithError(e.message);
      return false;
    }
  }

  // ── Poll Firebase to check if email is now verified ────────────────────────
  Future<bool> checkEmailVerified() async {
    final verified = await _repo.checkEmailVerified();
    if (verified && state.userId != null) {
      state = AuthState.authenticated(
        userId: state.userId!,
        email: state.email ?? '',
        displayName: state.displayName,
      );
    }
    return verified;
  }

  // ── Google sign in ─────────────────────────────────────────────────────────
  Future<bool> googleSignIn() async {
    state = const AuthState.loading();
    try {
      final uid = await _repo.signInWithGoogle();
      final email = _repo.currentUserEmail ?? '';
      final displayName = _repo.currentUserDisplayName;
      final userModel = await _repo.fetchUserModel(uid);
      state = AuthState.authenticated(
        userId: uid,
        email: email,
        displayName: displayName,
        userModel: userModel,
      );
      return true;
    } on AuthException catch (e) {
      state = const AuthState.unauthenticated().copyWithError(e.message);
      return false;
    }
  }

  // ── Phone OTP — send ───────────────────────────────────────────────────────
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    state = const AuthState.loading();
    await _repo.sendPhoneOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (vid) {
        state = const AuthState.unauthenticated();
        onCodeSent(vid);
      },
      onError: (err) {
        state = const AuthState.unauthenticated().copyWithError(err);
        onError(err);
      },
    );
  }

  // ── Phone OTP — verify ─────────────────────────────────────────────────────
  Future<bool> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    state = const AuthState.loading();
    try {
      final uid = await _repo.verifyPhoneOtp(
          verificationId: verificationId, smsCode: smsCode);
      final email = _repo.currentUserEmail ?? '';
      state = AuthState.authenticated(userId: uid, email: email);
      return true;
    } on AuthException catch (e) {
      state = const AuthState.unauthenticated().copyWithError(e.message);
      return false;
    }
  }

  // ── Save full UserModel to Firestore ───────────────────────────────────────
  Future<void> saveUserModel({
    required String uid,
    required String email,
    required OnboardingProfile profile,
    String authProvider = 'email',
  }) async {
    final user = UserModel(
      uid: uid,
      email: email,
      firstName: profile.firstName ?? '',
      lastName: profile.lastName ?? '',
      phoneNumber: null,
      dateOfBirth: profile.dateOfBirth,
      examGoalId: profile.examGoalId,
      learningStyleId: profile.learningStyleId,
      journeyLevelId: profile.journeyLevelId,
      onboardingCompleted: true,
      emailVerified: _repo.isEmailVerified,
      authProvider: authProvider,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    await _repo.saveUserModel(user);
    state = AuthState.authenticated(
      userId: uid,
      email: email,
      displayName: user.displayName,
      userModel: user,
    );
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState.unauthenticated();
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _repo.sendPasswordResetEmail(email);
      return true;
    } catch (_) {
      return false;
    }
  }

  void clearError() {
    if (state.hasError) state = const AuthState.unauthenticated();
  }
}

final authProvider =
NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);