import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Absolute path reference targeting your static content models
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding page state
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingState {
  final int currentIndex;
  final int totalPages;

  const OnboardingState({
    required this.currentIndex,
    required this.totalPages,
  });

  bool get isLastPage => currentIndex == totalPages - 1;

  OnboardingState copyWith({int? currentIndex}) => OnboardingState(
    currentIndex: currentIndex ?? this.currentIndex,
    totalPages: totalPages,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingNotifier extends Notifier<OnboardingState> {
  late final PageController pageController;

  @override
  OnboardingState build() {
    pageController = PageController();
    ref.onDispose(pageController.dispose);

    return OnboardingState(
      currentIndex: 0,
      totalPages: OnboardingContent.slides.length,
    );
  }

  void onPageChanged(int index) {
    assert(index >= 0 && index < state.totalPages);
    state = state.copyWith(currentIndex: index);
  }

  void nextPage() {
    if (state.isLastPage) return;
    pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
  }

  void skipToLast() {
    pageController.animateToPage(
      state.totalPages - 1,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeInOutCubic,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final onboardingProvider =
NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);