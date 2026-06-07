import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dot Indicator (used on dark splash slides)
// ─────────────────────────────────────────────────────────────────────────────
class PageDotIndicator extends StatelessWidget {
  const PageDotIndicator({super.key, required this.total, required this.current});
  final int total, current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i == current;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedContainer(
            duration: AppTheme.dotAnimDuration,
            curve: AppTheme.dotAnimCurve,
            width: active ? AppTheme.dotWidthActive : AppTheme.dotWidthInactive,
            height: AppTheme.dotHeight,
            decoration: BoxDecoration(
              color: active ? AppTheme.dotActive : AppTheme.dotInactive,
              borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step Progress Header (used on light profile steps)
// ─────────────────────────────────────────────────────────────────────────────
class StepHeader extends StatelessWidget {
  const StepHeader({super.key, required this.onBack,
    this.fraction, this.progress = 0.0, this.onSkip});
  final VoidCallback onBack;
  final String? fraction;
  final double progress;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppTheme.bgWhite,
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: AppTheme.cardShadow,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppTheme.textPrimary),
            ),
          ),
          const Spacer(),
          if (fraction != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.brandRedSurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
              ),
              child: Text(fraction!, style: AppTheme.stepLabel.copyWith(color: AppTheme.brandRed)),
            ),
          if (onSkip != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSkip,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.bgWhite,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Text('Skip', style: AppTheme.stepLabel),
              ),
            ),
          ],
        ]),
        const SizedBox(height: AppTheme.s12),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
          child: LinearProgressIndicator(
            value: progress, minHeight: 4,
            backgroundColor: AppTheme.borderLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.brandRed),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primary Button
// ─────────────────────────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed,
    this.isLoading = false, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: GestureDetector(
        onTap: (isLoading || onPressed == null) ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: (isLoading || onPressed == null)
                ? LinearGradient(colors: [
              AppTheme.brandRedDark.withValues(alpha: 0.5),
              AppTheme.brandRedDark.withValues(alpha: 0.5)])
                : const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [AppTheme.brandRedLight, AppTheme.brandRedDark]),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            boxShadow: (isLoading || onPressed == null) ? [] : AppTheme.buttonShadow,
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white)))
                : Row(mainAxisSize: MainAxisSize.min, children: [
              Text(label, style: AppTheme.buttonLabel),
              if (icon != null) ...[const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 18)],
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Google Sign-In Button
// ─────────────────────────────────────────────────────────────────────────────
class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, required this.onPressed, this.isLoading = false});
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.bgWhite,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(color: AppTheme.borderLight),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            isLoading
                ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppTheme.brandRed)))
                : Image.asset('assets/icons/google_logo.png', width: 22, height: 22,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.g_mobiledata_rounded, color: Color(0xFF4285F4), size: 28)),
            const SizedBox(width: 10),
            Text('Continue with Google',
                style: AppTheme.labelMedium.copyWith(fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Text Input Field
// ─────────────────────────────────────────────────────────────────────────────
class AlogyanField extends StatefulWidget {
  const AlogyanField({super.key, required this.controller, required this.hint,
    this.isPassword = false, this.keyboardType = TextInputType.text,
    this.validator, this.action = TextInputAction.next,
    this.onSubmit, this.focusNode, this.prefix, this.suffix});
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction action;
  final void Function(String)? onSubmit;
  final FocusNode? focusNode;
  final IconData? prefix;
  final Widget? suffix;

  @override State<AlogyanField> createState() => _AlogyanFieldState();
}
class _AlogyanFieldState extends State<AlogyanField> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller, focusNode: widget.focusNode,
    obscureText: widget.isPassword && _obscure,
    keyboardType: widget.keyboardType, textInputAction: widget.action,
    onFieldSubmitted: widget.onSubmit,
    style: AppTheme.bodyLight.copyWith(color: AppTheme.textPrimary),
    validator: widget.validator,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    decoration: InputDecoration(
      hintText: widget.hint,
      prefixIcon: widget.prefix != null
          ? Icon(widget.prefix, color: AppTheme.textMuted, size: 18) : null,
      suffixIcon: widget.isPassword
          ? GestureDetector(
          onTap: () => setState(() => _obscure = !_obscure),
          child: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppTheme.textMuted, size: 18))
          : widget.suffix,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Selectable Option Card
// ─────────────────────────────────────────────────────────────────────────────
class OptionCard extends StatelessWidget {
  const OptionCard({super.key, required this.label, required this.isSelected,
    required this.onTap, this.emoji});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.brandRedSurface : AppTheme.bgWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
              color: isSelected ? AppTheme.brandRed : AppTheme.borderLight,
              width: isSelected ? 1.5 : 1),
          boxShadow: isSelected ? [] : AppTheme.cardShadow,
        ),
        child: Row(children: [
          if (emoji != null) Text(emoji!, style: const TextStyle(fontSize: 18)),
          if (emoji != null) const SizedBox(width: 8),
          Expanded(child: Text(label,
              style: AppTheme.labelMedium.copyWith(
                  color: isSelected ? AppTheme.brandRed : AppTheme.textPrimary))),
          if (isSelected)
            const Icon(Icons.check_circle_rounded, color: AppTheme.brandRed, size: 18),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Illustration Image with fallback
// ─────────────────────────────────────────────────────────────────────────────
class IllustrationImage extends StatelessWidget {
  const IllustrationImage({super.key, required this.asset, this.height = 220});
  final String asset;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height, width: double.infinity,
      child: Image.asset(asset, fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [AppTheme.brandRedSurface, AppTheme.bgCardAlt]),
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          ),
          child: Center(child: Icon(Icons.school_rounded, size: 64,
              color: AppTheme.brandRed.withValues(alpha: 0.3))),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OR Divider
// ─────────────────────────────────────────────────────────────────────────────
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
    const Expanded(child: Divider(color: AppTheme.borderLight)),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('or', style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted))),
    const Expanded(child: Divider(color: AppTheme.borderLight)),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// Brand Row (logo + name)
// ─────────────────────────────────────────────────────────────────────────────
class BrandRow extends StatelessWidget {
  const BrandRow({super.key, this.dark = false});
  final bool dark;
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 38, height: 38,
        decoration: BoxDecoration(color: AppTheme.brandRed,
            borderRadius: BorderRadius.circular(AppTheme.radiusS)),
        child: const Icon(Icons.school_rounded, color: Colors.white, size: 20)),
    const SizedBox(width: 8),
    Text('Alogyan', style: AppTheme.labelMedium.copyWith(
        fontSize: 17, fontWeight: FontWeight.w700,
        color: dark ? AppTheme.textOnDark : AppTheme.textPrimary)),
  ]);
}