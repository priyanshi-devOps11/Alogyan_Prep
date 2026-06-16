import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/onboarding/controllers/controllers.dart';
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';
import 'package:alogyan_prep/features/onboarding/presentation/screens/phone_login_screen.dart';
import 'package:alogyan_prep/features/onboarding/presentation/widgets/widgets.dart';

// ══════════════════════════════════════════════════════════════════════════════
// WELCOME SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final aN   = ref.read(authProvider.notifier);
    final flow = ref.read(flowProvider.notifier);

    ref.listen(authProvider, (_, next) {
      if (next.isAuthenticated) flow.goTo(OnboardingStep.name);
      if (next.hasError && next.errorMessage != null) {
        _showError(context, next.errorMessage!, isDev: next.isDeveloperError);
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
                height: MediaQuery.sizeOf(context).height * 0.28))),
            Text("Let's Build Your\nSuccess Journey", style: AppTheme.displayLight),
            const SizedBox(height: AppTheme.s12),
            Text('Personalised exam preparation powered by AI. We adapt to your pace.',
                style: AppTheme.bodyLight),
            const SizedBox(height: AppTheme.s32),
            GoogleButton(isLoading: auth.isLoading, onPressed: aN.googleSignIn),
            const SizedBox(height: AppTheme.s12),
            PrimaryButton(label: 'Get Started', icon: Icons.arrow_forward_rounded,
                onPressed: () => flow.goTo(OnboardingStep.name)),
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

// ══════════════════════════════════════════════════════════════════════════════
// STEP 1/4 — NAME
// ══════════════════════════════════════════════════════════════════════════════
class NameStepScreen extends ConsumerStatefulWidget {
  const NameStepScreen({super.key});
  @override ConsumerState<NameStepScreen> createState() => _NameState();
}
class _NameState extends ConsumerState<NameStepScreen> {
  final _fKey   = GlobalKey<FormState>();
  final _first  = TextEditingController();
  final _last   = TextEditingController();
  final _lastFN = FocusNode();

