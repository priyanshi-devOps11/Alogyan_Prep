import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/onboarding/controllers/controllers.dart';
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';
import 'package:alogyan_prep/features/onboarding/presentation/widgets/widgets.dart';

// ══════════════════════════════════════════════════════════════════════
// WELCOME SCREEN
// ══════════════════════════════════════════════════════════════════════
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final flow = ref.read(flowProvider.notifier);
    final aN   = ref.read(authProvider.notifier);

    ref.listen(authProvider, (_, next) {
      if (next.isAuthenticated) flow.goTo(OnboardingStep.name);
      if (next.hasError && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppTheme.error));
        aN.clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.bgWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: AppTheme.s24),
            const BrandRow(),
            Expanded(child: Center(child: IllustrationImage(
              asset: 'assets/images/welcome_illustration.png',
              height: MediaQuery.sizeOf(context).height * 0.28,
            ))),
            Text("Let's Build Your\nSuccess Journey", style: AppTheme.displayLight),
            const SizedBox(height: AppTheme.s12),
            Text('Personalised exam preparation. Adapt to your pace and focus on your growth.',
                style: AppTheme.bodyLight),
            const SizedBox(height: AppTheme.s32),
            GoogleButton(isLoading: auth.isLoading, onPressed: aN.googleSignIn),
            const SizedBox(height: AppTheme.s12),
            PrimaryButton(
              label: 'Get Started',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => flow.next(),
            ),
            const SizedBox(height: AppTheme.s16),
            Center(child: Text.rich(TextSpan(style: AppTheme.bodySmall, children: [
              const TextSpan(text: 'By continuing you agree to our '),
              TextSpan(text: 'Terms & Privacy Policy',
                  style: AppTheme.linkText.copyWith(fontSize: 12)),
            ]), textAlign: TextAlign.center)),
            const SizedBox(height: AppTheme.s24),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// STEP 1/4 — NAME  (FIX: SingleChildScrollView removes yellow overflow)
// ══════════════════════════════════════════════════════════════════════
class NameStepScreen extends ConsumerStatefulWidget {
  const NameStepScreen({super.key});
  @override ConsumerState<NameStepScreen> createState() => _NameState();
}
class _NameState extends ConsumerState<NameStepScreen> {
  final _fKey  = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last  = TextEditingController();
  final _firstFocus = FocusNode();
  final _lastFocus  = FocusNode();

