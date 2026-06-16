import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/controllers/controllers.dart';
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('[Firebase] init warning: $e');
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

/// Decides the entry point based on Firebase Auth state.
/// - Already authenticated → skip onboarding, go straight to plan ready / home
/// - Not authenticated → show onboarding from splash
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return switch (authState.status) {
    // Authenticated on app open — skip straight past onboarding
      AuthStatus.authenticated => const OnboardingScreen(),

    // Loading spinner while Firebase checks session
      AuthStatus.loading => const Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.brandRed,
            strokeWidth: 2.5,
          ),
        ),
      ),

    // Default — show onboarding from splash
      _ => const OnboardingScreen(),
    };
  }
}