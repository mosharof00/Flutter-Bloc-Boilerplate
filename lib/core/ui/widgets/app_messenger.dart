import 'package:enterprise_mvvm/core/theme/app_tokens.dart';
import 'package:enterprise_mvvm/core/ui/widgets/app_text.dart';
import 'package:flutter/material.dart';

abstract final class AppMessenger {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    IconData? icon,
    bool isError = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final background = isError ? scheme.error : scheme.inverseSurface;
    final foreground = isError ? scheme.onError : scheme.onInverseSurface;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          content: Row(
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, color: foreground, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (title != null)
                      AppText(
                        title,
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(color: foreground),
                      ),
                    AppText(
                      message,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: foreground),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
}