  @override
  void dispose() {
    _first.dispose(); _last.dispose();
    _firstFocus.dispose(); _lastFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(flowProvider);
    final fn   = ref.read(flowProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      // KEY FIX: resizeToAvoidBottomInset keeps layout stable when keyboard opens
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: AppTheme.s24, right: AppTheme.s24,
            top: AppTheme.s20,
            bottom: MediaQuery.viewInsetsOf(context).bottom + AppTheme.s24,
          ),
          child: Form(
            key: _fKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              StepHeader(
                fraction: flow.fraction,
                progress: flow.progress,
                onBack: fn.back,
              ),
              const SizedBox(height: AppTheme.s24),
              IllustrationImage(
                asset: 'assets/images/onboarding_name.png',
                height: 160,
              ),
              const SizedBox(height: AppTheme.s20),
              Text('What should we\ncall you?', style: AppTheme.displayLight),
              const SizedBox(height: AppTheme.s8),
              Text("Let's personalise your learning experience.", style: AppTheme.bodyLight),
              const SizedBox(height: AppTheme.s24),
              AlogyanField(
                controller: _first,
                hint: 'First Name',
                prefix: Icons.person_outline_rounded,
                focusNode: _firstFocus,
                textInputAction: TextInputAction.next,
                onSubmit: (_) => FocusScope.of(context).requestFocus(_lastFocus),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your first name' : null,
              ),
              const SizedBox(height: AppTheme.s12),
              AlogyanField(
                controller: _last,
                hint: 'Last Name',
                prefix: Icons.person_outline_rounded,
                focusNode: _lastFocus,
                action: TextInputAction.done,
                onSubmit: (_) => _submit(fn),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your last name' : null,
              ),
              const SizedBox(height: AppTheme.s32),
              PrimaryButton(
                label: 'Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => _submit(fn),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _submit(FlowNotifier fn) {
    if (_fKey.currentState?.validate() ?? false) {
      fn.setName(_first.text.trim(), _last.text.trim());
      fn.next();
    }
  }
}

// ══════════════════════════════════════════════════════════════════════
// STEP 2/4 — EMAIL / AUTH
// ══════════════════════════════════════════════════════════════════════
class EmailStepScreen extends ConsumerStatefulWidget {
  const EmailStepScreen({super.key});
  @override ConsumerState<EmailStepScreen> createState() => _EmailState();
}
class _EmailState extends ConsumerState<EmailStepScreen> {
  final _fKey  = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _createPass = false;

  @override
  void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!(_fKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final fn = ref.read(flowProvider.notifier);
    final aN = ref.read(authProvider.notifier);
    fn.setLoading(true);
    fn.setEmail(_email.text.trim());
    bool ok;
    if (_createPass) {
      ok = await aN.register(email: _email.text.trim(), password: _pass.text);
    } else {
      ok = true;
    }
    fn.setLoading(false);
    if (ok && mounted) fn.next();
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(flowProvider);
    final auth = ref.watch(authProvider);
    final fn   = ref.read(flowProvider.notifier);
    final aN   = ref.read(authProvider.notifier);

    ref.listen(authProvider, (_, next) {
      if (next.isAuthenticated && _createPass) { fn.setLoading(false); fn.next(); }
      if (next.hasError && next.errorMessage != null) {
        fn.setLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(next.errorMessage!), backgroundColor: AppTheme.error));
        aN.clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: AppTheme.s24, right: AppTheme.s24,
            top: AppTheme.s20,
            bottom: MediaQuery.viewInsetsOf(context).bottom + AppTheme.s24,
          ),
          child: Form(
            key: _fKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              StepHeader(fraction: flow.fraction, progress: flow.progress, onBack: fn.back),
              const SizedBox(height: AppTheme.s20),
              IllustrationImage(asset: 'assets/images/onboarding_email.png', height: 140),
              const SizedBox(height: AppTheme.s20),
              Text('Which email do\nyou use most?', style: AppTheme.displayLight),
              const SizedBox(height: AppTheme.s8),
              Text("We'll send important updates and study reminders.", style: AppTheme.bodyLight),
              const SizedBox(height: AppTheme.s20),
              if (flow.profile.displayName.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: AppTheme.s16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: AppTheme.bgCardAlt,
                      borderRadius: BorderRadius.circular(AppTheme.radiusM)),
                  child: Row(children: [
                    const Text('👋', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text('Hi, ${flow.profile.displayName}!', style: AppTheme.labelMedium),
                  ]),
                ),
              AlogyanField(
                controller: _email,
                hint: 'name@example.com',
                keyboardType: TextInputType.emailAddress,
                prefix: Icons.mail_outline_rounded,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter your email';
                  if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$').hasMatch(v.trim())) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.s12),
              GestureDetector(
                onTap: () => setState(() => _createPass = !_createPass),
                child: Row(children: [
                  Icon(_createPass ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      size: 20, color: AppTheme.brandRed),
                  const SizedBox(width: 8),
                  Text('Create password for my account',
                      style: AppTheme.labelMedium.copyWith(fontSize: 13)),
                ]),
              ),
              if (_createPass) ...[
                const SizedBox(height: AppTheme.s12),
                AlogyanField(
                  controller: _pass,
                  hint: 'Password (min. 6 chars)',
                  isPassword: true,
                  prefix: Icons.lock_outline_rounded,
                  action: TextInputAction.done,
                  onSubmit: (_) => _submit(),
                  validator: _createPass ? (v) {
                    if (v == null || v.isEmpty) return 'Enter password';
                    if (v.length < 6) return 'Min 6 characters';
                    return null;
                  } : null,
                ),
              ],
              const SizedBox(height: AppTheme.s16),
              GoogleButton(isLoading: auth.isLoading, onPressed: () async {
                fn.setLoading(true);
                await aN.googleSignIn();
              }),
              const SizedBox(height: AppTheme.s16),
              PrimaryButton(
                label: 'Verify Email',
                icon: Icons.arrow_forward_rounded,
                isLoading: flow.isLoading || auth.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppTheme.s12),
              Center(child: Text("You'll receive a verification email after sign up.",
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted, fontSize: 12),
                  textAlign: TextAlign.center)),
            ]),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// STEP 3/4 — DATE OF BIRTH
// ══════════════════════════════════════════════════════════════════════
class DobStepScreen extends ConsumerStatefulWidget {
  const DobStepScreen({super.key});
  @override ConsumerState<DobStepScreen> createState() => _DobState();
}
class _DobState extends ConsumerState<DobStepScreen> {
  final _ctrl = TextEditingController();
  DateTime? _selected;

  Future<void> _pick() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 5),
      builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(
              primary: AppTheme.brandRed, onPrimary: Colors.white,
              surface: AppTheme.bgWhite, onSurface: AppTheme.textPrimary)),
          child: child!),
    );
    if (picked != null) {
      setState(() {
        _selected = picked;
        _ctrl.text =
        '${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}';
      });
    }
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(flowProvider);
    final fn   = ref.read(flowProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: AppTheme.s20),
            StepHeader(
                fraction: flow.fraction, progress: flow.progress,
                onBack: fn.back, onSkip: fn.next),
            const SizedBox(height: AppTheme.s24),
            IllustrationImage(asset: 'assets/images/onboarding_dob.png', height: 160),
            const SizedBox(height: AppTheme.s20),
            Text("When's your\nhappy birthday? 🎂", style: AppTheme.displayLight),
            const SizedBox(height: AppTheme.s8),
            Text("We'll personalise recommendations based on your age and education stage.",
                style: AppTheme.bodyLight),
            const SizedBox(height: AppTheme.s20),
            GestureDetector(
              onTap: _pick,
              child: AbsorbPointer(child: TextFormField(
                controller: _ctrl,
                style: AppTheme.bodyLight.copyWith(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'DD / MM / YYYY',
                  hintStyle: AppTheme.bodyLight.copyWith(color: AppTheme.textMuted),
                  prefixIcon: const Icon(Icons.cake_outlined, color: AppTheme.textMuted, size: 18),
                  suffixIcon: const Icon(Icons.calendar_today_outlined,
                      color: AppTheme.brandRed, size: 18),
                  filled: true, fillColor: AppTheme.bgWhite,
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      borderSide: const BorderSide(color: AppTheme.borderLight)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      borderSide: const BorderSide(color: AppTheme.brandRed, width: 1.5)),
                ),
              )),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Continue',
              icon: Icons.arrow_forward_rounded,
              onPressed: () { if (_selected != null) fn.setDob(_selected!); fn.next(); },
            ),
            const SizedBox(height: AppTheme.s24),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// STEP 4/4 — EXAM GOAL
