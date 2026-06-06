/// Pure Dart domain layer — no Flutter or Firebase imports.

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding step enum — each screen in the multi-step flow
// ─────────────────────────────────────────────────────────────────────────────

enum OnboardingStep {
  welcome,        // Step 0: Welcome splash + Google / Email CTA
  name,           // Step 1/4: What should we call you?
  verifyEmail,    // Step 2/4: Which email do you use most?
  dateOfBirth,    // Step 3/4: When's your happy birthday?
  educationGoal,  // Step 4/4: What are you preparing for?
  learningStyle,  // How do you learn best?
  currentJourney, // Where are you in your journey?
  planReady,      // Your Personalized Study Plan Is Ready
}

// ─────────────────────────────────────────────────────────────────────────────
// Education Goal option
// ─────────────────────────────────────────────────────────────────────────────

class ExamGoal {
  final String id;
  final String label;
  final String iconAsset; // path to icon in assets/icons/
  final String fallbackEmoji;

  const ExamGoal({
    required this.id,
    required this.label,
    required this.iconAsset,
    required this.fallbackEmoji,
  });
}

abstract class ExamGoals {
  static const List<ExamGoal> all = [
    ExamGoal(id: 'ssc', label: 'SSC', iconAsset: 'assets/icons/ssc.png', fallbackEmoji: '📝'),
    ExamGoal(id: 'railway', label: 'Railway', iconAsset: 'assets/icons/railway.png', fallbackEmoji: '🚂'),
    ExamGoal(id: 'banking', label: 'Banking', iconAsset: 'assets/icons/banking.png', fallbackEmoji: '🏦'),
    ExamGoal(id: 'upsc', label: 'UPSC', iconAsset: 'assets/icons/upsc.png', fallbackEmoji: '🏛️'),
    ExamGoal(id: 'state_psc', label: 'State PSC', iconAsset: 'assets/icons/state_psc.png', fallbackEmoji: '🏢'),
    ExamGoal(id: 'teaching', label: 'Teaching', iconAsset: 'assets/icons/teaching.png', fallbackEmoji: '👨‍🏫'),
    ExamGoal(id: 'jee', label: 'JEE', iconAsset: 'assets/icons/jee.png', fallbackEmoji: '⚙️'),
    ExamGoal(id: 'neet', label: 'NEET', iconAsset: 'assets/icons/neet.png', fallbackEmoji: '🩺'),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Learning style option
// ─────────────────────────────────────────────────────────────────────────────

class LearningStyle {
  final String id;
  final String label;
  final String emoji;

  const LearningStyle({required this.id, required this.label, required this.emoji});
}

abstract class LearningStyles {
  static const List<LearningStyle> all = [
    LearningStyle(id: 'video', label: 'Video Classes', emoji: '🎬'),
    LearningStyle(id: 'mock', label: 'Mock Tests', emoji: '📊'),
    LearningStyle(id: 'daily_quiz', label: 'Daily Quiz', emoji: '❓'),
    LearningStyle(id: 'pdf', label: 'PDF Notes', emoji: '📄'),
    LearningStyle(id: 'live', label: 'Live Sessions', emoji: '📡'),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Current journey / class level
// ─────────────────────────────────────────────────────────────────────────────

class JourneyLevel {
  final String id;
  final String label;

  const JourneyLevel({required this.id, required this.label});
}

abstract class JourneyLevels {
  static const List<JourneyLevel> all = [
    JourneyLevel(id: 'class_10', label: 'Class 10'),
    JourneyLevel(id: 'class_12', label: 'Class 12'),
    JourneyLevel(id: 'graduate', label: 'Graduate'),
    JourneyLevel(id: 'post_graduate', label: 'Post Graduate'),
    JourneyLevel(id: 'working', label: 'Working Professional'),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Collected onboarding data — filled step by step
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingProfile {
  final String? firstName;
  final String? lastName;
  final String? email;
  final DateTime? dateOfBirth;
  final String? selectedExamGoalId;
  final String? selectedLearningStyleId;
  final String? selectedJourneyLevelId;

  const OnboardingProfile({
    this.firstName,
    this.lastName,
    this.email,
    this.dateOfBirth,
    this.selectedExamGoalId,
    this.selectedLearningStyleId,
    this.selectedJourneyLevelId,
  });

  OnboardingProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    DateTime? dateOfBirth,
    String? selectedExamGoalId,
    String? selectedLearningStyleId,
    String? selectedJourneyLevelId,
  }) =>
      OnboardingProfile(
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        selectedExamGoalId: selectedExamGoalId ?? this.selectedExamGoalId,
        selectedLearningStyleId:
        selectedLearningStyleId ?? this.selectedLearningStyleId,
        selectedJourneyLevelId:
        selectedJourneyLevelId ?? this.selectedJourneyLevelId,
      );

  String get displayName => [firstName, lastName]
      .where((s) => s != null && s.isNotEmpty)
      .join(' ');

  Map<String, dynamic> toFirestoreMap() => {
    'firstName': firstName ?? '',
    'lastName': lastName ?? '',
    'email': email ?? '',
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'examGoal': selectedExamGoalId,
    'learningStyle': selectedLearningStyleId,
    'journeyLevel': selectedJourneyLevelId,
    'onboardingCompleted': true,
    'createdAt': DateTime.now().toIso8601String(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth State
// ─────────────────────────────────────────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.userId,
    this.email,
    this.displayName,
    this.errorMessage,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        userId = null,
        email = null,
        displayName = null,
        errorMessage = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        userId = null,
        email = null,
        displayName = null,
        errorMessage = null;

  AuthState.authenticated({
    required String userId,
    required String email,
    String? displayName,
  })  : status = AuthStatus.authenticated,
        userId = userId,
        email = email,
        displayName = displayName,
        errorMessage = null;

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        userId = null,
        email = null,
        displayName = null,
        errorMessage = null;

  AuthState copyWithError(String message) => AuthState(
    status: AuthStatus.error,
    userId: userId,
    email: email,
    displayName: displayName,
    errorMessage: message,
  );

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get hasError => status == AuthStatus.error;
}