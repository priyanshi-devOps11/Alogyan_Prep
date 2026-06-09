import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';
import 'package:alogyan_prep/features/onboarding/controllers/controllers.dart';
import 'package:alogyan_prep/features/onboarding/presentation/widgets/widgets.dart';

/// Phone number login screen.
/// Uses Firebase Phone Auth — your predefined test number + OTP set in
/// Firebase Console → Authentication → Sign-in method → Phone →
/// Phone numbers for testing section.
class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});
  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl   = TextEditingController();
  String? _verificationId;
  bool _otpSent = false;
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = '+91${_phoneCtrl.text.trim()}';
    if (_phoneCtrl.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Enter a valid 10-digit mobile number'),
        backgroundColor: AppTheme.error,
      ));
      return;
    }

    setState(() => _loading = true);
    FocusScope.of(context).unfocus();

    await ref.read(authProvider.notifier).sendPhoneOtp(
      phoneNumber: phone,
      onCodeSent: (vid) {
        setState(() {
          _verificationId = vid;
          _otpSent = true;
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('OTP sent to your phone!'),
          backgroundColor: AppTheme.success,
        ));
      },
      onError: (err) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(err), backgroundColor: AppTheme.error));
      },
    );
  }

  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Enter the 6-digit OTP'),
        backgroundColor: AppTheme.error,
      ));
      return;
    }
    setState(() => _loading = true);
    FocusScope.of(context).unfocus();

    final ok = await ref.read(authProvider.notifier).verifyPhoneOtp(
      verificationId: _verificationId!,
      smsCode: _otpCtrl.text.trim(),
    );

    setState(() => _loading = false);

    if (ok && mounted) {
      // Phone auth successful → go to onboarding name step
      ref.read(flowProvider.notifier).goTo(OnboardingStep.name);
    } else if (mounted) {
      final err = ref.read(authProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err ?? 'OTP verification failed'),
        backgroundColor: AppTheme.error,
      ));
      ref.read(authProvider.notifier).clearError();
    }
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
            // Back button
            GestureDetector(

              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.bgWhite,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  border: Border.all(color: AppTheme.borderLight),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: AppTheme.textPrimary),
              ),
            ),

            const SizedBox(height: AppTheme.s32),

            // Phone illustration
            Center(child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                  color: AppTheme.brandRedSurface, shape: BoxShape.circle),
              child: const Icon(Icons.phone_iphone_rounded,
                  size: 40, color: AppTheme.brandRed),
            )),

            const SizedBox(height: AppTheme.s24),

            Text(
              _otpSent ? 'Enter the OTP' : 'Login with\nPhone Number',
              style: AppTheme.displayLight,
            ),
            const SizedBox(height: AppTheme.s8),
            Text(
              _otpSent
                  ? 'Enter the 6-digit OTP sent to +91 ${_phoneCtrl.text}'
                  : 'We\'ll send a one-time password to your mobile number.',
              style: AppTheme.bodyLight,
            ),

            const SizedBox(height: AppTheme.s32),

            if (!_otpSent) ...[
              // Phone number field
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.bgWhite,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Text('+91',
                      style: AppTheme.bodyLight.copyWith(
                          color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                ),
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
                        borderSide: const BorderSide(color: AppTheme.brandRed, width: 1.5)),
                  ),
                )),
              ]),

              const SizedBox(height: AppTheme.s32),
              PrimaryButton(
                label: 'Send OTP',
                icon: Icons.send_rounded,
                isLoading: _loading,
                onPressed: _sendOtp,
              ),

            ] else ...[
              // OTP field
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: AppTheme.displayLight.copyWith(
                    fontSize: 28, letterSpacing: 12),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _verifyOtp(),
                decoration: InputDecoration(
                  hintText: '------',
                  hintStyle: AppTheme.displayLight.copyWith(
                      fontSize: 28, letterSpacing: 12,
                      color: AppTheme.borderLight),
                  counterText: '',
                  filled: true, fillColor: AppTheme.bgWhite,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.s16, vertical: 18),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      borderSide: const BorderSide(color: AppTheme.borderLight)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      borderSide: const BorderSide(color: AppTheme.brandRed, width: 1.5)),
                ),
              ),

              const SizedBox(height: AppTheme.s20),

              // Resend
              Center(child: GestureDetector(
                onTap: () => setState(() { _otpSent = false; _otpCtrl.clear(); }),
                child: Text('Wrong number? Change it',
                    style: AppTheme.linkText.copyWith(fontSize: 13)),
              )),

              const SizedBox(height: AppTheme.s32),
              PrimaryButton(
                label: 'Verify OTP',
                icon: Icons.verified_rounded,
                isLoading: _loading,
                onPressed: _verifyOtp,
              ),
            ],

            const SizedBox(height: AppTheme.s24),

            // Info note
            Container(
              padding: const EdgeInsets.all(AppTheme.s12),
              decoration: BoxDecoration(
                color: AppTheme.bgCardAlt,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: Color(0xFF6366F1)),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  'Test mode: Use the predefined phone number and OTP set in Firebase Console → Authentication → Sign-in method → Phone → Test phone numbers.',
                  style: AppTheme.bodySmall.copyWith(
                      color: const Color(0xFF6366F1), fontSize: 12),
                )),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}