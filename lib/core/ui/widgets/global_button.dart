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
    this.prefix,
    this.suffix,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final bool useGradient;
  final Widget? prefix;
  final Widget? suffix;

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
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (prefix != null) ...<Widget>[
                      prefix!,
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: enabled
                              ? scheme.onPrimary
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (suffix != null) ...<Widget>[
                      const SizedBox(width: AppSpacing.sm),
                      suffix!,
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
