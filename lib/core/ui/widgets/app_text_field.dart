import 'package:enterprise_mvvm/core/theme/app_tokens.dart';
import 'package:enterprise_mvvm/core/ui/widgets/app_text.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

InputDecoration buildAppInputDecoration({
  required BuildContext context,
  String? hintText,
  String? errorText,
  Widget? suffixIcon,
  Widget? prefixIcon,
  Color? fillColor,
  EdgeInsetsGeometry? contentPadding,
  double borderRadius = AppRadii.md,
  bool showBorder = true,
}) {
  final scheme = Theme.of(context).colorScheme;
  final radius = BorderRadius.circular(borderRadius);
  final hintStyle = Theme.of(context).textTheme.bodyMedium
      ?.copyWith(color: AppPalette.hint);

  OutlineInputBorder borderFor(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: radius,
      borderSide: showBorder
          ? BorderSide(color: color, width: width)
          : BorderSide.none,
    );
  }

  return InputDecoration(
    errorText: errorText,
    suffixIcon: suffixIcon,
    prefixIcon: prefixIcon,
    hintText: hintText,
    filled: true,
    fillColor: fillColor ?? scheme.surface,
    contentPadding:
        contentPadding ??
        const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
    hintStyle: hintStyle,
    border: borderFor(scheme.outline),
    enabledBorder: borderFor(scheme.outlineVariant),
    focusedBorder: borderFor(scheme.primary, width: 1.4),
    errorBorder: borderFor(scheme.error),
    focusedErrorBorder: borderFor(scheme.error, width: 1.4),
  );
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hintText,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.canReveal = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.prefix,
    this.suffix,
    this.fillColor,
    this.showBorder = true,
    this.requiredMark,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hintText;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final bool canReveal;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? prefix;
  final Widget? suffix;
  final Color? fillColor;
  final bool showBorder;

  /// Drawn when a validator is set, unless this is passed explicitly.
  final bool? requiredMark;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final field = canReveal
        ? _RevealField(field: this)
        : _Input(field: this, obscureText: obscureText, suffix: suffix);
    if (label == null) {
      return field;
    }
    final markRequired = requiredMark ?? validator != null;
    final labelStyle = Theme.of(context).textTheme.titleSmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(child: AppText(label!, style: labelStyle)),
            if (markRequired)
              AppText(
                ' *',
                style: labelStyle?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        field,
      ],
    );
  }
}

class _RevealField extends StatefulWidget {
  const _RevealField({required this.field});

  final AppTextField field;

  @override
  State<_RevealField> createState() => _RevealFieldState();
}

class _RevealFieldState extends State<_RevealField> {
  late bool _obscure = widget.field.obscureText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Input(
      field: widget.field,
      obscureText: _obscure,
      suffix: IconButton(
        tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppPalette.hint,
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.field,
    required this.obscureText,
    required this.suffix,
  });

  final AppTextField field;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: field.controller,
      initialValue: field.controller == null ? field.initialValue : null,
      readOnly: field.readOnly,
      onTap: field.onTap,
      obscureText: obscureText,
      keyboardType: field.keyboardType,
      textInputAction: field.textInputAction,
      maxLines: obscureText ? 1 : field.maxLines,
      autofillHints: field.autofillHints,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: Theme.of(context).textTheme.bodyMedium,
      cursorColor: Theme.of(context).colorScheme.primary,
      onChanged: field.onChanged,
      onFieldSubmitted: field.onSubmitted,
      validator: field.validator,
      decoration: buildAppInputDecoration(
        context: context,
        hintText: field.hintText,
        errorText: field.errorText,
        prefixIcon: field.prefix,
        suffixIcon: suffix,
        fillColor: field.fillColor,
        showBorder: field.showBorder,
      ),
    );
  }
}
