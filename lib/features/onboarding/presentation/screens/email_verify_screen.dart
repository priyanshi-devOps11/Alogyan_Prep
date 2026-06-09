import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/onboarding/controllers/controllers.dart';

/// Shown after successful registration.
/// Polls Firebase every 3 seconds to check if email is verified.
/// Once verified → proceeds to next onboarding step.
class EmailVerifyWaitScreen extends ConsumerStatefulWidget {
  const EmailVerifyWaitScreen({super.key});
  @override
  ConsumerState<EmailVerifyWaitScreen> createState() => _EmailVerifyWaitState();
}

class _EmailVerifyWaitState extends ConsumerState<EmailVerifyWaitScreen> {
  Timer? _timer;
  bool _checking = false;
  int _seconds = 0;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
    // Allow resend after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) setState(() => _canResend = true);
    });
    // Countdown timer for UI
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _seconds++);
    });
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_checking) return;
      setState(() => _checking = true);
      final verified = await ref.read(authProvider.notifier).checkEmailVerified();
      if (mounted) setState(() => _checking = false);
      if (verified && mounted) {
        _timer?.cancel();
        // Proceed to next step
        ref.read(flowProvider.notifier).next();
      }
    });
  }

  Future<void> _resend() async {
    setState(() => _canResend = false);
    await ref.read(authRepositoryProvider).sendVerificationEmail();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Verification email resent! Check your inbox.'),
        backgroundColor: AppTheme.success,
      ));
      // Re-enable after 30s
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted) setState(() => _canResend = true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppTheme.s40),

              // Envelope animation
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.brandRedSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_unread_rounded,
                    size: 50, color: AppTheme.brandRed),
              ),

              const SizedBox(height: AppTheme.s32),

              Text('Verify your email',
                  style: AppTheme.headingLight, textAlign: TextAlign.center),
              const SizedBox(height: AppTheme.s12),
              Text(
                'We sent a verification link to\n${auth.email ?? ''}',
                style: AppTheme.bodyLight,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppTheme.s32),

              // Checking indicator
              Container(
                padding: const EdgeInsets.all(AppTheme.s16),
                decoration: BoxDecoration(
                  color: AppTheme.bgWhite,
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Row(children: [
                  SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _checking ? AppTheme.brandRed : AppTheme.borderLight,
                    ),
                  ),
                  const SizedBox(width: AppTheme.s12),
                  Text(
                    _checking
                        ? 'Checking verification...'
                        : 'Waiting for you to click the link...',
                    style: AppTheme.bodyLight,
                  ),
                ]),
              ),

              const SizedBox(height: AppTheme.s24),

              Text(
                'Open your email app and click the verification link.\nThis page will automatically proceed.',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Resend button
              GestureDetector(
                onTap: _canResend ? _resend : null,
                child: Container(
                  width: double.infinity, height: 50,
                  decoration: BoxDecoration(
                    color: _canResend ? AppTheme.bgWhite : AppTheme.bgSoft,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(
                      color: _canResend ? AppTheme.brandRed : AppTheme.borderLight,
                    ),
                  ),
                  child: Center(child: Text(
                    _canResend ? 'Resend verification email' : 'Resend available in ${30 - _seconds}s',
                    style: AppTheme.labelMedium.copyWith(
                      color: _canResend ? AppTheme.brandRed : AppTheme.textMuted,
                    ),
                  )),
                ),
              ),

              const SizedBox(height: AppTheme.s12),

              // Skip verification (for testing / phone users)
              GestureDetector(
                onTap: () => ref.read(flowProvider.notifier).next(),
                child: Text('Skip for now →',
                    style: AppTheme.linkText.copyWith(fontSize: 13)),
              ),

              const SizedBox(height: AppTheme.s24),
            ],
          ),
        ),
      ),
    );
  }
}