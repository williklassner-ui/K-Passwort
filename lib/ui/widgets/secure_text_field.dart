import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';

/// Text field that prevents screenshots via semantic exclusion
/// and never enters autocorrect/autofill for sensitive fields.
class SecureTextField extends StatefulWidget {
  const SecureTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.isPassword = false,
    this.isMonospace = false,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.autofocus = false,
    this.maxLength,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool isPassword;
  final bool isMonospace;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final int? maxLength;
  final bool enabled;

  @override
  State<SecureTextField> createState() => _SecureTextFieldState();
}

class _SecureTextFieldState extends State<SecureTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.isMonospace
        ? AppTypography.passwordMedium.copyWith(color: KPasswortColors.onBackground)
        : null;

    return ExcludeSemantics(
      excluding: widget.isPassword,
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword && _obscure,
        enableSuggestions: false,
        autocorrect: false,
        autofocus: widget.autofocus,
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        maxLength: widget.maxLength,
        style: textStyle,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          counterText: '',
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: KPasswortColors.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
        ),
      ),
    );
  }
}
