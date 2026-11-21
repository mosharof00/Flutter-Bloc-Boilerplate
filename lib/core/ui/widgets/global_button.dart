import 'package:enterprise_mvvm/core/theme/app_gradients.dart';
import 'package:enterprise_mvvm/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

class GlobalButton extends StatelessWidget {
  const GlobalButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.useGradient = true,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final bool useGradient;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null && !isLoading;
    final gradient = Theme.of(context).extension<AppGradients>()?.brand;
    final radius = BorderRadius.circular(AppRadii.md);
    return SizedBox(
      height: AppSpacing.xxl,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: enabled && useGradient ? gradient : null,
          color: enabled && (gradient == null || !useGradient)
              ? scheme.primary
              : enabled
              ? null
              : scheme.surfaceContainerHighest,
        ),
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPalette.transparent,
            shadowColor: AppPalette.transparent,
            disabledBackgroundColor: AppPalette.transparent,
            foregroundColor: scheme.onPrimary,
            disabledForegroundColor: scheme.onSurfaceVariant,
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: isLoading
              ? SizedBox(
                  height: AppSpacing.lg,
                  width: AppSpacing.lg,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.onPrimary,
                  ),
                )
              : Text(label),
        ),
      ),
    );
  }
}
