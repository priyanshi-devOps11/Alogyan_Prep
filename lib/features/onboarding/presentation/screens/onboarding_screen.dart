import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Pure package paths (Absolute imports)
import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/onboarding/controllers/onboarding_controller.dart';
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';
import 'package:alogyan_prep/features/onboarding/widgets/onboarding_action_button.dart';
import 'package:alogyan_prep/features/onboarding/widgets/onboarding_slide_card.dart';
import 'package:alogyan_prep/features/onboarding/widgets/page_dot_indicator.dart';

/// The Students Onboarding screen — ALO-001.
///
/// Entry point: push this route when the app is opened for the first time.
/// Once completed or skipped, call [onCompleted] to navigate to the home/auth
/// screen. This screen manages its own [OnboardingController] lifecycle.
///
/// Usage:
/// ```dart
/// Navigator.of(context).pushReplacement(
///   MaterialPageRoute(
///     builder: (_) => OnboardingScreen(
///       onCompleted: () { /* navigate to login */ },
///     ),
///   ),
/// );
/// ```
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onCompleted,
  });

  /// Called when the user either taps "Get Started" on the last slide
  /// or uses the Skip action. Navigate away from onboarding in this callback.
  final VoidCallback onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingController _controller;
  static const _slides = OnboardingData.slides;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingController(totalPages: _slides.length);
    _controller.addListener(_rebuild);

    // Make the status bar transparent so the illustration bleeds to top.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _controller.dispose();
    super.dispose();
  }

  // ── Navigation helpers ─────────────────────────────────────────────────────

  void _handleNext() {
    if (_controller.isLastPage) {
      widget.onCompleted();
    } else {
      _controller.nextPage();
    }
  }

  void _handleSkip() {
    // On skip, jump to last slide first — mirrors Scapia UX.
    if (!_controller.isLastPage) {
      _controller.skipToLast();
    } else {
      widget.onCompleted();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Main PageView ─────────────────────────────────────────────────
          PageView.builder(
            controller: _controller.pageController,
            onPageChanged: _controller.onPageChanged,
            physics: const BouncingScrollPhysics(),
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: OnboardingSlideCard(slide: _slides[index]),
              );
            },
          ),

          // ── Top overlay: Logo + Skip ──────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingL,
                vertical: AppTheme.paddingM,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand wordmark
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.brandOrange,
                          borderRadius:
                          BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
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

                  // Skip button — hidden on last page
                  AnimatedOpacity(
                    opacity: _controller.isLastPage ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: IgnorePointer(
                      ignoring: _controller.isLastPage,
                      child: GestureDetector(
                        onTap: _handleSkip,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(
                                AppTheme.radiusCircle),
                            border: Border.all(
                              color: AppTheme.textMuted.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            'Skip',
                            style: AppTheme.titleMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom bar: Dots + Action button ─────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: AppTheme.paddingL,
                right: AppTheme.paddingL,
                bottom:
                MediaQuery.viewPaddingOf(context).bottom + AppTheme.paddingL,
                top: AppTheme.paddingM,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.backgroundDark.withOpacity(0.0),
                    AppTheme.backgroundDark.withOpacity(0.97),
                    AppTheme.backgroundDark,
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PageDotIndicator(
                    totalPages: _slides.length,
                    currentIndex: _controller.currentIndex,
                  ),
                  OnboardingActionButton(
                    isLastPage: _controller.isLastPage,
                    onNext: _handleNext,
                    onGetStarted: widget.onCompleted,
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
