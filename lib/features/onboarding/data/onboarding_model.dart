/// Model representing a single onboarding slide.
///
/// Each slide contains a title, subtitle, a description,
/// and the path to its illustration asset.
class OnboardingSlide {
  final String title;
  final String subtitle;
  final String description;
  final String assetPath; // Vector/Lottie asset placeholder path
  final String? accentTag; // Optional top badge text (e.g. "FREE FOREVER")

  const OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.assetPath,
    this.accentTag,
  });
}

/// Static repository of all onboarding slides.
/// Update [assetPath] values once real assets are added under assets/images/.
abstract class OnboardingData {
  static const List<OnboardingSlide> slides = [
    OnboardingSlide(
      accentTag: 'EXAM PREP · MADE SIMPLE',
      title: 'Master Every\nExam with Ease',
      subtitle: 'Your smart preparation hub',
      description:
      'Access thousands of curated questions, mock tests, and study notes — all in one place.',
      assetPath: 'assets/images/onboarding_1.png',
    ),
    OnboardingSlide(
      accentTag: 'DAILY CURRENT AFFAIRS',
      title: 'Stay Ahead,\nEvery Single Day',
      subtitle: 'News distilled for competitive exams',
      description:
      'Get daily GK updates filtered by Economy, Politics, Science and more — no noise, just what matters.',
      assetPath: 'assets/images/onboarding_2.png',
    ),
    OnboardingSlide(
      accentTag: 'PERFORMANCE ANALYTICS',
      title: 'Know Where\nYou Stand',
      subtitle: 'Detailed reports & insights',
      description:
      'Track test scores, identify weak topics, and get personalised recommendations to improve faster.',
      assetPath: 'assets/images/onboarding_3.png',
    ),
    OnboardingSlide(
      accentTag: 'PDF BUNDLES & MORE',
      title: 'All Study\nMaterial. One App.',
      subtitle: 'Offline-ready PDF bundles',
      description:
      'Download study notes and PDF bundles. Read anytime, anywhere — even without internet.',
      assetPath: 'assets/images/onboarding_4.png',
    ),
  ];
}
