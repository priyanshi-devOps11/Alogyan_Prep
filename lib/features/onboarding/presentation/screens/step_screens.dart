import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../controllers/controllers.dart';
import '../../data/onboarding_model.dart';
import '../widgets/widgets.dart';

// ══════════════════════════════════════════════════════════════════════════════
// WELCOME — "Let's Build Your Success Journey"
// ══════════════════════════════════════════════════════════════════════════════
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth  = ref.watch(authProvider);
    final flow  = ref.read(flowProvider.notifier);
    final aN    = ref.read(authProvider.notifier);

    ref.listen(authProvider, (_, next) {
      if (next.isAuthenticated) flow.goTo(OnboardingStep.name);
      if (next.hasError && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.errorMessage!), backgroundColor: AppTheme.error));
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
              height: MediaQuery.sizeOf(context).height * 0.30,
            ))),
            Text("Let's Build Your\nSuccess Journey", style: AppTheme.displayLight),
            const SizedBox(height: AppTheme.s12),
            Text('Personalised exam preparation powered by AI. We adapt to your pace and focus on your growth.',
                style: AppTheme.bodyLight),
            const SizedBox(height: AppTheme.s32),
            GoogleButton(isLoading: auth.isLoading, onPressed: aN.googleSignIn),
            const SizedBox(height: AppTheme.s12),
            PrimaryButton(label: 'Continue with Phone Number', icon: Icons.arrow_forward_rounded,
                onPressed: () => flow.next()),
            const SizedBox(height: AppTheme.s16),
            Center(child: Text.rich(TextSpan(style: AppTheme.bodySmall, children: [
              const TextSpan(text: 'By continuing, you agree to our '),
              TextSpan(text: 'Terms of Service', style: AppTheme.linkText.copyWith(fontSize: 12)),
              const TextSpan(text: ' and '),
              TextSpan(text: 'Privacy Policy', style: AppTheme.linkText.copyWith(fontSize: 12)),
            ]), textAlign: TextAlign.center)),
            const SizedBox(height: AppTheme.s24),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 1/4 — NAME
// ══════════════════════════════════════════════════════════════════════════════
class NameStepScreen extends ConsumerStatefulWidget {
  const NameStepScreen({super.key});
  @override ConsumerState<NameStepScreen> createState() => _NameState();
}
class _NameState extends ConsumerState<NameStepScreen> {
  final _fKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last  = TextEditingController();
  @override void dispose() { _first.dispose(); _last.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(flowProvider);
    final fn   = ref.read(flowProvider.notifier);
    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
        child: Form(key: _fKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: AppTheme.s20),
          StepHeader(fraction: flow.fraction, progress: flow.progress, onBack: fn.back),
          const SizedBox(height: AppTheme.s32),
          IllustrationImage(asset: 'assets/images/onboarding_name.png',
              height: MediaQuery.sizeOf(context).height * 0.22),
          const SizedBox(height: AppTheme.s20),
          Text('What should we\ncall you?', style: AppTheme.displayLight),
          const SizedBox(height: AppTheme.s8),
          Text("Let's personalise your learning experience.", style: AppTheme.bodyLight),
          const SizedBox(height: AppTheme.s24),
          AlogyanField(controller: _first, hint: 'First Name', prefix: Icons.person_outline_rounded,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your first name' : null),
          const SizedBox(height: AppTheme.s12),
          AlogyanField(controller: _last, hint: 'Last Name', prefix: Icons.person_outline_rounded,
              action: TextInputAction.done,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your last name' : null),
          const Spacer(),
          PrimaryButton(label: 'Continue', icon: Icons.arrow_forward_rounded,
              onPressed: () {
                if (_fKey.currentState?.validate() ?? false) {
                  fn.setName(_first.text.trim(), _last.text.trim());
                  fn.next();
                }
              }),
          const SizedBox(height: AppTheme.s24),
        ])),
      )),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 2/4 — EMAIL / AUTH
