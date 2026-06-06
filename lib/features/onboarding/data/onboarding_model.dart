/// Domain layer — pure Dart, zero Flutter/Firebase imports.
/// All models are immutable and null-safe.

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding Slide Model
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingSlide {
  final String accentTag;
  final String title;
  final String subtitle;
  final String description;
  final String assetPath;

  const OnboardingSlide({
    required this.accentTag,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.assetPath,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Static onboarding content
// ─────────────────────────────────────────────────────────────────────────────

abstract class OnboardingContent {
  static const List<OnboardingSlide> slides = [
    OnboardingSlide(
      accentTag: 'EXAM PREP · MADE SIMPLE',
      title: 'Master Every\nExam with Ease',
      subtitle: 'Your smart preparation hub',
      description:
      'Access thousands of curated questions, mock tests, and study notes — all in one place.',
      assetPath: 'assets/images/onboarding_1.png',
    ),
    OnboardingSlide(
      accentTag: 'DAILY CURRENT AFFAIRS',
      title: 'Stay Ahead,\nEvery Single Day',
      subtitle: 'News distilled for competitive exams',
      description:
      'Get daily GK updates filtered by Economy, Politics, Science and more — no noise, just what matters.',
      assetPath: 'assets/images/onboarding_2.png',
    ),
    OnboardingSlide(
      accentTag: 'PERFORMANCE ANALYTICS',
      title: 'Know Where\nYou Stand',
      subtitle: 'Detailed reports & insights',
      description:
      'Track test scores, identify weak topics, and get personalised recommendations to improve faster.',
      assetPath: 'assets/images/onboarding_3.png',
    ),
    OnboardingSlide(
      accentTag: 'PDF BUNDLES & MORE',
      title: 'All Study\nMaterial. One App.',
      subtitle: 'Offline-ready PDF bundles',
      description:
      'Download study notes and PDF bundles. Read anytime, anywhere — even without internet.',
      assetPath: 'assets/images/onboarding_4.png',
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth State Model
// ─────────────────────────────────────────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.userId,
    this.email,
    this.errorMessage,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        userId = null,
        email = null,
        errorMessage = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        userId = null,
        email = null,
        errorMessage = null;

  const AuthState.authenticated({required String userId, required String email})
      : status = AuthStatus.authenticated,
        userId = userId,
        email = email,
        errorMessage = null;

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        userId = null,
        email = null,
        errorMessage = null;

  AuthState copyWithError(String message) => AuthState(
    status: AuthStatus.error,
    errorMessage: message,
    userId: userId,
    email: email,
  );

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get hasError => status == AuthStatus.error;
}

// ─────────────────────────────────────────────────────────────────────────────
// Firestore user profile model
// ─────────────────────────────────────────────────────────────────────────────

class StudentProfile {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final bool onboardingCompleted;

  const StudentProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    required this.onboardingCompleted,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'createdAt': createdAt.toIso8601String(),
    'onboardingCompleted': onboardingCompleted,
  };

  factory StudentProfile.fromMap(Map<String, dynamic> map) => StudentProfile(
    uid: map['uid'] as String,
    email: map['email'] as String,
    displayName: map['displayName'] as String,
    createdAt: DateTime.parse(map['createdAt'] as String),
    onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
  );
}