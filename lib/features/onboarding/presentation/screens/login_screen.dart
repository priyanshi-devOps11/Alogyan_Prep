import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/onboarding/controllers/controllers.dart';
import 'package:alogyan_prep/features/onboarding/presentation/widgets/widgets.dart';

/// On successful sign-in, _AuthGate in main.dart automatically routes:
///   - isOnboardingCompleted == true  → BundleListingScreen
///   - isOnboardingCompleted == false → resume pending step (DOB / goal etc.)
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _passFocus  = FocusNode();
  bool  _passVis    = false;
  bool  _loading    = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  // ── Email + Password sign in ──────────────────────────────────────────────
  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    final ok = await ref.read(authProvider.notifier).signIn(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) {
      final err =
          ref.read(authProvider).errorMessage ?? 'Sign in failed.';
      _showErr(err,
          isDev: ref.read(authProvider).isDeveloperError);
      ref.read(authProvider.notifier).clearError();
    }
    // On success: _AuthGate watches authProvider and auto-routes.
    // No Navigator.pop() needed — MaterialApp root rebuilds.
  }

  // ── Google sign in ────────────────────────────────────────────────────────
  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    final ok = await ref.read(authProvider.notifier).googleSignIn();
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      final err =
          ref.read(authProvider).errorMessage ?? 'Google sign-in failed.';
      _showErr(err, isDev: ref.read(authProvider).isDeveloperError);
      ref.read(authProvider.notifier).clearError();
    }
  }

  // ── Forgot password ───────────────────────────────────────────────────────
  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showErr('Enter your email address above, then tap Forgot Password.');
      return;
    }
    final ok =
    await ref.read(authProvider.notifier).resetPassword(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(ok
            ? 'Reset email sent to $email'
            : 'Could not send reset email. Check the address.'),
        backgroundColor: ok ? AppTheme.success : AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusS)),
      ));
  }

  void _showErr(String msg, {bool isDev = false}) {
    if (isDev) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppTheme.bgWhite,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusL)),
          title: const Row(children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.warning),
            SizedBox(width: 8),
            Flexible(
              child: Text('Config Error',
                  style: TextStyle(fontFamily: 'Poppins',
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ]),
          content: Text(msg,
              style: AppTheme.bodyLight.copyWith(fontSize: 13)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: AppTheme.linkText),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusS)),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: AppTheme.s24,
            right: AppTheme.s24,
            top: AppTheme.s32,
            bottom: MediaQuery.viewInsetsOf(context).bottom + AppTheme.s32,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.bgWhite,
                      borderRadius:
                      BorderRadius.circular(AppTheme.radiusS),
                      border: Border.all(color: AppTheme.borderLight),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppTheme.textPrimary),
                  ),
                ),

                const SizedBox(height: AppTheme.s32),

                Text('Welcome back! 👋',
                    style: AppTheme.displayLight),
                const SizedBox(height: AppTheme.s8),
                Text(
                  'Sign in to continue your exam preparation.',
                  style: AppTheme.bodyLight,
                ),

                const SizedBox(height: AppTheme.s32),

                // Email field
                AlogyanField(
                  controller: _emailCtrl,
                  hint: 'name@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefix: Icons.mail_outline_rounded,
                  action: TextInputAction.next,
                  onSubmit: (_) =>
                      FocusScope.of(context).requestFocus(_passFocus),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$')
                        .hasMatch(v.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppTheme.s12),

                // Password field
                TextFormField(
                  controller: _passCtrl,
                  focusNode: _passFocus,
                  obscureText: !_passVis,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signIn(),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: AppTheme.bodyLight
                      .copyWith(color: AppTheme.textPrimary),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (v.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: AppTheme.bodyLight
                        .copyWith(color: AppTheme.textMuted),
                    prefixIcon: const Icon(Icons.lock_outline_rounded,
                        color: AppTheme.textMuted, size: 18),
                    suffixIcon: GestureDetector(
                      onTap: () =>
                          setState(() => _passVis = !_passVis),
                      child: Icon(
                        _passVis
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.textMuted, size: 18,
                      ),
                    ),
                  ),
                ),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _forgotPassword,
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: AppTheme.s8),
                      child: Text('Forgot Password?',
                          style: AppTheme.linkText
                              .copyWith(fontSize: 13)),
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.s16),

                // Sign In button
                PrimaryButton(
                  label: 'Sign In',
                  icon: Icons.login_rounded,
                  isLoading: _loading || auth.isLoading,
                  onPressed: _signIn,
                ),

                const SizedBox(height: AppTheme.s20),
                const OrDivider(),
                const SizedBox(height: AppTheme.s20),

                // Google
                GoogleButton(
                  isLoading: _loading || auth.isLoading,
                  onPressed: _googleSignIn,
                ),

                const SizedBox(height: AppTheme.s32),

                // Info card
                Container(
                  padding: const EdgeInsets.all(AppTheme.s12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius:
                    BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(
                        color: AppTheme.success.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          size: 16, color: AppTheme.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'After verifying your email, sign in here '
                              'to continue from where you left off.',
                          style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.success, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.s20),

                // Go to signup
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Text.rich(TextSpan(
                      style: AppTheme.bodySmall,
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                            text: 'Sign Up',
                            style: AppTheme.linkText
                                .copyWith(fontSize: 13)),
                      ],
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}