// ══════════════════════════════════════════════════════════════════════════════
class EmailStepScreen extends ConsumerStatefulWidget {
  const EmailStepScreen({super.key});
  @override ConsumerState<EmailStepScreen> createState() => _EmailState();
}
class _EmailState extends ConsumerState<EmailStepScreen> {
  final _fKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _createPass = false;

  @override void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!(_fKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final fn = ref.read(flowProvider.notifier);
    final aN = ref.read(authProvider.notifier);
    fn.setLoading(true);
    fn.setEmail(_email.text.trim());
    final ok = _createPass
        ? await aN.register(email: _email.text.trim(), password: _pass.text)
        : true; // email-only: advance without auth
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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.errorMessage!), backgroundColor: AppTheme.error));
        aN.clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(child: SingleChildScrollView(
        padding: EdgeInsets.only(left: AppTheme.s24, right: AppTheme.s24, top: AppTheme.s20,
            bottom: MediaQuery.viewInsetsOf(context).bottom + AppTheme.s24),
        child: Form(key: _fKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          StepHeader(fraction: flow.fraction, progress: flow.progress, onBack: fn.back),
          const SizedBox(height: AppTheme.s24),
          IllustrationImage(asset: 'assets/images/onboarding_email.png',
              height: MediaQuery.sizeOf(context).height * 0.20),
          const SizedBox(height: AppTheme.s20),
          Text('Which email do\nyou use most?', style: AppTheme.displayLight),
          const SizedBox(height: AppTheme.s8),
          Text("We'll send important updates and study reminders.", style: AppTheme.bodyLight),
          const SizedBox(height: AppTheme.s24),
          if (flow.profile.displayName.isNotEmpty)
            Container(margin: const EdgeInsets.only(bottom: AppTheme.s16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: AppTheme.bgCardAlt,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM)),
              child: Row(children: [
                const Icon(Icons.waving_hand_rounded, size: 18, color: AppTheme.brandRed),
                const SizedBox(width: 8),
                Text('Hi, ${flow.profile.displayName}!', style: AppTheme.labelMedium),
              ]),
            ),
          AlogyanField(controller: _email, hint: 'name@example.com',
              keyboardType: TextInputType.emailAddress, prefix: Icons.mail_outline_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter your email';
                if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$').hasMatch(v.trim())) return 'Enter a valid email';
                return null;
              }),
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
            AlogyanField(controller: _pass, hint: 'Password (min. 6 chars)', isPassword: true,
                prefix: Icons.lock_outline_rounded, action: TextInputAction.done,
                validator: _createPass ? (v) {
                  if (v == null || v.isEmpty) return 'Enter password';
                  if (v.length < 6) return 'Min 6 characters';
                  return null;
                } : null),
          ],
          const SizedBox(height: AppTheme.s16),
          GoogleButton(isLoading: auth.isLoading, onPressed: () async {
            fn.setLoading(true);
            await aN.googleSignIn();
          }),
          const SizedBox(height: AppTheme.s16),
          PrimaryButton(label: 'Verify Email', icon: Icons.arrow_forward_rounded,
              isLoading: flow.isLoading || auth.isLoading, onPressed: _submit),
          const SizedBox(height: AppTheme.s12),
          Center(child: Text("You'll receive a verification email after sign up.",
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted, fontSize: 12),
              textAlign: TextAlign.center)),
        ])),
      )),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 3/4 — DATE OF BIRTH
