import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Absolute imports to target clean folder locations
import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';
import 'package:alogyan_prep/features/onboarding/controllers/onboarding_controller.dart';
import 'package:alogyan_prep/features/onboarding/widgets/onboarding_action_button.dart';
import 'package:alogyan_prep/features/onboarding/widgets/onboarding_slide_card.dart';
import 'package:alogyan_prep/features/onboarding/widgets/page_dot_indicator.dart';
import 'package:alogyan_prep/features/onboarding/presentation/screens/login_screen.dart';

/// ALO-001 — Students Onboarding Screen (Riverpod + Firebase ready).
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  static const _slides = OnboardingContent.slides;

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas, // Fixed: Using your explicit bgCanvas token
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── PageView ─────────────────────────────────────────────────────
          PageView.builder(
            controller: notifier.pageController,
            onPageChanged: notifier.onPageChanged,
            physics: const BouncingScrollPhysics(),
            itemCount: _slides.length,
            itemBuilder: (_, index) => SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: OnboardingSlideCard(slide: _slides[index]),
            ),
          ),

          // ── Top bar: Logo + Skip ──────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL, // Fixed: Realigned to your spacing tokens
                vertical: AppTheme.spacingM,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppTheme.brandOrange,
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: const Icon(Icons.school_rounded,
                            color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Alogyan',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),

                  // Skip button
                  AnimatedOpacity(
                    opacity: state.isLastPage ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: IgnorePointer(
                      ignoring: state.isLastPage,
                      child: GestureDetector(
                        onTap: () {
                          notifier.skipToLast();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.bgSurface, // Fixed: Using your bgSurface token
                            borderRadius:
                            BorderRadius.circular(AppTheme.radiusCircle),
                            border: Border.all(
                              color: AppTheme.textMuted.withOpacity(0.2),
                            ),
                          ),
                          child: Text('Skip',
                              style: AppTheme.titleMedium
                                  .copyWith(color: AppTheme.textSecondary)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom bar: Dots + Button ─────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: AppTheme.spacingL, // Fixed: Realigned to your spacing tokens
                right: AppTheme.spacingL,
                bottom: MediaQuery.viewPaddingOf(context).bottom + AppTheme.spacingL,
                top: AppTheme.spacingM,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.bgCanvas.withOpacity(0.0), // Fixed: Using your bgCanvas token
                    AppTheme.bgCanvas.withOpacity(0.97),
                    AppTheme.bgCanvas,
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PageDotIndicator(
                    totalPages: state.totalPages,
                    currentIndex: state.currentIndex,
                  ),
                  OnboardingActionButton(
                    isLastPage: state.isLastPage,
                    onNext: notifier.nextPage,
                    onGetStarted: () => _navigateToLogin(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}