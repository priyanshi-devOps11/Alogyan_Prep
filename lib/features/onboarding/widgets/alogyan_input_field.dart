import 'package:flutter/material.dart';

// Clean absolute path targeting your enterprise design tokens
import 'package:alogyan_prep/core/theme/app_theme.dart';

/// A styled text input field that matches the Alogyan theme spec.
/// Supports password visibility toggle, prefix icons, and real-time validation checks.
class AlogyanInputField extends StatefulWidget {
  const AlogyanInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.focusNode,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;

  @override
  State<AlogyanInputField> createState() => _AlogyanInputFieldState();
}

class _AlogyanInputFieldState extends State<AlogyanInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      style: AppTheme.bodyRegular.copyWith(color: AppTheme.textPrimary),
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: Icon(
          widget.prefixIcon,
          color: AppTheme.textMuted,
          size: 20,
        ),
        suffixIcon: widget.isPassword
            ? GestureDetector(
          onTap: () => setState(() => _obscureText = !_obscureText),
          child: Icon(
            _obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppTheme.textMuted,
            size: 20,
          ),
        )
            : null,
      ),
    );
  }
}