// ══════════════════════════════════════════════════════════════════════════════
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
      context: context, initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1950), lastDate: DateTime(now.year - 5),
      builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(
              primary: AppTheme.brandRed, onPrimary: Colors.white,
              surface: AppTheme.bgWhite, onSurface: AppTheme.textPrimary)),
          child: child!),
    );
    if (picked != null) {
      setState(() {
        _selected = picked;
        _ctrl.text = '${picked.day.toString().padLeft(2,'0')} / ${picked.month.toString().padLeft(2,'0')} / ${picked.year}';
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
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: AppTheme.s20),
          StepHeader(fraction: flow.fraction, progress: flow.progress, onBack: fn.back,
              onSkip: fn.next),
          const SizedBox(height: AppTheme.s32),
          IllustrationImage(asset: 'assets/images/onboarding_dob.png',
              height: MediaQuery.sizeOf(context).height * 0.22),
          const SizedBox(height: AppTheme.s20),
          Text("When's your\nhappy birthday? 🎂", style: AppTheme.displayLight),
          const SizedBox(height: AppTheme.s8),
          Text("We'll personalise recommendations based on your age and education stage.",
              style: AppTheme.bodyLight),
          const SizedBox(height: AppTheme.s8),
          Row(children: [
            const Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.textMuted),
            const SizedBox(width: 6),
            Expanded(child: Text('This helps comply with age-related guidelines.',
                style: AppTheme.bodySmall.copyWith(fontSize: 12, color: AppTheme.textMuted))),
          ]),
          const SizedBox(height: AppTheme.s24),
          GestureDetector(onTap: _pick, child: AbsorbPointer(child: TextFormField(
            controller: _ctrl,
            style: AppTheme.bodyLight.copyWith(color: AppTheme.textPrimary),
            decoration: InputDecoration(hintText: 'DD / MM / YYYY',
              hintStyle: AppTheme.bodyLight.copyWith(color: AppTheme.textMuted),
              prefixIcon: const Icon(Icons.cake_outlined, color: AppTheme.textMuted, size: 18),
              suffixIcon: const Icon(Icons.calendar_today_outlined, color: AppTheme.brandRed, size: 18),
              filled: true, fillColor: AppTheme.bgWhite,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  borderSide: const BorderSide(color: AppTheme.borderLight)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  borderSide: const BorderSide(color: AppTheme.brandRed, width: 1.5)),
            ),
          ))),
          const Spacer(),
          PrimaryButton(label: 'Continue', icon: Icons.arrow_forward_rounded, onPressed: () {
            if (_selected != null) fn.setDob(_selected!);
            fn.next();
          }),
          const SizedBox(height: AppTheme.s24),
        ]),
      )),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 4/4 — EXAM GOAL
// ══════════════════════════════════════════════════════════════════════════════
class ExamGoalScreen extends ConsumerWidget {
  const ExamGoalScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(flowProvider);
    final fn   = ref.read(flowProvider.notifier);
    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: AppTheme.s20),
          StepHeader(fraction: flow.fraction, progress: flow.progress, onBack: fn.back),
          const SizedBox(height: AppTheme.s20),
          Text('What are you\npreparing for?', style: AppTheme.displayLight),
          const SizedBox(height: AppTheme.s8),
          Text('Select your target exam for a personalised study plan.', style: AppTheme.bodyLight),
          const SizedBox(height: AppTheme.s20),
          Expanded(child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: AppTheme.s12,
                crossAxisSpacing: AppTheme.s12, childAspectRatio: 2.6),
            itemCount: ExamGoals.all.length,
            itemBuilder: (_, i) {
              final g = ExamGoals.all[i];
              return OptionCard(label: g.label, emoji: g.emoji,
                  isSelected: flow.profile.examGoalId == g.id,
                  onTap: () => fn.setGoal(g.id));
            },
          )),
          const SizedBox(height: AppTheme.s16),
          PrimaryButton(label: 'Create My Learning Plan', icon: Icons.auto_awesome_rounded,
              onPressed: flow.profile.examGoalId != null ? fn.next : null),
          const SizedBox(height: AppTheme.s24),
        ]),
      )),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LEARNING STYLE
// ══════════════════════════════════════════════════════════════════════════════
class LearningStyleScreen extends ConsumerWidget {
  const LearningStyleScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(flowProvider);
    final fn   = ref.read(flowProvider.notifier);
    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: AppTheme.s20),
          StepHeader(progress: flow.progress, onBack: fn.back),
          const SizedBox(height: AppTheme.s20),
          IllustrationImage(asset: 'assets/images/onboarding_learning.png',
              height: MediaQuery.sizeOf(context).height * 0.20),
          const SizedBox(height: AppTheme.s20),
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
      )),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CURRENT JOURNEY
