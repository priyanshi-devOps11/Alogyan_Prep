import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/onboarding/controllers/controllers.dart';
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';
import 'package:alogyan_prep/features/onboarding/presentation/screens/login_screen.dart';

class EmailVerifyWaitScreen extends ConsumerStatefulWidget {
  const EmailVerifyWaitScreen({super.key});
  @override
  ConsumerState<EmailVerifyWaitScreen> createState() =>
      _EmailVerifyWaitState();
}

class _EmailVerifyWaitState extends ConsumerState<EmailVerifyWaitScreen>
    with WidgetsBindingObserver {
  Timer? _pollTimer;
  bool _checking  = false;
  bool _canResend = false;
  bool _disposed  = false;
  int  _elapsed   = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
    _startResendCountdown();
  }

  // ── App lifecycle: check immediately when user returns from email ──────────
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_disposed) {
      // User just came back (probably from clicking email link)
      _checkNow();
    }
  }

  // ── Immediate one-shot check ──────────────────────────────────────────────
  Future<void> _checkNow() async {
    if (_disposed || _checking) return;
    if (mounted) setState(() => _checking = true);
    final verified =
    await ref.read(authProvider.notifier).checkEmailVerified();
    if (_disposed || !mounted) return;
    setState(() => _checking = false);
    if (verified) _onVerified();
  }

  void _onVerified() {
    _pollTimer?.cancel();
    if (!mounted || _disposed) return;
    ref.read(flowProvider.notifier).goTo(OnboardingStep.dateOfBirth);
  }

  // ── Background poll every 5s ──────────────────────────────────────────────
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_disposed || !mounted) return;
      if (_checking) return;
      setState(() => _checking = true);
      final verified =
      await ref.read(authProvider.notifier).checkEmailVerified();
      if (_disposed || !mounted) return;
      setState(() => _checking = false);
      if (verified) _onVerified();
    });
  }

  // ── 30s resend countdown ──────────────────────────────────────────────────
  void _startResendCountdown() {
    _elapsed   = 0;
    _canResend = false;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_disposed || !mounted) return false;
      setState(() {
        _elapsed++;
        if (_elapsed >= 30) _canResend = true;
      });
      return mounted && !_canResend && !_disposed;
    });
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    setState(() { _canResend = false; _elapsed = 0; });
    try {
      await ref.read(authRepositoryProvider).sendVerificationEmail();
      if (!mounted) return;
      _showSnack('Verification email resent! Check your inbox.',
          color: AppTheme.success);
      _startResendCountdown();
    } catch (_) {
      if (!mounted) return;
      _showSnack('Could not resend. Please try again.');
    }
  }

  void _showSnack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color ?? AppTheme.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusS)),
    ));
  }

  @override
  void dispose() {
    _disposed = true;
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppTheme.s48),

              // Icon
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.brandRedSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_unread_rounded,
                    size: 50, color: AppTheme.brandRed),
              ),

              const SizedBox(height: AppTheme.s24),

              Text('Verify your email',
                  style: AppTheme.headingLight,
                  textAlign: TextAlign.center),

              const SizedBox(height: AppTheme.s12),

              Text(
                'We sent a link to\n${auth.email ?? 'your email'}',
                style: AppTheme.bodyLight,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppTheme.s4),

              Text(
                '(Check spam/junk folder if not visible)',
                style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textMuted, fontSize: 12),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppTheme.s32),

              // Checking status card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.s16),
                decoration: BoxDecoration(
                  color: AppTheme.bgWhite,
                  borderRadius:
                  BorderRadius.circular(AppTheme.radiusL),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Row(children: [
                  SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _checking
                          ? AppTheme.brandRed
                          : AppTheme.borderLight,
                    ),
                  ),
                  const SizedBox(width: AppTheme.s12),
                  Expanded(
                    child: Text(
                      _checking
                          ? 'Checking verification...'
                          : 'Waiting — checking every 5 seconds',
                      style: AppTheme.bodyLight.copyWith(fontSize: 14),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: AppTheme.s16),

              // Step guide
              Container(
                padding: const EdgeInsets.all(AppTheme.s16),
                decoration: BoxDecoration(
                  color: AppTheme.bgCardAlt,
                  borderRadius:
                  BorderRadius.circular(AppTheme.radiusL),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Step(n: '1', text: 'Open your email app'),
                    const SizedBox(height: AppTheme.s8),
                    _Step(n: '2',
                        text: 'Click the verification link'),
                    const SizedBox(height: AppTheme.s8),
                    _Step(n: '3',
                        text: 'Come back to this app — it auto-advances'),
                  ],
                ),
              ),

              const Spacer(),

              // Primary CTA — Already Verified? Sign In
              SizedBox(
                width: double.infinity, height: 52,
                child: GestureDetector(
                  onTap: () {
                    _pollTimer?.cancel();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.brandRedLight,
                          AppTheme.brandRedDark
                        ],
                      ),
                      borderRadius:
                      BorderRadius.circular(AppTheme.radiusM),
                      boxShadow: AppTheme.buttonShadow,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Already Verified? Sign In',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.s12),

              // Resend
              GestureDetector(
                onTap: _canResend ? _resend : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity, height: 48,
                  decoration: BoxDecoration(
                    color: _canResend
                        ? AppTheme.bgWhite
                        : AppTheme.bgSoft,
                    borderRadius:
                    BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(
                      color: _canResend
                          ? AppTheme.brandRed
                          : AppTheme.borderLight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _canResend
                          ? 'Resend verification email'
                          : 'Resend in ${30 - _elapsed}s',
                      style: AppTheme.labelMedium.copyWith(
                        color: _canResend
                            ? AppTheme.brandRed
                            : AppTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.s12),

              // Skip for testing
              GestureDetector(
                onTap: () => ref
                    .read(flowProvider.notifier)
                    .goTo(OnboardingStep.dateOfBirth),
                child: Text('Skip for now →',
                    style: AppTheme.linkText.copyWith(fontSize: 13)),
              ),

              const SizedBox(height: AppTheme.s32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.n, required this.text});
  final String n, text;
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        color: AppTheme.brandRed,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(n,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
    ),
    const SizedBox(width: 10),
    Expanded(child: Text(text, style: AppTheme.bodyLight.copyWith(fontSize: 14))),
  ]);
}