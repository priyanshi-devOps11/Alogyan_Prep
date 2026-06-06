import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/onboarding_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingFlowState {
  final OnboardingStep currentStep;
  final OnboardingProfile profile;
  final bool isLoading;

  // The ordered list of profile-building steps (excluding welcome & planReady)
  static const List<OnboardingStep> profileSteps = [
    OnboardingStep.name,
    OnboardingStep.verifyEmail,
    OnboardingStep.dateOfBirth,
    OnboardingStep.educationGoal,
    OnboardingStep.learningStyle,
    OnboardingStep.currentJourney,
  ];

  const OnboardingFlowState({
    this.currentStep = OnboardingStep.welcome,
    this.profile = const OnboardingProfile(),
    this.isLoading = false,
  });

  /// Returns 0-based index within profileSteps, or -1 if not a profile step.
  int get profileStepIndex => profileSteps.indexOf(currentStep);

  /// Total number of profile-building steps.
  int get totalProfileSteps => profileSteps.length;

  /// Progress fraction [0.0 – 1.0] for the progress bar inside profile steps.
  double get progressFraction {
    final idx = profileStepIndex;
    if (idx < 0) return 0.0;
    return (idx + 1) / totalProfileSteps;
  }

  /// Label like "2/4" shown in the top progress chip.
  /// Only 4 steps show the fraction: name, verifyEmail, dateOfBirth, educationGoal
  String? get stepFractionLabel {
    const shownSteps = [
      OnboardingStep.name,
      OnboardingStep.verifyEmail,
      OnboardingStep.dateOfBirth,
      OnboardingStep.educationGoal,
    ];
    final idx = shownSteps.indexOf(currentStep);
    if (idx < 0) return null;
    return '${idx + 1}/${shownSteps.length}';
  }

  bool get isWelcome => currentStep == OnboardingStep.welcome;
  bool get isPlanReady => currentStep == OnboardingStep.planReady;

  OnboardingFlowState copyWith({
    OnboardingStep? currentStep,
    OnboardingProfile? profile,
    bool? isLoading,
  }) =>
      OnboardingFlowState(
        currentStep: currentStep ?? this.currentStep,
        profile: profile ?? this.profile,
        isLoading: isLoading ?? this.isLoading,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingFlowNotifier extends Notifier<OnboardingFlowState> {
  @override
  OnboardingFlowState build() => const OnboardingFlowState();

  void setStep(OnboardingStep step) {
    state = state.copyWith(currentStep: step);
  }

  void goBack() {
    final current = state.currentStep;
    final steps = OnboardingFlowState.profileSteps;
    final idx = steps.indexOf(current);

    if (current == OnboardingStep.planReady) {
      state = state.copyWith(currentStep: steps.last);
      return;
    }
    if (idx > 0) {
      state = state.copyWith(currentStep: steps[idx - 1]);
    } else if (idx == 0) {
      // Back from first profile step goes to welcome
      state = state.copyWith(currentStep: OnboardingStep.welcome);
    }
    // welcome — no back
  }

  void advanceToNextStep() {
    final current = state.currentStep;
    final steps = OnboardingFlowState.profileSteps;
    final idx = steps.indexOf(current);

    if (current == OnboardingStep.welcome) {
      state = state.copyWith(currentStep: OnboardingStep.name);
      return;
    }
    if (idx >= 0 && idx < steps.length - 1) {
      state = state.copyWith(currentStep: steps[idx + 1]);
    } else if (idx == steps.length - 1) {
      state = state.copyWith(currentStep: OnboardingStep.planReady);
    }
  }

  void updateName({required String firstName, required String lastName}) {
    state = state.copyWith(
      profile: state.profile.copyWith(
        firstName: firstName,
        lastName: lastName,
      ),
    );
  }

  void updateEmail(String email) {
    state = state.copyWith(profile: state.profile.copyWith(email: email));
  }

  void updateDateOfBirth(DateTime dob) {
    state =
        state.copyWith(profile: state.profile.copyWith(dateOfBirth: dob));
  }

  void selectExamGoal(String goalId) {
    state = state.copyWith(
        profile: state.profile.copyWith(selectedExamGoalId: goalId));
  }

  void selectLearningStyle(String styleId) {
    state = state.copyWith(
        profile: state.profile.copyWith(selectedLearningStyleId: styleId));
  }

  void selectJourneyLevel(String levelId) {
    state = state.copyWith(
        profile: state.profile.copyWith(selectedJourneyLevelId: levelId));
  }

  void setLoading(bool v) => state = state.copyWith(isLoading: v);
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final onboardingFlowProvider =
NotifierProvider<OnboardingFlowNotifier, OnboardingFlowState>(
  OnboardingFlowNotifier.new,
);