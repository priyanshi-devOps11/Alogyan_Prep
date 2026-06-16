// ════════════════════════════════════════════════════════════════════════════
// main.dart
// KEY FIX (Point 2): _AuthGate is a ConsumerWidget that watches authProvider.
// When status == authenticated:
//   • userModel.isOnboardingCompleted == true  → BundleListingScreen
//   • userModel.isOnboardingCompleted == false → force flowProvider to
//     the user's last pending step, render OnboardingScreen
//   • userModel == null (still loading from Firestore) → loading spinner
// This eliminates the gap where auth is set but flow step is undefined.
// ════════════════════════════════════════════════════════════════════════════

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/onboarding/controllers/controllers.dart';
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';
import 'package:alogyan_prep/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:alogyan_prep/features/bundle_listing/presentation/screens/bundle_listing_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('[Firebase] init error: $e');
  }

  runApp(const ProviderScope(child: AlogyanPrepApp()));
}

class AlogyanPrepApp extends ConsumerWidget {
  const AlogyanPrepApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Alogyan Prep',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _AuthGate(),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _AuthGate — smart reactive routing with Firestore-aware session restore
// ════════════════════════════════════════════════════════════════════════════
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    switch (authState.status) {
    // ── Unauthenticated / Error — always land on onboarding (splash) ──────
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
      case AuthStatus.initial:
        return const OnboardingScreen();

    // ── Loading / Email pending — show spinner ─────────────────────────────
      case AuthStatus.loading:
      case AuthStatus.emailPendingVerification:
      // verifyEmail step (set in register()) renders correctly
        return const OnboardingScreen();

    // ── Authenticated ──────────────────────────────────────────────────────
      case AuthStatus.authenticated:
        final userModel = authState.userModel;

        // UserModel is still being fetched from Firestore (hydrateUserModel
        // runs in microtask after build() returns). Show spinner briefly.
        if (userModel == null) {
          return const _LoadingScaffold();
        }

        // Onboarding complete — go straight to bundle listings
        if (userModel.isOnboardingCompleted) {
          return const BundleListingScreen();
        }

        // Onboarding NOT complete — resume from the user's last pending step.
        // We call this synchronously inside build using a post-frame callback
        // so we don't mutate provider state during a build cycle.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _resumeOnboardingStep(ref, userModel);
        });

        return const OnboardingScreen();
    }
  }

  /// Walk the user's Firestore record to find the furthest completed step,
  /// then set flowProvider to the NEXT step they haven't done yet.
  void _resumeOnboardingStep(WidgetRef ref, userModel) {
    final flow    = ref.read(flowProvider.notifier);
    final current = ref.read(flowProvider).step;

    // Only resume if we're still on splash/welcome — don't override if
    // the force-intercept in AuthNotifier already set a destination.
    if (current != OnboardingStep.splash &&
        current != OnboardingStep.welcome) return;

    // Walk completed fields to find resume point
    if (userModel.selectedJourneyLevelId != null) {
      flow.goTo(OnboardingStep.planReady);
    } else if (userModel.selectedLearningStyleId != null) {
      flow.goTo(OnboardingStep.currentJourney);
    } else if (userModel.selectedExamGoalId != null) {
      flow.goTo(OnboardingStep.learningStyle);
    } else if (userModel.dob != null) {
      flow.goTo(OnboardingStep.educationGoal);
    } else if (userModel.firstName.isNotEmpty) {
      // Name was collected but no DOB yet — go to DOB
      flow.goTo(OnboardingStep.dateOfBirth);
    } else {
      // Brand new user — start from name
      flow.goTo(OnboardingStep.name);
    }
  }
}

// Simple loading scaffold — shown only during Firestore hydration (~100ms)
class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();
  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppTheme.bgDark,
    body: Center(
      child: CircularProgressIndicator(
        color: AppTheme.brandRed,
        strokeWidth: 2.5,
      ),
    ),
  );
}