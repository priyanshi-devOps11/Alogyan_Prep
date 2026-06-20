# Alogyan Prep — Flutter App

> Competitive exam preparation app built with Flutter + Firebase + Riverpod 2.x

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter (Dart) |
| State Management | Riverpod 2.x (`NotifierProvider`) |
| Auth | Firebase Auth (Email/Password · Google Sign-In · Phone OTP) |
| Database | Cloud Firestore (`students` collection) |
| Theme | Custom Stitch-inspired light theme + dark splash state |
| Font | Poppins (Regular · Medium · SemiBold · Bold) |

---

## File Structure

```
lib/
├── main.dart                          ← App entry + _AuthGate (smart router)
├── firebase_options.dart              ← Auto-generated Firebase config
├── home_screen.dart                   ← Home dashboard with quick actions
│
├── core/
│   └── theme/
│       └── app_theme.dart             ← All colours, typography, spacing tokens
│
└── features/
    ├── bundle_listing/                ← ALO-002: Course bundles feature
    │   ├── controllers/
    │   │   └── bundle_controller.dart
    │   ├── models/
    │   │   └── bundle_model.dart
    │   ├── presentation/
    │   │   └── screens/
    │   │       └── bundle_listing_screen.dart
    │   ├── repository/
    │   │   └── bundle_repository.dart
    │   ├── services/
    │   │   └── bundle_api_service.dart
    │   └── widgets/
    │       └── bundle_widgets.dart
    │
    └── onboarding/                    ← ALO-001: Full auth + onboarding flow
        ├── controllers/
        │   └── controllers.dart       ← All Riverpod providers
        │                                 (authProvider, flowProvider, splashProvider)
        ├── data/
        │   ├── auth_repository.dart   ← Firebase Auth implementation
        │   ├── onboarding_model.dart  ← OnboardingStep enum + slide data
        │   └── user_model.dart        ← Firestore UserModel
        └── presentation/
            ├── screens/
            │   ├── email_step_screen.dart    ← Step 2/4 (standalone file)
            │   ├── email_verify_screen.dart  ← Email verification wait + polling
            │   ├── login_screen.dart         ← Sign in (email + Google)
            │   ├── onboarding_screen.dart    ← AnimatedSwitcher router
            │   ├── phone_login_screen.dart   ← Phone OTP auth
            │   ├── plan_ready_screen.dart    ← Final onboarding step
            │   ├── splash_screen.dart        ← 4 dark intro slides (PageView)
            │   └── step_screens.dart         ← Name · DOB · Goal · Learning · Journey
            └── widgets/
                └── widgets.dart              ← Shared UI components
```

---

## Onboarding Flow

```
App open → _AuthGate
│
├─ Not authenticated
│   └─ SplashScreen (4 dark slides)
│       └─ WelcomeScreen
│           ├─ [Continue with Google] → DOB step (skips email verification)
│           ├─ [Sign In] → LoginScreen
│           └─ [Get Started] → NameStepScreen (1/4)
│               └─ EmailStepScreen (2/4)
│                   ├─ Create Account → EmailVerifyWaitScreen → DOB
│                   ├─ Continue with Google → DOB step
│                   └─ Login with Phone → PhoneLoginScreen → DOB step
│                       └─ DobStepScreen (3/4)
│                           └─ ExamGoalScreen (4/4)
│                               └─ LearningStyleScreen
│                                   └─ JourneyScreen
│                                       └─ PlanReadyScreen
│                                           └─ [Start Learning] → BundleListingScreen
│
└─ Authenticated
    ├─ isOnboardingCompleted == true  → BundleListingScreen
    └─ isOnboardingCompleted == false → Resume at last pending step
```

---

## Firebase Setup

### Authentication Providers (enable all three)
Firebase Console → Authentication → Sign-in method:
- ✅ Email/Password
- ✅ Google
- ✅ Phone

### Phone Test Numbers (required — avoids SMS billing)
Firebase Console → Authentication → Sign-in method → Phone → **Phone numbers for testing**:
```
+91xxxxxxxxxx  →  OTP: 123456
```

### SHA-1 Fingerprint (required for Google Sign-In on Android)
```bash
cd android
gradlew.bat signingReport
```
Copy the `SHA1` under **Variant: debug** → Firebase Console → Project Settings → Your Android App → **Add fingerprint** → Save → re-download `google-services.json`.