// ══════════════════════════════════════════════════════════════════════════════
class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(flowProvider);
    final fn   = ref.read(flowProvider.notifier);
    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: AppTheme.s20),
          StepHeader(progress: flow.progress, onBack: fn.back),
          const SizedBox(height: AppTheme.s20),
          IllustrationImage(asset: 'assets/images/onboarding_journey.png',
              height: MediaQuery.sizeOf(context).height * 0.20),
          const SizedBox(height: AppTheme.s20),
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
      )),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PLAN READY
// ══════════════════════════════════════════════════════════════════════════════
class PlanReadyScreen extends ConsumerWidget {
  const PlanReadyScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(flowProvider);
    final auth = ref.watch(authProvider);
    final aN   = ref.read(authProvider.notifier);
    final goal = ExamGoals.all.where((g) => g.id == flow.profile.examGoalId).firstOrNull;

    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: AppTheme.s32),
          Center(child: IllustrationImage(asset: 'assets/images/plan_ready_illustration.png',
              height: MediaQuery.sizeOf(context).height * 0.28)),
          const SizedBox(height: AppTheme.s32),
          // Assessment complete badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(AppTheme.radiusCircle)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF22C55E)),
              const SizedBox(width: 6),
              Text('Assessment Complete',
                  style: AppTheme.stepLabel.copyWith(color: const Color(0xFF22C55E))),
            ]),
          ),
          const SizedBox(height: AppTheme.s16),
          Text('Your Personalized\nStudy Plan Is Ready', style: AppTheme.displayLight),
          const SizedBox(height: AppTheme.s12),
          Text("We've crunched the numbers and analysed your profile from thousands of students similar to yours.",
              style: AppTheme.bodyLight),
          const SizedBox(height: AppTheme.s20),
          Row(children: [
            Expanded(child: _PlanChip(label: goal?.label ?? 'Your Goal',
                icon: Icons.flag_outlined, color: AppTheme.brandRed)),
            const SizedBox(width: AppTheme.s12),
            Expanded(child: _PlanChip(label: '12 Modules',
                icon: Icons.layers_outlined, color: const Color(0xFF6366F1))),
          ]),
          const SizedBox(height: AppTheme.s12),
          Row(children: [
            Expanded(child: _PlanChip(label: '2.5 Hours/day',
                icon: Icons.timer_outlined, color: const Color(0xFF059669))),
            const SizedBox(width: AppTheme.s12),
            Expanded(child: _PlanChip(label: 'Adaptive AI',
                icon: Icons.auto_awesome_rounded, color: const Color(0xFFF59E0B))),
          ]),
          const Spacer(),
          PrimaryButton(
            label: 'Start Learning',
            icon: Icons.arrow_forward_rounded,
            isLoading: auth.isLoading,
            onPressed: () async {
              final uid = auth.userId;
              if (uid != null) {
                await aN.saveProfile(uid: uid, data: flow.profile.toMap());
              }
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const _HomeStub()));
              }
            },
          ),
          const SizedBox(height: AppTheme.s24),
        ]),
      )),
    );
  }
}

class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.label, required this.icon, required this.color});
  final String label; final IconData icon; final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppTheme.s12),
    decoration: BoxDecoration(color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: AppTheme.cardShadow),
    child: Row(children: [
      Icon(icon, size: 16, color: color), const SizedBox(width: 6),
      Expanded(child: Text(label,
          style: AppTheme.labelMedium.copyWith(fontSize: 12))),
    ]),
  );
}