// ══════════════════════════════════════════════════════════════════════
class ExamGoalScreen extends ConsumerWidget {
  const ExamGoalScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(flowProvider);
    final fn   = ref.read(flowProvider.notifier);
    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: AppTheme.s20),
            StepHeader(fraction: flow.fraction, progress: flow.progress, onBack: fn.back),
            const SizedBox(height: AppTheme.s16),
            Text('What are you\npreparing for?', style: AppTheme.displayLight),
            const SizedBox(height: AppTheme.s8),
            Text('Select your target exam for a personalised study plan.', style: AppTheme.bodyLight),
            const SizedBox(height: AppTheme.s16),
            Expanded(child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: AppTheme.s12,
                  crossAxisSpacing: AppTheme.s12, childAspectRatio: 2.6),
              itemCount: ExamGoals.all.length,
              itemBuilder: (_, i) {
                final g = ExamGoals.all[i];
                return OptionCard(
                    label: g.label, emoji: g.emoji,
                    isSelected: flow.profile.examGoalId == g.id,
                    onTap: () => fn.setGoal(g.id));
              },
            )),
            const SizedBox(height: AppTheme.s16),
            PrimaryButton(
              label: 'Create My Learning Plan',
              icon: Icons.auto_awesome_rounded,
              onPressed: flow.profile.examGoalId != null ? fn.next : null,
            ),
            const SizedBox(height: AppTheme.s24),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// LEARNING STYLE
// ══════════════════════════════════════════════════════════════════════
class LearningStyleScreen extends ConsumerWidget {
  const LearningStyleScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(flowProvider);
    final fn   = ref.read(flowProvider.notifier);
    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: AppTheme.s20),
            StepHeader(progress: flow.progress, onBack: fn.back),
            const SizedBox(height: AppTheme.s16),
            IllustrationImage(asset: 'assets/images/onboarding_learning.png', height: 150),
            const SizedBox(height: AppTheme.s16),
            Text('How do you\nlearn best?', style: AppTheme.displayLight),
            const SizedBox(height: AppTheme.s8),
            Text("We'll prioritise content in your preferred format.", style: AppTheme.bodyLight),
            const SizedBox(height: AppTheme.s16),
            Expanded(child: ListView.separated(
              itemCount: LearningStyles.all.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppTheme.s8),
              itemBuilder: (_, i) {
                final s = LearningStyles.all[i];
                return OptionCard(label: s.label, emoji: s.emoji,
                    isSelected: flow.profile.learningStyleId == s.id,
                    onTap: () => fn.setLearning(s.id));
              },
            )),
            const SizedBox(height: AppTheme.s16),
            PrimaryButton(label: 'Continue', icon: Icons.arrow_forward_rounded,
                onPressed: flow.profile.learningStyleId != null ? fn.next : null),
            const SizedBox(height: AppTheme.s24),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// CURRENT JOURNEY
// ══════════════════════════════════════════════════════════════════════
class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(flowProvider);
    final fn   = ref.read(flowProvider.notifier);
    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: AppTheme.s20),
            StepHeader(progress: flow.progress, onBack: fn.back),
            const SizedBox(height: AppTheme.s16),
            IllustrationImage(asset: 'assets/images/onboarding_journey.png', height: 150),
            const SizedBox(height: AppTheme.s16),
            Text('Where are you\nin your journey?', style: AppTheme.displayLight),
            const SizedBox(height: AppTheme.s8),
            Text("We'll adapt to your pace and focus on your growth.", style: AppTheme.bodyLight),
            const SizedBox(height: AppTheme.s16),
            Expanded(child: ListView.separated(
              itemCount: JourneyLevels.all.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppTheme.s8),
              itemBuilder: (_, i) {
                final l = JourneyLevels.all[i];
                return OptionCard(label: l.label, emoji: '📚',
                    isSelected: flow.profile.journeyLevelId == l.id,
                    onTap: () => fn.setJourney(l.id));
              },
            )),
            const SizedBox(height: AppTheme.s16),
            PrimaryButton(label: 'Continue', icon: Icons.arrow_forward_rounded,
                onPressed: flow.profile.journeyLevelId != null ? fn.next : null),
            const SizedBox(height: AppTheme.s24),
          ]),
        ),
      ),
    );
  }
}