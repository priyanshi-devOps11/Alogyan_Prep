import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/onboarding/controllers/controllers.dart';
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';
import 'package:alogyan_prep/features/onboarding/presentation/screens/phone_login_screen.dart';
import 'package:alogyan_prep/features/onboarding/presentation/widgets/widgets.dart';

/// Step 2/4 — Email with strong password + phone option + email verification trigger.
class EmailStepScreen extends ConsumerStatefulWidget {
  const EmailStepScreen({super.key});
  @override
  ConsumerState<EmailStepScreen> createState() => _EmailStepState();
}

class _EmailStepState extends ConsumerState<EmailStepScreen> {
  final _fKey      = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _confCtrl  = TextEditingController();
  bool _createPass  = false;
  bool _passVisible = false;
  bool _confVisible = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confCtrl.dispose();
    super.dispose();
  }

  // ── Strong password rules ──────────────────────────────────────────────────
  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter a password';
    if (v.length < 8) return 'Minimum 8 characters required';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'At least one uppercase letter (A-Z)';
    if (!v.contains(RegExp(r'[a-z]'))) return 'At least one lowercase letter (a-z)';
    if (!v.contains(RegExp(r'[0-9]'))) return 'At least one number (0-9)';
    if (!v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))) {
      return 'At least one special character (!@#\$%)';
    }
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _passCtrl.text) return 'Passwords do not match';
    return null;
  }

  // ── Password strength indicator ────────────────────────────────────────────
  double _passwordStrength(String pass) {
    int score = 0;
    if (pass.length >= 8) score++;
    if (pass.contains(RegExp(r'[A-Z]'))) score++;
    if (pass.contains(RegExp(r'[a-z]'))) score++;
    if (pass.contains(RegExp(r'[0-9]'))) score++;
    if (pass.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))) score++;
    return score / 5;
  }

  Color _strengthColor(double strength) {
    if (strength < 0.4) return AppTheme.error;
    if (strength < 0.8) return const Color(0xFFF59E0B); // Direct beautiful amber validation color
    return AppTheme.success;
  }

  String _strengthLabel(double strength) {
    if (strength < 0.4) return 'Weak';
    if (strength < 0.8) return 'Medium';
    return 'Strong';
  }

  Future<void> _submit() async {
    if (!(_fKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final fn = ref.read(flowProvider.notifier);
    final aN = ref.read(authProvider.notifier);
    fn.setLoading(true);
    fn.setEmail(_emailCtrl.text.trim());

    if (_createPass) {
      // Register → sends verification email → shows verify wait screen
      final ok = await aN.register(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      fn.setLoading(false);
      if (ok && mounted) {
        // Go to email verification waiting screen
        fn.goTo(OnboardingStep.verifyEmail);
      }
    } else {
      // No password — just save email and continue
      fn.setLoading(false);
      fn.next();
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(flowProvider);
    final auth = ref.watch(authProvider);
    final fn   = ref.read(flowProvider.notifier);
    final aN   = ref.read(authProvider.notifier);
    final passText = _passCtrl.text;
    final strength = _passwordStrength(passText);

    ref.listen(authProvider, (_, next) {
      if (next.hasError && next.errorMessage != null) {
        fn.setLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppTheme.error));
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
              StepHeader(
                fraction: flow.fraction,
                progress: flow.progress,
                onBack: fn.back,
              ),
              const SizedBox(height: AppTheme.s20),
              IllustrationImage(
                  asset: 'assets/images/onboarding_email.png', height: 130),
              const SizedBox(height: AppTheme.s20),
              Text('Which email do\nyou use most?', style: AppTheme.displayLight),
              const SizedBox(height: AppTheme.s8),
              Text("We'll send important updates and study reminders.",
                  style: AppTheme.bodyLight),
              const SizedBox(height: AppTheme.s20),

              // Hi greeting
              if (flow.profile.displayName.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: AppTheme.s16),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                      color: AppTheme.bgCardAlt,
                      borderRadius: BorderRadius.circular(AppTheme.radiusM)),
                  child: Row(children: [
                    const Text('👋', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text('Hi, ${flow.profile.displayName}!',
                        style: AppTheme.labelMedium),
                  ]),
                ),

              // Email field
              AlogyanField(
                controller: _emailCtrl,
                hint: 'name@example.com',
                keyboardType: TextInputType.emailAddress,
                prefix: Icons.mail_outline_rounded,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter your email';
                  if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$')
                      .hasMatch(v.trim())) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.s12),

              // Create password toggle
              GestureDetector(
                onTap: () => setState(() => _createPass = !_createPass),
                child: Row(children: [
                  Icon(
                      _createPass
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 20, color: AppTheme.brandRed),
                  const SizedBox(width: 8),
                  Text('Create password for my account',
                      style: AppTheme.labelMedium.copyWith(fontSize: 13)),
                ]),
              ),

              if (_createPass) ...[
                const SizedBox(height: AppTheme.s12),

                // Password field
                StatefulBuilder(builder: (_, setSt) => TextFormField(
                  controller: _passCtrl,
                  obscureText: !_passVisible,
                  textInputAction: TextInputAction.next,
                  style: AppTheme.bodyLight.copyWith(color: AppTheme.textPrimary),
                  onChanged: (_) => setState(() {}),
                  validator: _validatePassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    hintText: 'Password (min 8 chars)',
                    hintStyle: AppTheme.bodyLight.copyWith(color: AppTheme.textMuted),
                    prefixIcon: const Icon(Icons.lock_outline_rounded,
                        color: AppTheme.textMuted, size: 18),
                    suffixIcon: GestureDetector(
                        onTap: () => setState(() => _passVisible = !_passVisible),
                        child: Icon(
                            _passVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.textMuted, size: 18)),
                  ),
                )),

                // Strength bar
                if (passText.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.s8),
                  Row(children: [
                    Expanded(child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: strength,
                        minHeight: 4,
                        backgroundColor: AppTheme.borderLight,
                        valueColor: AlwaysStoppedAnimation(_strengthColor(strength)),
                      ),
                    )),
                    const SizedBox(width: 10),
                    Text(_strengthLabel(strength),
                        style: AppTheme.stepLabel.copyWith(
                            color: _strengthColor(strength),
                            fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: AppTheme.s4),
                  // Requirements checklist
                  _PasswordRequirements(password: passText),
                ],

                const SizedBox(height: AppTheme.s12),

                // Confirm password field
                StatefulBuilder(builder: (_, setSt) => TextFormField(
                  controller: _confCtrl,
                  obscureText: !_confVisible,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  style: AppTheme.bodyLight.copyWith(color: AppTheme.textPrimary),
                  validator: _validateConfirm,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    hintText: 'Confirm password',
                    hintStyle: AppTheme.bodyLight.copyWith(color: AppTheme.textMuted),
                    prefixIcon: const Icon(Icons.lock_outline_rounded,
                        color: AppTheme.textMuted, size: 18),
                    suffixIcon: GestureDetector(
                        onTap: () => setState(() => _confVisible = !_confVisible),
                        child: Icon(
                            _confVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.textMuted, size: 18)),
                  ),
                )),
              ],

              const SizedBox(height: AppTheme.s16),

              // Google button
              GoogleButton(
                isLoading: auth.isLoading,
                onPressed: () async {
                  fn.setLoading(true);
                  final ok = await aN.googleSignIn();
                  fn.setLoading(false);
                  if (ok && mounted) fn.next();
                },
              ),

              const SizedBox(height: AppTheme.s12),

              // Phone login option
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
                ),
                child: Container(
                  width: double.infinity, height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.bgWhite,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(color: AppTheme.borderLight),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_outlined,
                            color: AppTheme.textPrimary, size: 20),
                        const SizedBox(width: 10),
                        Text('Continue with Phone Number',
                            style: AppTheme.labelMedium
                                .copyWith(fontWeight: FontWeight.w600)),
                      ]),
                ),
              ),

              const SizedBox(height: AppTheme.s16),

              // Main CTA
              PrimaryButton(
                label: _createPass ? 'Create Account & Verify' : 'Verify Email →',
                isLoading: flow.isLoading || auth.isLoading,
                onPressed: _submit,
              ),

              const SizedBox(height: AppTheme.s12),
              Center(child: Text(
                _createPass
                    ? 'A verification link will be sent to your email'
                    : "You'll receive a verification email after account creation.",
                style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textMuted, fontSize: 12),
                textAlign: TextAlign.center,
              )),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Password requirements checklist ───────────────────────────────────────────
class _PasswordRequirements extends StatelessWidget {
  const _PasswordRequirements({required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    final checks = [
      _Check('Minimum 8 characters', password.length >= 8),
      _Check('One uppercase letter (A-Z)',
          password.contains(RegExp(r'[A-Z]'))),
      _Check('One lowercase letter (a-z)',
          password.contains(RegExp(r'[a-z]'))),
      _Check('One number (0-9)', password.contains(RegExp(r'[0-9]'))),
      _Check('One special character (!@#\$%)',
          password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: checks.map((c) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(children: [
          Icon(
            c.met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 14,
            color: c.met ? AppTheme.success : AppTheme.textMuted,
          ),
          const SizedBox(width: 6),
          Text(c.label,
              style: AppTheme.bodySmall.copyWith(
                  fontSize: 11,
                  color: c.met ? AppTheme.success : AppTheme.textMuted)),
        ]),
      )).toList(),
    );
  }
}

class _Check { final String label; final bool met; const _Check(this.label, this.met); }