  @override
  void dispose() { _first.dispose(); _last.dispose(); _lastFN.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(flowProvider);
    final fn   = ref.read(flowProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
              left: AppTheme.s24, right: AppTheme.s24, top: AppTheme.s20,
              bottom: MediaQuery.viewInsetsOf(context).bottom + AppTheme.s24),
          child: Form(key: _fKey, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            StepHeader(fraction: flow.fraction, progress: flow.progress, onBack: fn.back),
            const SizedBox(height: AppTheme.s24),
            IllustrationImage(asset: 'assets/images/onboarding_name.png', height: 160),
            const SizedBox(height: AppTheme.s20),
            Text('What should we\ncall you?', style: AppTheme.displayLight),
            const SizedBox(height: AppTheme.s8),
            Text("Let's personalise your learning experience.", style: AppTheme.bodyLight),
            const SizedBox(height: AppTheme.s24),
            AlogyanField(
                controller: _first, hint: 'First Name',
                prefix: Icons.person_outline_rounded,
                action: TextInputAction.next,
                onSubmit: (_) => FocusScope.of(context).requestFocus(_lastFN),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter your first name' : null),
            const SizedBox(height: AppTheme.s12),
            AlogyanField(
                controller: _last, hint: 'Last Name',
                prefix: Icons.person_outline_rounded,
                focusNode: _lastFN,
                action: TextInputAction.done,
                onSubmit: (_) => _submit(fn),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter your last name' : null),
            const SizedBox(height: AppTheme.s32),
            PrimaryButton(label: 'Continue', icon: Icons.arrow_forward_rounded,
                onPressed: () => _submit(fn)),
          ])),
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

// ══════════════════════════════════════════════════════════════════════════════
// STEP 2/4 — EMAIL (mandatory password + phone link + auth gate)
// ══════════════════════════════════════════════════════════════════════════════
class EmailStepScreen extends ConsumerStatefulWidget {
  const EmailStepScreen({super.key});
  @override ConsumerState<EmailStepScreen> createState() => _EmailState();
}
class _EmailState extends ConsumerState<EmailStepScreen> {
  final _fKey    = GlobalKey<FormState>();
  final _emailC  = TextEditingController();
  final _passC   = TextEditingController();
  final _confC   = TextEditingController();
  final _passFN  = FocusNode();
  final _confFN  = FocusNode();
  bool _passVis  = false;
  bool _confVis  = false;

  // ── Strong password regex ────────────────────────────────────────────────
  static final _passRegex =
  RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>_\-]).{6,}$');

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$').hasMatch(v.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePass(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (!_passRegex.hasMatch(v)) {
      return 'Min 6 chars with uppercase, lowercase, digit & special char\n(e.g. Asdfgh@12)';
    }
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _passC.text) return 'Passwords do not match';
    return null;
  }

  double _strength(String p) {
    int s = 0;
    if (p.length >= 6) s++;
    if (p.contains(RegExp(r'[A-Z]'))) s++;
    if (p.contains(RegExp(r'[a-z]'))) s++;
    if (p.contains(RegExp(r'\d'))) s++;
    if (p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]'))) s++;
    return s / 5;
  }

  Color _strengthColor(double s) {
    if (s < 0.4) return AppTheme.error;
    if (s < 0.8) return AppTheme.warning;
    return AppTheme.success;
  }

  String _strengthLabel(double s) {
    if (s < 0.4) return 'Weak';
    if (s < 0.8) return 'Medium';
    return 'Strong ✓';
  }

  Future<void> _submit() async {
    if (!(_fKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final fn = ref.read(flowProvider.notifier);
    final aN = ref.read(authProvider.notifier);
    fn.setEmail(_emailC.text.trim());
    fn.setLoading(true);
    final ok = await aN.register(
        email: _emailC.text.trim(), password: _passC.text);
    fn.setLoading(false);
    // register() sets auth state to emailPendingVerification on success
    // The onboarding_screen router picks that up and shows EmailVerifyWaitScreen
  }

  @override
  void dispose() {
    _emailC.dispose(); _passC.dispose(); _confC.dispose();
    _passFN.dispose(); _confFN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow   = ref.watch(flowProvider);
    final auth   = ref.watch(authProvider);
    final fn     = ref.read(flowProvider.notifier);
    final aN     = ref.read(authProvider.notifier);
    final pass   = _passC.text;
    final str    = _strength(pass);

    ref.listen(authProvider, (_, next) {
      if (next.hasError && next.errorMessage != null) {
        fn.setLoading(false);
        _showError(context, next.errorMessage!, isDev: next.isDeveloperError);
        aN.clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
              left: AppTheme.s24, right: AppTheme.s24, top: AppTheme.s20,
              bottom: MediaQuery.viewInsetsOf(context).bottom + AppTheme.s24),
          child: Form(key: _fKey, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            StepHeader(fraction: flow.fraction, progress: flow.progress, onBack: fn.back),
            const SizedBox(height: AppTheme.s20),
            IllustrationImage(asset: 'assets/images/onboarding_email.png', height: 130),
            const SizedBox(height: AppTheme.s20),
            Text('Which email do\nyou use most?', style: AppTheme.displayLight),
            const SizedBox(height: AppTheme.s8),
            Text("We'll send important updates and study reminders.", style: AppTheme.bodyLight),
            const SizedBox(height: AppTheme.s20),

            // Hi greeting
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
                  ])),

            // Email field
            AlogyanField(controller: _emailC, hint: 'name@example.com',
                keyboardType: TextInputType.emailAddress,
                prefix: Icons.mail_outline_rounded,
                action: TextInputAction.next,
                onSubmit: (_) => FocusScope.of(context).requestFocus(_passFN),
                validator: _validateEmail),
            const SizedBox(height: AppTheme.s12),

            // Password (mandatory)
            StatefulBuilder(builder: (_, ss) => Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextFormField(
                  controller: _passC,
                  focusNode: _passFN,
                  obscureText: !_passVis,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => ss(() {}),
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confFN),
                  validator: _validatePass,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: AppTheme.bodyLight.copyWith(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                      hintText: 'Password (e.g. Asdfgh@12)',
                      hintStyle: AppTheme.bodyLight.copyWith(color: AppTheme.textMuted),
                      prefixIcon: const Icon(Icons.lock_outline_rounded,
                          color: AppTheme.textMuted, size: 18),
                      suffixIcon: GestureDetector(
                          onTap: () => setState(() => _passVis = !_passVis),
                          child: Icon(_passVis ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                              color: AppTheme.textMuted, size: 18)))),

              // Strength bar
              if (pass.isNotEmpty) ...[
                const SizedBox(height: AppTheme.s8),
                Row(children: [
                  Expanded(child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(value: str, minHeight: 4,
                          backgroundColor: AppTheme.borderLight,
                          valueColor: AlwaysStoppedAnimation(_strengthColor(str))))),
                  const SizedBox(width: 8),
                  Text(_strengthLabel(str),
                      style: AppTheme.stepLabel.copyWith(
                          color: _strengthColor(str), fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: AppTheme.s4),
                _PassRequirements(pass: pass),
              ],
            ])),

            const SizedBox(height: AppTheme.s12),

            // Confirm password
            StatefulBuilder(builder: (_, ss) => TextFormField(
                controller: _confC, focusNode: _confFN,
                obscureText: !_confVis,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: _validateConfirm,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                style: AppTheme.bodyLight.copyWith(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                    hintText: 'Confirm password',
                    hintStyle: AppTheme.bodyLight.copyWith(color: AppTheme.textMuted),
                    prefixIcon: const Icon(Icons.lock_outline_rounded,
                        color: AppTheme.textMuted, size: 18),
                    suffixIcon: GestureDetector(
                        onTap: () => setState(() => _confVis = !_confVis),
                        child: Icon(_confVis ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                            color: AppTheme.textMuted, size: 18))))),
            const SizedBox(height: AppTheme.s16),

            // Google
            GoogleButton(isLoading: auth.isLoading, onPressed: () async {
              fn.setLoading(true);
              final ok = await aN.googleSignIn();
              fn.setLoading(false);
              if (ok && context.mounted) fn.next();
            }),
            const SizedBox(height: AppTheme.s12),

            // Phone number alternative
            GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PhoneLoginScreen())),
                child: Container(width: double.infinity, height: 52,
                    decoration: BoxDecoration(color: AppTheme.bgWhite,
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: AppTheme.cardShadow),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.phone_outlined,
                          color: AppTheme.textPrimary, size: 18),
                      const SizedBox(width: 10),
                      Text('Login with Phone Number',
                          style: AppTheme.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                    ]))),
            const SizedBox(height: AppTheme.s16),

            // CTA
            PrimaryButton(label: 'Create Account & Verify',
                isLoading: flow.isLoading || auth.isLoading,
                onPressed: _submit),
            const SizedBox(height: AppTheme.s12),
            Center(child: Text(
                'A verification link will be sent to your email.',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted, fontSize: 12),
                textAlign: TextAlign.center)),
          ])),
        ),
      ),
    );
  }
}

