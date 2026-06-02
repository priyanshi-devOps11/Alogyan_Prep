import 'package:flutter/material.dart';

/// Controller for the onboarding flow.
///
/// Encapsulates all page-state logic so the [OnboardingScreen]
/// widget tree stays purely presentational.
class OnboardingController extends ChangeNotifier {
  OnboardingController({required int totalPages})
      : assert(totalPages > 0, 'totalPages must be greater than 0'),
        _totalPages = totalPages;

  final int _totalPages;
  final PageController pageController = PageController();

  int _currentIndex = 0;

  /// Zero-based index of the currently visible slide.
  int get currentIndex => _currentIndex;

  /// Whether the user is on the very last slide.
  bool get isLastPage => _currentIndex == _totalPages - 1;

  /// Total number of onboarding slides.
  int get totalPages => _totalPages;

  /// Called by [PageView.onPageChanged] to sync the dot indicator.
  void onPageChanged(int index) {
    assert(index >= 0 && index < _totalPages, 'Page index out of range');
    _currentIndex = index;
    notifyListeners();
  }

  /// Advances to the next page with a smooth animation.
  void nextPage() {
    if (isLastPage) return;
    pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
  }

  /// Jumps directly to the last page (used by the Skip button).
  void skipToLast() {
    pageController.animateToPage(
      _totalPages - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
