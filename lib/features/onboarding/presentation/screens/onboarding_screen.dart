import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Clean logic and models imports
import 'package:alogyan_prep/features/onboarding/controllers/controllers.dart';
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';

// Absolute clean paths pointing to your files
import 'package:alogyan_prep/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:alogyan_prep/features/onboarding/presentation/screens/step_screens.dart';
import 'package:alogyan_prep/features/onboarding/presentation/screens/plan_ready_screen.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(flowProvider.select((s) => s.step));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      child: _screen(step),
    );
  }

  /// Exhaustive mapping of every [OnboardingStep] to its screen widget.
  Widget _screen(OnboardingStep step) => switch (step) {
    OnboardingStep.splash =>
    const SplashScreen(key: ValueKey('splash')),
    OnboardingStep.welcome =>
    const WelcomeScreen(key: ValueKey('welcome')),
    OnboardingStep.name =>
    const NameStepScreen(key: ValueKey('name')),
    OnboardingStep.verifyEmail =>
    const EmailStepScreen(key: ValueKey('email')),
    OnboardingStep.emailVerifyWait => const EmailVerifyWaitScreen(key: ValueKey('verify_wait')),
    OnboardingStep.dateOfBirth =>
    const DobStepScreen(key: ValueKey('dob')),
    OnboardingStep.educationGoal =>
    const ExamGoalScreen(key: ValueKey('goal')),
    OnboardingStep.learningStyle =>
    const LearningStyleScreen(key: ValueKey('learning')),
    OnboardingStep.currentJourney =>
    const JourneyScreen(key: ValueKey('journey')),
    OnboardingStep.planReady =>
    const PlanReadyScreen(key: ValueKey('plan')),
  };
}