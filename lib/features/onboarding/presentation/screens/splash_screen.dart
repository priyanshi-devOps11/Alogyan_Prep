import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../controllers/controllers.dart';
import '../../data/onboarding_model.dart';
import '../widgets/widgets.dart';

/// ALO-001 Phase 1 — 4 dark animated slides (Scapia-style).
/// After Get Started → transitions to Welcome screen.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(splashProvider);
    final notifier = ref.read(splashProvider.notifier);
    final flow     = ref.read(flowProvider.notifier);
    final slides   = OnboardingSlidesData.slides;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      extendBodyBehindAppBar: true,
      body: Stack(children: [
        // ── PageView ────────────────────────────────────────────────────────
        PageView.builder(
          controller: notifier.pageController,
          onPageChanged: notifier.onPageChanged,
          physics: const BouncingScrollPhysics(),
          itemCount: slides.length,
          itemBuilder: (_, i) => _SlidePage(slide: slides[i]),
        ),

        // ── Top: Brand + Skip ────────────────────────────────────────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.s24, vertical: AppTheme.s20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BrandRow(dark: true),
                AnimatedOpacity(
                  opacity: state.isLast ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: state.isLast,
                    child: GestureDetector(
                      onTap: notifier.skipToLast,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.bgDark3,
                          borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
                          border: Border.all(color: AppTheme.textMutedOnDark.withValues(alpha: 0.2)),
                        ),
                        child: Text('Skip',
                            style: AppTheme.titleOnDark.copyWith(
                                color: AppTheme.textSecondaryOnDark)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Bottom: Dots + Arrow/GetStarted ─────────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: EdgeInsets.only(
              left: AppTheme.s24, right: AppTheme.s24,
              bottom: MediaQuery.viewPaddingOf(context).bottom + AppTheme.s24,
              top: AppTheme.s20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [
                  AppTheme.bgDark.withValues(alpha: 0),
                  AppTheme.bgDark.withValues(alpha: 0.95),
                  AppTheme.bgDark,
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PageDotIndicator(total: state.total, current: state.index),
                _ActionButton(
                  isLast: state.isLast,
                  onNext: () => ref.read(splashProvider.notifier).nextPage(),
                  onGetStarted: () {
                    flow.goTo(OnboardingStep.welcome);
                  },
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Single slide layout ────────────────────────────────────────────────────────
class _SlidePage extends StatelessWidget {
  const _SlidePage({required this.slide});
  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Illustration area
      SizedBox(
        height: h * 0.46, width: double.infinity,
        child: Stack(fit: StackFit.expand, children: [
          // Gradient bg
          Container(decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [AppTheme.bgDark3, AppTheme.bgDark2, AppTheme.bgDark]),
          )),
          // Glow
          Positioned(top: -60, right: -40,
            child: Container(width: 220, height: 220, decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppTheme.brandRed.withValues(alpha: 0.18),
                AppTheme.brandRed.withValues(alpha: 0),
              ]),
            )),
          ),
          // Asset
          Image.asset(slide.assetPath, fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Center(child: Column(
              mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.image_outlined, size: 72,
                  color: AppTheme.textMutedOnDark.withValues(alpha: 0.3)),
              const SizedBox(height: 8),
              Text(slide.assetPath.split('/').last,
                  style: AppTheme.bodyOnDark.copyWith(
                      fontSize: 12, color: AppTheme.textMutedOnDark)),
            ],
            )),
          ),
          // Bottom fade
          Positioned(bottom: 0, left: 0, right: 0,
            child: Container(height: 80, decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppTheme.bgDark.withValues(alpha: 0.9)]),
            )),
          ),
        ]),
      ),
      // Text content
      Padding(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.s24, AppTheme.s24, AppTheme.s24, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Accent tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.brandRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
              border: Border.all(color: AppTheme.brandRed.withValues(alpha: 0.3)),
            ),
            child: Text(slide.accentTag, style: AppTheme.accentTagDark),
          ),
          const SizedBox(height: AppTheme.s12),
          Text(slide.title, style: AppTheme.displayDark),
          const SizedBox(height: AppTheme.s8),
          Text(slide.subtitle, style: AppTheme.titleOnDark),
          const SizedBox(height: AppTheme.s16),
          Text(slide.description, style: AppTheme.bodyOnDark),
        ]),
      ),
    ]);
  }
}

// ── Arrow / Get Started button ─────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.isLast, required this.onNext, required this.onGetStarted});
  final bool isLast;
  final VoidCallback onNext, onGetStarted;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 300),
    transitionBuilder: (child, anim) => ScaleTransition(scale: anim,
        child: FadeTransition(opacity: anim, child: child)),
    child: isLast
        ? _GetStarted(key: const ValueKey('gs'), onTap: onGetStarted)
        : _Arrow(key: const ValueKey('ar'), onTap: onNext),
  );
}

class _Arrow extends StatelessWidget {
  const _Arrow({super.key, required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(width: 60, height: 60,
      decoration: BoxDecoration(shape: BoxShape.circle,
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppTheme.brandRedLight, AppTheme.brandRedDark]),
        boxShadow: [BoxShadow(color: AppTheme.brandRed.withValues(alpha: 0.4),
            blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 26),
    ),
  );
}

class _GetStarted extends StatelessWidget {
  const _GetStarted({super.key, required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppTheme.brandRedLight, AppTheme.brandRedDark]),
        borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
        boxShadow: [BoxShadow(color: AppTheme.brandRed.withValues(alpha: 0.45),
            blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('Get Started', style: AppTheme.buttonLabel),
        const SizedBox(width: 10),
        const Icon(Icons.check_rounded, color: Colors.white, size: 20),
      ]),
    ),
  );
}