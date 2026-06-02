# Alogyan Prep — Flutter App

## ALO-001: Students Onboarding Screen

### File Structure
```
lib/
├── main.dart
├── core/
│   └── theme/
│       └── app_theme.dart          ← All colours, typography, spacing tokens
└── features/
    └── onboarding/
        ├── onboarding.dart          ← Barrel export (import only this)
        ├── data/
        │   └── onboarding_model.dart    ← OnboardingSlide model + static data
        ├── controllers/
        │   └── onboarding_controller.dart  ← Page state logic (ChangeNotifier)
        ├── presentation/
        │   └── screens/
        │       └── onboarding_screen.dart  ← Main screen (ALO-001 deliverable)
        └── widgets/
            ├── onboarding_slide_card.dart   ← Single slide layout
            ├── page_dot_indicator.dart      ← Animated dot row
            └── onboarding_action_button.dart ← Arrow / Get Started button
```

### Setup Steps

1. **Add Poppins font files** into `assets/fonts/`:
    - Download from https://fonts.google.com/specimen/Poppins
    - Add: `Poppins-Regular.ttf`, `Poppins-Medium.ttf`, `Poppins-SemiBold.ttf`, `Poppins-Bold.ttf`

2. **Add illustration assets** into `assets/images/`:
    - `onboarding_1.png` through `onboarding_4.png`
    - (Placeholder gradient shows until real assets are added — safe to run without them)

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

### Key Features Implemented
- ✅ 4-slide dynamic `PageView.builder`
- ✅ Animated dot indicator (active dot stretches 8px → 28px)
- ✅ Skip button (fades out on last page)
- ✅ Arrow → "Get Started" button morph with `AnimatedSwitcher`
- ✅ Graceful asset fallback (no crash if images missing)
- ✅ Feature-first modular architecture
- ✅ All values in `AppTheme` tokens (zero hardcoding in widgets)
- ✅ Null-safe, fully documented Dart code

### Navigation
Wire the `onCompleted` callback in `main.dart` to navigate to your Login/Home screen once onboarding is done.