// Password requirements checklist
class _PassRequirements extends StatelessWidget {
  const _PassRequirements({required this.pass});
  final String pass;
  @override
  Widget build(BuildContext context) {
    final checks = [
      _Chk('At least 6 characters', pass.length >= 6),
      _Chk('One uppercase letter (A-Z)', pass.contains(RegExp(r'[A-Z]'))),
      _Chk('One lowercase letter (a-z)', pass.contains(RegExp(r'[a-z]'))),
      _Chk('One digit (0-9)', pass.contains(RegExp(r'\d'))),
      _Chk('One special character (!@#\$%)',
          pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]'))),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: checks.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(children: [
              Icon(c.met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 13, color: c.met ? AppTheme.success : AppTheme.textMuted),
              const SizedBox(width: 6),
              Text(c.label, style: AppTheme.bodySmall.copyWith(fontSize: 11,
                  color: c.met ? AppTheme.success : AppTheme.textMuted)),
            ]))).toList());
  }
}
class _Chk { final String label; final bool met; const _Chk(this.label, this.met); }

// ══════════════════════════════════════════════════════════════════════════════
// EMAIL VERIFY WAIT SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class EmailVerifyWaitScreen extends ConsumerStatefulWidget {
  const EmailVerifyWaitScreen({super.key});
  @override ConsumerState<EmailVerifyWaitScreen> createState() => _EVWState();
}
class _EVWState extends ConsumerState<EmailVerifyWaitScreen> {
  int _elapsed = 0;
  bool _canResend = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() { _elapsed++; if (_elapsed >= 30) _canResend = true; });
      return mounted;
    });
  }

  void _startPolling() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return false;
      setState(() => _checking = true);
      final verified = await ref.read(authProvider.notifier).checkEmailVerified();
      if (!mounted) return false;
      setState(() => _checking = false);
      if (verified) { ref.read(flowProvider.notifier).next(); return false; }
      return mounted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(AppTheme.s24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(height: AppTheme.s40),
          Container(width: 90, height: 90,
              decoration: BoxDecoration(color: AppTheme.brandRedSurface, shape: BoxShape.circle),
              child: const Icon(Icons.mark_email_unread_rounded,
                  size: 46, color: AppTheme.brandRed)),
          const SizedBox(height: AppTheme.s24),
          Text('Verify your email', style: AppTheme.headingLight, textAlign: TextAlign.center),
          const SizedBox(height: AppTheme.s12),
          Text('A verification link was sent to\n${auth.email ?? ''}',
              style: AppTheme.bodyLight, textAlign: TextAlign.center),
          const SizedBox(height: AppTheme.s32),
          // Checking indicator
          Container(padding: const EdgeInsets.all(AppTheme.s16),
              decoration: BoxDecoration(color: AppTheme.bgWhite,
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  boxShadow: AppTheme.cardShadow),
              child: Row(children: [
                SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5,
                        color: _checking ? AppTheme.brandRed : AppTheme.borderLight)),
                const SizedBox(width: AppTheme.s12),
                Text(_checking ? 'Checking...' : 'Waiting for verification...',
                    style: AppTheme.bodyLight),
              ])),
          const SizedBox(height: AppTheme.s16),
          Text('Open your email and click the verification link.\nThis page will update automatically.',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted),
              textAlign: TextAlign.center),
          const Spacer(),
          // Resend
          GestureDetector(
              onTap: _canResend ? () async {
                await ref.read(authRepositoryProvider).sendVerificationEmail();
                setState(() { _canResend = false; _elapsed = 0; });
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verification email resent!')));
              } : null,
              child: Container(width: double.infinity, height: 50,
                  decoration: BoxDecoration(
                      color: _canResend ? AppTheme.bgWhite : AppTheme.bgSoft,
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      border: Border.all(color: _canResend ? AppTheme.brandRed : AppTheme.borderLight)),
                  child: Center(child: Text(
                      _canResend ? 'Resend verification email'
                          : 'Resend in ${30 - _elapsed}s',
                      style: AppTheme.labelMedium.copyWith(
                          color: _canResend ? AppTheme.brandRed : AppTheme.textMuted))))),
          const SizedBox(height: AppTheme.s12),
          GestureDetector(
              onTap: () => ref.read(flowProvider.notifier).next(),
              child: Text('Skip for now →', style: AppTheme.linkText.copyWith(fontSize: 13))),
          const SizedBox(height: AppTheme.s24),
        ]),
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
  DateTime? _picked;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  // AUTH GATE: user must be authenticated to reach DOB
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authProvider);
      if (!auth.isAuthenticated) {
        ref.read(flowProvider.notifier).goTo(OnboardingStep.verifyEmail);
      }
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
        context: context, initialDate: DateTime(now.year - 18),
        firstDate: DateTime(1950), lastDate: DateTime(now.year - 5),
        builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(
                primary: AppTheme.brandRed, onPrimary: Colors.white,
                surface: AppTheme.bgWhite, onSurface: AppTheme.textPrimary)),
            child: child!));
    if (d != null) {
      setState(() {
        _picked = d;
        _ctrl.text = '${d.day.toString().padLeft(2,'0')} / '
            '${d.month.toString().padLeft(2,'0')} / ${d.year}';
      });
    }
  }

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
          StepHeader(fraction: flow.fraction, progress: flow.progress,
              onBack: fn.back, onSkip: fn.next),
          const SizedBox(height: AppTheme.s24),
          IllustrationImage(asset: 'assets/images/onboarding_dob.png', height: 160),
          const SizedBox(height: AppTheme.s20),
          Text("When's your\nhappy birthday? 🎂", style: AppTheme.displayLight),
          const SizedBox(height: AppTheme.s8),
          Text("We'll personalise recommendations based on your age.", style: AppTheme.bodyLight),
          const SizedBox(height: AppTheme.s20),
          GestureDetector(onTap: _pickDate, child: AbsorbPointer(child: TextField(
              controller: _ctrl,
              style: AppTheme.bodyLight.copyWith(color: AppTheme.textPrimary),
              decoration: InputDecoration(hintText: 'DD / MM / YYYY',
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
                      borderSide: const BorderSide(color: AppTheme.brandRed, width: 1.5)))))),
          const Spacer(),
          PrimaryButton(label: 'Continue', icon: Icons.arrow_forward_rounded,
              onPressed: () { if (_picked != null) fn.setDob(_picked!); fn.next(); }),
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
          const SizedBox(height: AppTheme.s16),
          Text('What are you\npreparing for?', style: AppTheme.displayLight),
          const SizedBox(height: AppTheme.s8),
          Text('Select your target exam for a personalised plan.', style: AppTheme.bodyLight),
          const SizedBox(height: AppTheme.s16),
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
              })),
          const SizedBox(height: AppTheme.s16),
          PrimaryButton(label: 'Create My Learning Plan',
              icon: Icons.auto_awesome_rounded,
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
              })),
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
              })),
          const SizedBox(height: AppTheme.s16),
          PrimaryButton(label: 'Continue', icon: Icons.arrow_forward_rounded,
              onPressed: flow.profile.journeyLevelId != null ? fn.next : null),
          const SizedBox(height: AppTheme.s24),
        ]),
      )),
    );
  }
}

// ── Shared error helper ───────────────────────────────────────────────────────
void _showError(BuildContext context, String message, {bool isDev = false}) {
  if (isDev) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppTheme.bgWhite,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL)),
      title: const Row(children: [
        Icon(Icons.warning_amber_rounded, color: AppTheme.warning),
        SizedBox(width: 8),
        Text('Configuration Error', style: TextStyle(fontSize: 16,
            fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
      ]),
      content: Text(message, style: AppTheme.bodyLight.copyWith(fontSize: 13)),
      actions: [TextButton(onPressed: () => Navigator.pop(context),
          child: Text('OK', style: AppTheme.linkText))],
    ));
  } else {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message),
          backgroundColor: AppTheme.error));
  }
}