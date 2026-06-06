import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Absolute package structure mapping your direct workspace architecture
import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';
import 'package:alogyan_prep/features/onboarding/controllers/auth_controller.dart';
import 'package:alogyan_prep/features/onboarding/widgets/alogyan_input_field.dart';
import 'package:alogyan_prep/features/onboarding/widgets/primary_button.dart';

/// Login & Register screen — smoothly transitions from onboarding.
/// Handles sign-in, registration, and forgot-password flows.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _nameFocus = FocusNode();

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  // ── Submit Logic ───────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final mode = ref.read(authModeProvider);
    final notifier = ref.read(authProvider.notifier);

    if (mode == AuthMode.login) {
      await notifier.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      await notifier.register(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _nameController.text,
      );
    }
  }

  // ── Error SnackBar Handler ─────────────────────────────────────────────────

  void _handleAuthState(AuthState state) {
    if (state.status == AuthStatus.error && state.errorMessage != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: AppTheme.textError, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    state.errorMessage!,
                    style: AppTheme.bodyRegular.copyWith(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      ref.read(authProvider.notifier).clearError();
    }
  }

  // ── Forgot Password Bottom Sheet ───────────────────────────────────────────

  Future<void> _showForgotPassword() async {
    final emailController = TextEditingController();
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.spacingL),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppTheme.spacingL,
          right: AppTheme.spacingL,
          top: AppTheme.spacingL,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + AppTheme.spacingXL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reset Password', style: AppTheme.headingMedium),
            const SizedBox(height: 8),
            Text(
              'Enter your registered email to receive a password reset link.',
              style: AppTheme.bodyRegular.copyWith(fontSize: 13),
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: AppTheme.inputText,
              decoration: InputDecoration(
                hintText: 'Your email address',
                hintStyle: AppTheme.inputHint,
                prefixIcon: const Icon(Icons.mail_outline_rounded,
                    color: AppTheme.textMuted, size: 20),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            PrimaryButton(
              label: 'Send Reset Link',
              onPressed: () => Navigator.pop(ctx, emailController.text),
            ),
          ],
        ),
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      final sent =
      await ref.read(authProvider.notifier).sendPasswordReset(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sent
                  ? 'Reset link sent! Check your inbox.'
                  : 'Could not send reset link. Check the email address.',
              style: AppTheme.bodyRegular.copyWith(fontSize: 13),
            ),
          ),
        );
      }
    }
  }

  // ── Toggle Auth Mode ───────────────────────────────────────────────────────

  void _toggleMode() {
    ref.read(authModeProvider.notifier).state =
    ref.read(authModeProvider) == AuthMode.login
        ? AuthMode.register
        : AuthMode.login;
    _formKey.currentState?.reset();
    _fadeController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final mode = ref.watch(authModeProvider);
    final isLogin = mode == AuthMode.login;
    final isLoading = authState.status == AuthStatus.loading;

    // Listen for state and trigger error logs cleanly
    ref.listen<AuthState>(authProvider, (_, next) => _handleAuthState(next));

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      body: Stack(
        children: [
          // Background radial glow layout element
          Positioned(
            top: -100,
            left: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.brandOrange.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main contents
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingL,
                  vertical: AppTheme.spacingXL,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Logo Header ────────────────────────────────────
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.brandOrange,
                                  borderRadius:
                                  BorderRadius.circular(AppTheme.radiusS),
                                ),
                                child: const Icon(Icons.school_rounded,
                                    color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Alogyan',
                                style: AppTheme.titleMedium.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppTheme.spacingXL),

                          // ── Dynamic Form Headings ──────────────────────────
                          Text(
                            isLogin ? 'Welcome\nBack 👋' : 'Create\nAccount',
                            style: AppTheme.displayLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isLogin
                                ? 'Sign in to continue your exam prep journey.'
                                : 'Join thousands of students preparing smarter.',
                            style: AppTheme.bodyRegular,
                          ),

                          const SizedBox(height: AppTheme.spacingXL),

                          // ── Registration Name Field ────────────────────────
                          if (!isLogin) ...[
                            AlogyanInputField(
                              controller: _nameController,
                              hintText: 'Your full name',
                              prefixIcon: Icons.person_outline_rounded,
                              focusNode: _nameFocus,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) =>
                                  FocusScope.of(context).requestFocus(_emailFocus),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Please enter your name';
                                }
                                if (v.trim().length < 2) {
                                  return 'Name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppTheme.spacingS),
                          ],

                          // ── Email Input Field ──────────────────────────────
                          AlogyanInputField(
                            controller: _emailController,
                            hintText: 'Email address',
                            prefixIcon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            focusNode: _emailFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                FocusScope.of(context).requestFocus(_passwordFocus),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              final emailRegex = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                              if (!emailRegex.hasMatch(v.trim())) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppTheme.spacingS),

                          // ── Password Input Field ───────────────────────────
                          AlogyanInputField(
                            controller: _passwordController,
                            hintText: 'Password',
                            prefixIcon: Icons.lock_outline_rounded,
                            isPassword: true,
                            focusNode: _passwordFocus,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (v.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          // ── Forgot Password Module ─────────────────────────
                          if (isLogin) ...[
                            const SizedBox(height: AppTheme.spacingS),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _showForgotPassword,
                                child: Text('Forgot password?',
                                    style: AppTheme.linkText),
                              ),
                            ),
                          ],

                          const SizedBox(height: AppTheme.spacingXL),

                          // ── Main CTA Primary Button ────────────────────────
                          PrimaryButton(
                            label: isLogin ? 'Sign In' : 'Create Account',
                            onPressed: _submit,
                            isLoading: isLoading,
                          ),

                          const SizedBox(height: AppTheme.spacingL),

                          // ── Visual Center Text Divider ─────────────────────
                          Row(
                            children: [
                              const Expanded(
                                  child: Divider(color: AppTheme.borderDefault)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('or',
                                    style: AppTheme.bodyRegular
                                        .copyWith(color: AppTheme.textMuted)),
                              ),
                              const Expanded(
                                  child: Divider(color: AppTheme.borderDefault)),
                            ],
                          ),

                          const SizedBox(height: AppTheme.spacingL),

                          // ── Toggle Auth Mode Interface ─────────────────────
                          Center(
                            child: GestureDetector(
                              onTap: _toggleMode,
                              child: RichText(
                                text: TextSpan(
                                  style: AppTheme.bodyRegular,
                                  children: [
                                    TextSpan(
                                      text: isLogin
                                          ? "Don't have an account? "
                                          : 'Already have an account? ',
                                    ),
                                    TextSpan(
                                      text: isLogin ? 'Sign Up' : 'Sign In',
                                      style: AppTheme.linkText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Full-screen structural block barrier during load state
          if (isLoading)
            const ModalBarrier(
              dismissible: false,
              color: Colors.transparent,
            ),
        ],
      ),
    );
  }
}