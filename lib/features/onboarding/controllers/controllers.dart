import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';
import 'package:alogyan_prep/features/onboarding/data/auth_repository.dart';
import 'package:alogyan_prep/features/onboarding/data/user_model.dart';

// ── Repository provider ───────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>(
      (_) => FirebaseAuthRepository(),
);

// SPLASH (4 dark intro slides)
class SplashState {
  final int index, total;
  const SplashState({required this.index, required this.total});
  bool get isLast => index == total - 1;
  SplashState copyIndex(int i) => SplashState(index: i, total: total);
}

class SplashNotifier extends Notifier<SplashState> {
  late final PageController pageController;

  @override
  SplashState build() {
    pageController = PageController();
    ref.onDispose(pageController.dispose);
    return SplashState(index: 0, total: OnboardingSlidesData.slides.length);
  }

  void onPageChanged(int i) => state = state.copyIndex(i);

  void nextPage() {
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

// FLOW STATE MACHINE
class FlowState {
  final OnboardingStep step;
  final OnboardingProfile profile;
  final bool isLoading;

  // Steps shown in the 1/4 2/4 fraction header
  static const _fractionSteps = [
    OnboardingStep.name,
    OnboardingStep.verifyEmail,
    OnboardingStep.dateOfBirth,
    OnboardingStep.educationGoal,
  ];

  // All sequential profile-building steps for progress bar & next() logic
  static const _profileSteps = [
    OnboardingStep.name,
    OnboardingStep.verifyEmail,
    OnboardingStep.dateOfBirth,
    OnboardingStep.educationGoal,
    OnboardingStep.learningStyle,
    OnboardingStep.currentJourney,
  ];

  const FlowState({
    this.step      = OnboardingStep.splash,
    this.profile   = const OnboardingProfile(),
    this.isLoading = false,
  });

  int get profileIdx => _profileSteps.indexOf(step);

  double get progress {
    final i = profileIdx;
    return i < 0 ? 0.0 : (i + 1) / _profileSteps.length;
  }

  String? get fraction {
    final i = _fractionSteps.indexOf(step);
    return i < 0 ? null : '${i + 1}/${_fractionSteps.length}';
  }

  FlowState copyWith({
    OnboardingStep? step,
    OnboardingProfile? profile,
    bool? isLoading,
  }) => FlowState(
    step:      step      ?? this.step,
    profile:   profile   ?? this.profile,
    isLoading: isLoading ?? this.isLoading,
  );
}

class FlowNotifier extends Notifier<FlowState> {
  late final AuthRepository _repo;

  @override
  FlowState build() {
    _repo = ref.read(authRepositoryProvider);
    return const FlowState();
  }

  void goTo(OnboardingStep s) => state = state.copyWith(step: s);

  void next() {
    final steps = FlowState._profileSteps;
    final cur   = state.step;

    if (cur == OnboardingStep.splash)  { state = state.copyWith(step: OnboardingStep.welcome);  return; }
    if (cur == OnboardingStep.welcome) { state = state.copyWith(step: OnboardingStep.name);      return; }

    // emailVerifyWait is an overlay state — not in _profileSteps.
    // After verification, always continue to dateOfBirth.
    if (cur == OnboardingStep.emailVerifyWait) {
      state = state.copyWith(step: OnboardingStep.dateOfBirth);
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
    final cur   = state.step;

    if (cur == OnboardingStep.welcome)   { state = state.copyWith(step: OnboardingStep.splash); return; }
    if (cur == OnboardingStep.planReady) { state = state.copyWith(step: steps.last);            return; }

    final i = steps.indexOf(cur);
    if (i > 0)       state = state.copyWith(step: steps[i - 1]);
    else if (i == 0) state = state.copyWith(step: OnboardingStep.welcome);
  }

  // ── Profile setters (each triggers incremental Firestore save) ────────────
  void setName(String first, String last) {
    state = state.copyWith(
        profile: state.profile.copyWith(firstName: first, lastName: last));
    _incrementalSave();
  }

  void setEmail(String email) =>
      state = state.copyWith(profile: state.profile.copyWith(email: email));

  void setDob(DateTime dob) {
    state = state.copyWith(profile: state.profile.copyWith(dateOfBirth: dob));
    _incrementalSave();
  }

  void setGoal(String id) {
    state = state.copyWith(profile: state.profile.copyWith(examGoalId: id));
    _incrementalSave();
  }

  void setLearning(String id) {
    state = state.copyWith(profile: state.profile.copyWith(learningStyleId: id));
    _incrementalSave();
  }

  void setJourney(String id) {
    state = state.copyWith(profile: state.profile.copyWith(journeyLevelId: id));
    _incrementalSave();
  }

  void setLoading(bool v) => state = state.copyWith(isLoading: v);

  // Writes partial profile to Firestore after every step (merge:true).
  // Never blocks UI — fire-and-forget.
  void _incrementalSave() {
    final uid = _repo.currentUserId;
    if (uid == null) return;
    final p = state.profile;
    final partial = UserModel(
      uid:                     uid,
      email:                   p.email ?? _repo.currentUserEmail ?? '',
      firstName:               p.firstName   ?? '',
      lastName:                p.lastName    ?? '',
      dob:                     p.dateOfBirth?.toIso8601String(),
      selectedExamGoalId:      p.examGoalId,
      selectedLearningStyleId: p.learningStyleId,
      selectedJourneyLevelId:  p.journeyLevelId,
      isOnboardingCompleted:   false,
    );
    _repo.saveUserModel(partial).catchError((_) {});
  }
}

final flowProvider =
NotifierProvider<FlowNotifier, FlowState>(FlowNotifier.new);


// AUTH STATE
class AuthState {
  final AuthStatus status;
  final String?    userId, email, displayName, errorMessage;
  final UserModel? userModel;
  final bool       isDeveloperError;

  const AuthState({
    required this.status,
    this.userId, this.email, this.displayName,
    this.errorMessage, this.userModel,
    this.isDeveloperError = false,
  });

  const AuthState.initial()
      : status = AuthStatus.initial, userId = null, email = null,
        displayName = null, errorMessage = null, userModel = null,
        isDeveloperError = false;

  const AuthState.loading()
      : status = AuthStatus.loading, userId = null, email = null,
        displayName = null, errorMessage = null, userModel = null,
        isDeveloperError = false;

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated, userId = null, email = null,
        displayName = null, errorMessage = null, userModel = null,
        isDeveloperError = false;

  AuthState.authenticated({
    required String userId,
    required String email,
    String? displayName,
    UserModel? userModel,
  })  : status = AuthStatus.authenticated,
        userId = userId, email = email,
        displayName = displayName,
        errorMessage = null,
        userModel = userModel,
        isDeveloperError = false;

  AuthState copyWithError(String msg, {bool devError = false}) => AuthState(
    status: AuthStatus.error,
    userId: userId, email: email, displayName: displayName,
    errorMessage: msg, userModel: userModel,
    isDeveloperError: devError,
  );

  AuthState copyWithPending(String uid, String email) => AuthState(
    status: AuthStatus.emailPendingVerification,
    userId: uid, email: email,
    displayName: displayName, userModel: userModel,
  );

  bool get isLoading       => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get hasError        => status == AuthStatus.error;
  bool get isPendingVerify => status == AuthStatus.emailPendingVerification;
}

// AUTH NOTIFIER
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repo;

  @override
  AuthState build() {
    _repo = ref.read(authRepositoryProvider);
    final uid = _repo.currentUserId;
    if (uid != null) {
      Future.microtask(() => _hydrateUserModel(uid));
      return AuthState.authenticated(
        userId: uid,
        email: _repo.currentUserEmail ?? '',
        displayName: _repo.currentUserDisplayName,
      );
    }
    return const AuthState.unauthenticated();
  }

  // Load UserModel from Firestore and update state with it.
  Future<void> _hydrateUserModel(String uid) async {
    if (!state.isAuthenticated) return;

    final user = await _repo.fetchUserModel(uid);

    if (user != null) {
      state = AuthState.authenticated(
        userId: uid,
        email: user.email,
        displayName: user.displayName,
        userModel: user,
      );
      return;
    }

    // No Firestore doc found — create a minimal placeholder so
    // _AuthGate can proceed instead of stalling forever.
    final placeholder = UserModel(
      uid: uid,
      email: _repo.currentUserEmail ?? state.email ?? '',
      firstName: '',
      lastName: '',
      authProvider: 'email',
      isOnboardingCompleted: false,
    );
    state = AuthState.authenticated(
      userId: uid,
      email: placeholder.email,
      displayName: state.displayName,
      userModel: placeholder,
    );
  }

  // ── Email sign in ─────────────────────────────────────────────────────────
  Future<bool> signIn({required String email, required String password}) async {
    state = const AuthState.loading();
    try {
      final uid  = await _repo.signInWithEmail(email: email, password: password);
      final user = await _repo.fetchUserModel(uid);
      final flow = ref.read(flowProvider.notifier);

      // If onboarding was already completed, _AuthGate handles routing to
      // BundleListingScreen. Otherwise, resume from where they left off.
      if (user != null && !user.isOnboardingCompleted) {
        _resumePendingStep(user, flow);
      }

      state = AuthState.authenticated(
        userId: uid, email: email,
        displayName: user?.displayName,
        userModel: user,
      );
      return true;
    } on AuthException catch (e) {
      state = const AuthState.unauthenticated()
          .copyWithError(e.message, devError: e.isDeveloperError);
      return false;
    }
  }

  // ── Email register → send verification → pending ──────────────────────────
  Future<bool> register({required String email, required String password}) async {
    state = const AuthState.loading();
    try {
      final uid = await _repo.registerWithEmail(email: email, password: password);
      // Create initial Firestore record so we can resume later
      final flowProfile = ref.read(flowProvider).profile;
      await _repo.saveUserModel(UserModel(
        uid: uid, email: email,
        firstName:    flowProfile.firstName ?? '',
        lastName:     flowProfile.lastName  ?? '',
        authProvider: 'email',
        isOnboardingCompleted: false,
      ), isNew: true);
      await _repo.sendVerificationEmail();

      ref.read(flowProvider.notifier).goTo(OnboardingStep.verifyEmail);
      state = const AuthState.unauthenticated().copyWithPending(uid, email);
      return true;
    } on AuthException catch (e) {
      state = const AuthState.unauthenticated()
          .copyWithError(e.message, devError: e.isDeveloperError);
      return false;
    }
  }

  // ── Poll email verified ────────────────────────────────────────────────────
  // checkEmailVerified() :
  Future<bool> checkEmailVerified() async {
    final verified = await _repo.checkEmailVerified();
    if (verified && state.userId != null) {
      final uid  = state.userId!;
      final email = state.email ?? '';

      // KEY FIX: fetch or create Firestore doc before setting authenticated
      // so _AuthGate never sees userModel == null and gets stuck on spinner
      var user = await _repo.fetchUserModel(uid);
      if (user == null) {
        final flowProfile = ref.read(flowProvider).profile;
        user = UserModel(
          uid:                   uid,
          email:                 email,
          firstName:             flowProfile.firstName ?? '',
          lastName:              flowProfile.lastName  ?? '',
          authProvider:          'email',
          isOnboardingCompleted: false,
        );
        await _repo.saveUserModel(user, isNew: true);
      }

      // Set flow BEFORE authenticated so router has destination ready
      ref.read(flowProvider.notifier).goTo(OnboardingStep.dateOfBirth);

      state = AuthState.authenticated(
        userId:    uid,
        email:     email,
        userModel: user,
      );
    }
    return verified;
  }

  // ── Google sign in — FORCE INTERCEPT ─────────────────────────────────────
  // Step order:
  //   1. Firebase handshake → get uid
  //   2. Fetch/create Firestore user record
  //   3. INJECT flow step → OnboardingStep.dateOfBirth  ← KEY FIX
  //   4. THEN set AuthState.authenticated
  // This guarantees the router has a valid destination BEFORE the widget
  Future<bool> googleSignIn() async {
    state = const AuthState.loading();
    try {
      final uid         = await _repo.signInWithGoogle();
      final email       = _repo.currentUserEmail ?? '';
      final displayName = _repo.currentUserDisplayName;
      final flow        = ref.read(flowProvider.notifier);

      var user = await _repo.fetchUserModel(uid);
      if (user == null) {
        // First-time Google user — create Firestore record
        final parts = (displayName ?? '').split(' ');
        user = UserModel(
          uid: uid, email: email,
          firstName:    parts.isNotEmpty ? parts.first : '',
          lastName:     parts.length > 1  ? parts.last  : '',
          authProvider: 'google',
          isOnboardingCompleted: false,
        );
        await _repo.saveUserModel(user, isNew: true);
      }

      if (user.isOnboardingCompleted) {
        // Returning user who finished onboarding — _AuthGate will route to
        // BundleListingScreen when it sees isOnboardingCompleted == true.
      } else {
        _resumePendingStep(user, flow);
      }

      // NOW set authenticated state — widget tree rebuilds with a destination
      state = AuthState.authenticated(
        userId: uid, email: email,
        displayName: user.displayName,
        userModel: user,
      );
      return true;
    } on AuthException catch (e) {
      state = const AuthState.unauthenticated()
          .copyWithError(e.message, devError: e.isDeveloperError);
      return false;
    }
  }

  // ── Phone OTP send ────────────────────────────────────────────────────────
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String) onCodeSent,
    required void Function(String) onError,
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

  // ── Phone OTP verify — FORCE INTERCEPT ───────────────────────────────────
  // Same pattern as googleSignIn:
  //   1. Verify OTP → get uid
  //   2. Fetch/create Firestore record
  //   3. INJECT flow step → OnboardingStep.dateOfBirth  ← KEY FIX
  //   4. THEN set AuthState.authenticated
  Future<bool> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    state = const AuthState.loading();
    try {
      final uid   = await _repo.verifyPhoneOtp(
          verificationId: verificationId, smsCode: smsCode);
      final email = _repo.currentUserEmail ?? '';
      final flow  = ref.read(flowProvider.notifier);

      var user = await _repo.fetchUserModel(uid);
      if (user == null) {
        user = UserModel(
          uid: uid, email: email,
          authProvider: 'phone',
          isOnboardingCompleted: false,
        );
        await _repo.saveUserModel(user, isNew: true);
      }

      if (user.isOnboardingCompleted) {
        // Returning phone user — _AuthGate handles routing to Bundle screen.
      } else {
        // ── FORCE INTERCEPT: flow step BEFORE auth state ──────────────────
        flow.goTo(OnboardingStep.dateOfBirth);
      }

      state = AuthState.authenticated(
        userId: uid, email: email,
        userModel: user,
      );
      return true;
    } on AuthException catch (e) {
      state = const AuthState.unauthenticated().copyWithError(e.message);
      return false;
    }
  }

