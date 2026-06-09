// ─── Onboarding splash slides (dark Scapia-style) ─────────────────────────────
class OnboardingSlide {
  final String accentTag;
  final String title;
  final String subtitle;
  final String description;
  final String assetPath;
  const OnboardingSlide({
    required this.accentTag, required this.title,
    required this.subtitle,  required this.description,
    required this.assetPath,
  });
}

abstract class OnboardingSlidesData {
  static const List<OnboardingSlide> slides = [
    OnboardingSlide(
      accentTag: 'EXAM PREP · MADE SIMPLE',
      title: 'Master Every\nExam with Ease',
      subtitle: 'Your smart preparation hub',
      description: 'Access thousands of curated questions, mock tests, and study notes — all in one place.',
      assetPath: 'assets/images/onboarding_1.png',
    ),
    OnboardingSlide(
      accentTag: 'DAILY CURRENT AFFAIRS',
      title: 'Stay Ahead,\nEvery Single Day',
      subtitle: 'News distilled for competitive exams',
      description: 'Get daily GK updates filtered by Economy, Politics, Science and more — no noise, just what matters.',
      assetPath: 'assets/images/onboarding_2.png',
    ),
    OnboardingSlide(
      accentTag: 'PERFORMANCE ANALYTICS',
      title: 'Know Where\nYou Stand',
      subtitle: 'Detailed reports & insights',
      description: 'Track test scores, identify weak topics, and get personalised recommendations to improve faster.',
      assetPath: 'assets/images/onboarding_3.png',
    ),
    OnboardingSlide(
      accentTag: 'PDF BUNDLES & MORE',
      title: 'All Study\nMaterial. One App.',
      subtitle: 'Offline-ready PDF bundle_listing',
      description: 'Download study notes and PDF bundle_listing. Read anytime, anywhere — even without internet.',
      assetPath: 'assets/images/onboarding_4.png',
    ),
  ];
}

// ─── Profile-building flow steps ──────────────────────────────────────────────
enum OnboardingStep {
  splash,         // 4 dark slides
  welcome,        // "Let's Build Your Success Journey"
  name,           // 1/4 What should we call you?
  verifyEmail,    // 2/4 Which email do you use most?
  dateOfBirth,    // 3/4 When's your happy birthday?
  educationGoal,  // 4/4 What are you preparing for?
  learningStyle,  // How do you learn best?
  currentJourney, // Where are you in your journey?
  planReady,      // Your Personalized Plan Is Ready
}

// ─── Exam goals ───────────────────────────────────────────────────────────────
class ExamGoal {
  final String id, label, emoji;
  const ExamGoal({required this.id, required this.label, required this.emoji});
}
abstract class ExamGoals {
  static const List<ExamGoal> all = [
    ExamGoal(id: 'ssc',       label: 'SSC',       emoji: '📝'),
    ExamGoal(id: 'railway',   label: 'Railway',   emoji: '🚂'),
    ExamGoal(id: 'banking',   label: 'Banking',   emoji: '🏦'),
    ExamGoal(id: 'upsc',      label: 'UPSC',      emoji: '🏛️'),
    ExamGoal(id: 'state_psc', label: 'State PSC', emoji: '🏢'),
    ExamGoal(id: 'teaching',  label: 'Teaching',  emoji: '👨‍🏫'),
    ExamGoal(id: 'jee',       label: 'JEE',       emoji: '⚙️'),
    ExamGoal(id: 'neet',      label: 'NEET',      emoji: '🩺'),
  ];
}

// ─── Learning styles ──────────────────────────────────────────────────────────
class LearningStyle { final String id, label, emoji; const LearningStyle({required this.id, required this.label, required this.emoji}); }
abstract class LearningStyles {
  static const List<LearningStyle> all = [
    LearningStyle(id: 'video',     label: 'Video Classes',  emoji: '🎬'),
    LearningStyle(id: 'mock',      label: 'Mock Tests',     emoji: '📊'),
    LearningStyle(id: 'daily_quiz',label: 'Daily Quiz',     emoji: '❓'),
    LearningStyle(id: 'pdf',       label: 'PDF Notes',      emoji: '📄'),
    LearningStyle(id: 'live',      label: 'Live Sessions',  emoji: '📡'),
  ];
}

// ─── Journey levels ───────────────────────────────────────────────────────────
class JourneyLevel { final String id, label; const JourneyLevel({required this.id, required this.label}); }
abstract class JourneyLevels {
  static const List<JourneyLevel> all = [
    JourneyLevel(id: 'class_10', label: 'Class 10'),
    JourneyLevel(id: 'class_12', label: 'Class 12'),
    JourneyLevel(id: 'graduate', label: 'Graduate'),
    JourneyLevel(id: 'post_graduate', label: 'Post Graduate'),
    JourneyLevel(id: 'working', label: 'Working Professional'),
  ];
}

// ─── Collected profile models ───────────────────────────────────────────────────
class OnboardingProfile {
  final String? firstName, lastName, email, examGoalId, learningStyleId, journeyLevelId;
  final DateTime? dateOfBirth;
  const OnboardingProfile({this.firstName, this.lastName, this.email,
    this.examGoalId, this.learningStyleId, this.journeyLevelId, this.dateOfBirth});
  OnboardingProfile copyWith({String? firstName, String? lastName, String? email,
    String? examGoalId, String? learningStyleId, String? journeyLevelId, DateTime? dateOfBirth}) =>
      OnboardingProfile(
        firstName: firstName ?? this.firstName, lastName: lastName ?? this.lastName,
        email: email ?? this.email, examGoalId: examGoalId ?? this.examGoalId,
        learningStyleId: learningStyleId ?? this.learningStyleId,
        journeyLevelId: journeyLevelId ?? this.journeyLevelId,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      );
  String get displayName => [firstName, lastName].where((s) => s != null && s.isNotEmpty).join(' ');
  Map<String, dynamic> toMap() => {
    'firstName': firstName ?? '', 'lastName': lastName ?? '',
    'email': email ?? '', 'examGoal': examGoalId,
    'learningStyle': learningStyleId, 'journeyLevel': journeyLevelId,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'onboardingCompleted': true, 'createdAt': DateTime.now().toIso8601String(),
  };
}