### Firestore Collection
Collection name: `students`

Document structure per user:
```
uid                     String
email                   String
firstName               String
lastName                String
phoneNumber             String?
dob                     String?   (ISO8601)
selectedExamGoalId      String?
selectedLearningStyleId String?
selectedJourneyLevelId  String?
isOnboardingCompleted   Boolean
authProvider            String    ('email' | 'google' | 'phone')
createdAt               Timestamp
lastUpdated             Timestamp
```

---

## Dependencies

```yaml
# pubspec.yaml (key packages)
flutter_riverpod: ^2.5.1
riverpod_annotation: ^2.3.5
firebase_core: ^3.3.0
firebase_auth: ^5.1.4
cloud_firestore: ^5.2.1
google_sign_in: ^6.2.1
```

---

## Setup Steps

### 1. Add Poppins font files → `assets/fonts/`
Download from https://fonts.google.com/specimen/Poppins  
Required files: `Poppins-Regular.ttf` · `Poppins-Medium.ttf` · `Poppins-SemiBold.ttf` · `Poppins-Bold.ttf`

### 2. Add image assets → `assets/images/`
```
onboarding_1.png    onboarding_2.png    onboarding_3.png    onboarding_4.png
onboarding_email.png    onboarding_name.png
onboarding_dob.png      onboarding_learning.png    onboarding_journey.png
plan_ready_illustration.png    welcome_illustration.png
```
> All screens have graceful fallback containers — safe to run without assets.

### 3. Add Google logo → `assets/icons/`
```
google_logo.png
```
> Button falls back to a Material icon if file is missing.

### 4. Install dependencies
```bash
flutter pub get
```

### 5. Run
```bash
flutter run
```

---

## Key Features

### ALO-001 — Students Onboarding
- ✅ 4-slide dark animated splash (`PageView.builder`, dot indicator 8px→28px)
- ✅ Welcome screen with Google Sign-In, Sign In, and Get Started
- ✅ Name step (1/4) with first + last name validation
- ✅ Email step (2/4) — mandatory strong password (regex: 1 uppercase + 1 lowercase + 1 digit + 1 special char + min 6 chars), real-time strength bar
- ✅ Phone OTP login (Firebase test number bypass for local dev)
- ✅ Email verification wait screen with `WidgetsBindingObserver` — auto-detects verification when user returns from email app
- ✅ DOB picker (3/4), Exam Goal grid (4/4), Learning Style, Journey Level
- ✅ Plan Ready screen → saves `isOnboardingCompleted: true` → routes to bundles
- ✅ Persistent session — app remembers authenticated state across restarts
- ✅ Resume onboarding — if user closes app mid-flow, resumes from last completed step
- ✅ Incremental Firestore saves after every step (`SetOptions(merge: true)`)
- ✅ Full sign-out with flow state reset

### ALO-002 — Bundle Listing
- ✅ Search bar with real-time filtering
- ✅ Filter tabs: All · Free · Paid · Purchased
- ✅ Bundle cards with discount badge, rating, course count, purchased badge
- ✅ Bottom sheet detail view with "Buy Now" / "Get Free" CTA
- ✅ Sign out button in app bar

---

## State Management

All providers live in `controllers/controllers.dart`:

| Provider | Type | Purpose |
|---|---|---|
| `authRepositoryProvider` | `Provider` | Firebase repo singleton |
| `authProvider` | `NotifierProvider<AuthNotifier, AuthState>` | Auth status + UserModel |
| `flowProvider` | `NotifierProvider<FlowNotifier, FlowState>` | Onboarding step machine |
| `splashProvider` | `NotifierProvider<SplashNotifier, SplashState>` | Splash PageView control |

### `AuthStatus` enum
`initial` · `loading` · `authenticated` · `unauthenticated` · `error` · `emailPendingVerification`

### `OnboardingStep` enum
`splash` · `welcome` · `name` · `verifyEmail` · `emailVerifyWait` · `dateOfBirth` · `educationGoal` · `learningStyle` · `currentJourney` · `planReady`

> ⚠️ `OnboardingStep` is defined **only** in `data/onboarding_model.dart`. Never redeclare it elsewhere to avoid "defined in two libraries" compile errors.

---
