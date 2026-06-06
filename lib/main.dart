import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

// Absolute path configurations mapping your project domains directly
import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';
import 'package:alogyan_prep/features/onboarding/controllers/auth_controller.dart';


// Safe conditional import wrapper to keep IDE happy if file generation is pending
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase infrastructure layout
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  runApp(
    const ProviderScope(
      child: AlogyanPrepApp(),
    ),
  );
}

class AlogyanPrepApp extends ConsumerWidget {
  const AlogyanPrepApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Alogyan Prep',
      debugShowCheckedModeBanner: false,

      // Fallback fallback configuration to keep compilation live if static theme getter names mismatch
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: AppTheme.fontFamily,
        scaffoldBackgroundColor: const Color(0xFF0A0A14),
        colorScheme: const ColorScheme.dark(
          primary: AppTheme.brandRed,
        ),
      ),
      home: const _AuthGate(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reactive Authentication Router (Auth Gate Engine)
// ─────────────────────────────────────────────────────────────────────────────

class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return switch (authState.status) {
      AuthStatus.authenticated => const HomeStubScreen(),
      AuthStatus.initial => const OnboardingScreen(),
      AuthStatus.unauthenticated => const OnboardingScreen(),
      AuthStatus.loading => const Scaffold(
        backgroundColor: Color(0xFF0A0A14),
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.brandOrange,
          ),
        ),
      ),
      _ => const OnboardingScreen(),
    };
  }
}