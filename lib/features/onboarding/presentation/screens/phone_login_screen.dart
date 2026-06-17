import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/onboarding/controllers/controllers.dart';
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';
import 'package:alogyan_prep/features/onboarding/presentation/widgets/widgets.dart';

import 'dart:async';

/// Phone authentication screen.
/// Supports Firebase Phone Auth with predefined test numbers.
///
/// Firebase Console setup:
/// Authentication → Sign-in method → Phone → Phone numbers for testing
/// Add: +91XXXXXXXXXX  →  OTP: 123456  (your predefined test pair)
class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});
  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

// ── DEV TEST CREDENTIALS ────────────────────────────────────────────────────
// Must match EXACTLY what's added in:
// Firebase Console → Authentication → Sign-in method → Phone →
// "Phone numbers for testing (skip App Verification)"
// When this number+OTP pair is used, Firebase resolves locally —
// no SMS gateway is hit, so BILLING_NOT_ENABLED never triggers.
const String _kTestPhoneNumber = '8081438778'; // without +91, matches our 10-digit input field
const String _kTestOtp         = '123456';
// ─────────────────────────────────────────────────────────────────────────

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneCtrl = TextEditingController(text: _kTestPhoneNumber);
  final _otpCtrl   = TextEditingController();

  bool _otpSent   = false;
  bool _loading   = false;
  String? _verificationId;
  int _elapsed    = 0;
  bool _canResend = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _resendTimer?.cancel(); // ← add this
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final raw = _phoneCtrl.text.trim();
    if (raw.length != 10) {
      _snack('Enter a valid 10-digit mobile number', error: true);
      return;
    }
    final phone = '+91$raw';
    FocusScope.of(context).unfocus();
    setState(() { _loading = true; });

    await ref.read(authProvider.notifier).sendPhoneOtp(
      phoneNumber: phone,
      onCodeSent: (vid) {
        if (!mounted) return;
        setState(() {
          _verificationId = vid;
          _otpSent  = true;
          _loading  = false;
          _elapsed  = 0;
          _canResend = false;
        });
        _startResendTimer();
        _snack('OTP sent to $phone');
      },
      onError: (err) {
        if (!mounted) return;
        setState(() => _loading = false);
        _snack(err, error: true);
      },
    );
  }

  // Add to _PhoneLoginScreenState fields:
  Timer? _resendTimer;
  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() { _elapsed = 0; _canResend = false; });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _elapsed++;
        if (_elapsed >= 30) {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }
  Future<void> _verifyOtp() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length != 6) {
      _snack('Enter the 6-digit OTP', error: true);
      return;
    }
    if (_verificationId == null) {
      _snack('Session expired. Please request OTP again.', error: true);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    final ok = await ref.read(authProvider.notifier).verifyPhoneOtp(
      verificationId: _verificationId!,
      smsCode: otp,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      // AuthNotifier already called goTo(dateOfBirth) + set authenticated.
      // _AuthGate handles routing. Just close this screen back to root.
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      final err = ref.read(authProvider).errorMessage;
      _snack(err ?? 'OTP verification failed. Please try again.', error: true);
      ref.read(authProvider.notifier).clearError();
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: AppTheme.s24, right: AppTheme.s24,
            top: AppTheme.s20,
            bottom: MediaQuery.viewInsetsOf(context).bottom + AppTheme.s24,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Back
            GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppTheme.bgWhite,
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: AppTheme.cardShadow),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: AppTheme.textPrimary))),
            const SizedBox(height: AppTheme.s32),

            // Icon
            Center(child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: AppTheme.brandRedSurface, shape: BoxShape.circle),
                child: const Icon(Icons.phone_iphone_rounded, size: 40, color: AppTheme.brandRed))),
            const SizedBox(height: AppTheme.s24),

            Text(_otpSent ? 'Enter OTP' : 'Login with\nPhone Number',
                style: AppTheme.displayLight),
            const SizedBox(height: AppTheme.s8),
            Text(
              _otpSent
                  ? 'Enter the 6-digit OTP sent to +91 ${_phoneCtrl.text.trim()}'
                  : 'We\'ll send a one-time password to verify your number.',
              style: AppTheme.bodyLight,
            ),
            const SizedBox(height: AppTheme.s32),

            if (!_otpSent) ...[
              // Phone number input
              Row(children: [
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(color: AppTheme.bgWhite,
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        border: Border.all(color: AppTheme.borderLight)),
                    child: Text('+91', style: AppTheme.bodyLight.copyWith(
                        color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                const SizedBox(width: AppTheme.s8),
                Expanded(child: TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    style: AppTheme.bodyLight.copyWith(color: AppTheme.textPrimary),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _sendOtp(),
                    decoration: InputDecoration(
                        hintText: '10-digit mobile number',
                        hintStyle: AppTheme.bodyLight.copyWith(color: AppTheme.textMuted),
                        counterText: '',
                        filled: true, fillColor: AppTheme.bgWhite,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.s16, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            borderSide: const BorderSide(color: AppTheme.borderLight)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            borderSide: const BorderSide(color: AppTheme.brandRed, width: 1.5)))))]),
              const SizedBox(height: AppTheme.s32),
              PrimaryButton(label: 'Send OTP', icon: Icons.send_rounded,
                  isLoading: _loading, onPressed: _sendOtp),

            ] else ...[
              // OTP input
              Center(child: SizedBox(
                  width: 240,
                  child: TextField(
                      controller: _otpCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: AppTheme.displayLight.copyWith(fontSize: 26, letterSpacing: 10),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _verifyOtp(),
                      decoration: InputDecoration(
                          hintText: '— — — — — —',
                          hintStyle: AppTheme.displayLight.copyWith(
                              fontSize: 20, letterSpacing: 6, color: AppTheme.borderLight),
                          counterText: '',
                          filled: true, fillColor: AppTheme.bgWhite,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.s16, vertical: 18),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusM),
                              borderSide: const BorderSide(color: AppTheme.borderLight)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusM),
                              borderSide: const BorderSide(color: AppTheme.brandRed, width: 1.5)))))),

              const SizedBox(height: AppTheme.s20),

              // Resend row
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Didn\'t receive it? ', style: AppTheme.bodySmall),
                GestureDetector(
                    onTap: _canResend ? () { setState(() { _otpSent = false; _otpCtrl.clear(); }); } : null,
                    child: Text(
                        _canResend ? 'Resend OTP' : 'Resend in ${30 - _elapsed}s',
                        style: AppTheme.linkText.copyWith(
                            fontSize: 13,
                            color: _canResend ? AppTheme.brandRed : AppTheme.textMuted))),
              ]),

              const SizedBox(height: AppTheme.s24),
              PrimaryButton(label: 'Verify OTP', icon: Icons.verified_rounded,
                  isLoading: _loading, onPressed: _verifyOtp),
            ],

            const SizedBox(height: AppTheme.s24),

            // Developer test info card
            Container(
                padding: const EdgeInsets.all(AppTheme.s12),
                decoration: BoxDecoration(color: AppTheme.bgCardAlt,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: Color(0xFF6366F1)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                      'Test mode: +91 $_kTestPhoneNumber → OTP is always $_kTestOtp. '
                          'This pair is registered in Firebase Console → Authentication → '
                          'Sign-in method → Phone → Phone numbers for testing — '
                          'so no real SMS is sent and no billing is required.',
                      style: AppTheme.bodySmall.copyWith(
                          color: const Color(0xFF6366F1), fontSize: 12))),
                ])),
          ]),
        ),
      ),
    );
  }
}