  // ── Complete onboarding (called from PlanReadyScreen) ─────────────────────
  Future<void> completeOnboarding() async {
    final uid = state.userId;
    if (uid == null) return;
    final flow    = ref.read(flowProvider).profile;
    final existing = state.userModel;

    final user = UserModel(
      uid:                     uid,
      email:                   state.email ?? '',
      firstName:               flow.firstName   ?? existing?.firstName ?? '',
      lastName:                flow.lastName    ?? existing?.lastName  ?? '',
      dob:                     flow.dateOfBirth?.toIso8601String(),
      selectedExamGoalId:      flow.examGoalId,
      selectedLearningStyleId: flow.learningStyleId,
      selectedJourneyLevelId:  flow.journeyLevelId,
      isOnboardingCompleted:   true,          // ← gates _AuthGate to Bundle
      authProvider:            existing?.authProvider ?? 'email',
    );
    await _repo.saveUserModel(user);

    state = AuthState.authenticated(
      userId: uid, email: state.email ?? '',
      displayName: user.displayName,
      userModel: user,
    );
  }

  // ── Sign out — full state cleanup ─────────────────────────────────────────
  Future<void> signOut() async {
    await _repo.signOut();
    // Reset flow to splash BEFORE clearing auth state so the router
    ref.read(flowProvider.notifier).goTo(OnboardingStep.splash);
    state = const AuthState.unauthenticated();
  }

  Future<bool> resetPassword(String email) async {
    try { await _repo.sendPasswordResetEmail(email); return true; }
    catch (_) { return false; }
  }

  void clearError() {
    if (state.hasError || state.isPendingVerify) {
      state = const AuthState.unauthenticated();
    }
  }

  // ── Helper: resume from last completed step for returning users ───────────
  void _resumePendingStep(UserModel user, FlowNotifier flow) {
    // Walk Firestore fields to find the furthest completed step
    if (user.selectedJourneyLevelId != null) {
      flow.goTo(OnboardingStep.planReady);
    } else if (user.selectedLearningStyleId != null) {
      flow.goTo(OnboardingStep.currentJourney);
    } else if (user.selectedExamGoalId != null) {
      flow.goTo(OnboardingStep.learningStyle);
    } else if (user.dob != null) {
      flow.goTo(OnboardingStep.educationGoal);
    } else {
      // Has an account but no profile data — start from DOB
      flow.goTo(OnboardingStep.dateOfBirth);
    }
  }
}

final authProvider =
NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);