// ── Temporary HomeStub inside same file ──────────────────────────────────────
class _HomeStub extends ConsumerWidget {
  const _HomeStub();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    ref.listen(authProvider, (_, next) {
      if (next.status == AuthStatus.unauthenticated) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const _LoginScreen()),
                (_) => false);
      }
    });
    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(AppTheme.s24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const BrandRow(),
            const Spacer(),
            GestureDetector(
              onTap: () => ref.read(authProvider.notifier).signOut(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.bgWhite,
                    borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
                    border: Border.all(color: AppTheme.borderLight)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.logout_rounded, size: 15, color: AppTheme.brandRed),
                  const SizedBox(width: 6),
                  Text('Sign out', style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.brandRed, fontSize: 13)),
                ]),
              ),
            ),
          ]),
          const Spacer(),
          Text('You\'re all set! 🎉', style: AppTheme.headingLight),
          const SizedBox(height: AppTheme.s8),
          Text(auth.email ?? '', style: AppTheme.bodyLight.copyWith(color: AppTheme.textMuted)),
          const SizedBox(height: AppTheme.s16),
          Container(padding: const EdgeInsets.all(AppTheme.s16),
              decoration: BoxDecoration(color: AppTheme.brandRedSurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM)),
              child: Text('ALO-002 Bundle Listing coming next 🚀',
                  style: AppTheme.bodyLight.copyWith(color: AppTheme.brandRed))),
          const Spacer(),
        ]),
      )),
    );
  }
}

// ── Login screen for returning users ─────────────────────────────────────────
class _LoginScreen extends ConsumerStatefulWidget {
  const _LoginScreen();
  @override ConsumerState<_LoginScreen> createState() => _LoginState();
}
class _LoginState extends ConsumerState<_LoginScreen> {
  final _fKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _isRegister = false;

  @override void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!(_fKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final aN = ref.read(authProvider.notifier);
    if (_isRegister) { await aN.register(email: _email.text, password: _pass.text); }
    else             { await aN.signIn(email: _email.text, password: _pass.text); }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    ref.listen(authProvider, (_, next) {
      if (next.isAuthenticated) Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const _HomeStub()));
      if (next.hasError && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.errorMessage!), backgroundColor: AppTheme.error));
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(child: SingleChildScrollView(
        padding: EdgeInsets.only(left: AppTheme.s24, right: AppTheme.s24, top: AppTheme.s40,
            bottom: MediaQuery.viewInsetsOf(context).bottom + AppTheme.s40),
        child: Form(key: _fKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const BrandRow(),
          const SizedBox(height: AppTheme.s40),
          Text(_isRegister ? 'Create\nAccount' : 'Welcome\nBack 👋', style: AppTheme.displayLight),
          const SizedBox(height: AppTheme.s8),
          Text(_isRegister ? 'Sign up to start your exam prep.' : 'Sign in to continue.',
              style: AppTheme.bodyLight),
          const SizedBox(height: AppTheme.s32),
          GoogleButton(isLoading: auth.isLoading,
              onPressed: () => ref.read(authProvider.notifier).googleSignIn()),
          const SizedBox(height: AppTheme.s20),
          const OrDivider(),
          const SizedBox(height: AppTheme.s20),
          AlogyanField(controller: _email, hint: 'Email address',
              keyboardType: TextInputType.emailAddress, prefix: Icons.mail_outline_rounded,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter email' : null),
          const SizedBox(height: AppTheme.s12),
          AlogyanField(controller: _pass, hint: 'Password', isPassword: true,
              prefix: Icons.lock_outline_rounded, action: TextInputAction.done,
              onSubmit: (_) => _submit(),
              validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null),
          const SizedBox(height: AppTheme.s32),
          PrimaryButton(label: _isRegister ? 'Create Account' : 'Sign In',
              isLoading: auth.isLoading, onPressed: _submit),
          const SizedBox(height: AppTheme.s24),
          Center(child: GestureDetector(
            onTap: () => setState(() => _isRegister = !_isRegister),
            child: Text.rich(TextSpan(style: AppTheme.bodyLight, children: [
              TextSpan(text: _isRegister ? 'Already have an account? ' : "Don't have an account? "),
              TextSpan(text: _isRegister ? 'Sign In' : 'Sign Up', style: AppTheme.linkText),
            ])),
          )),
        ])),
      )),
    );
  }
}