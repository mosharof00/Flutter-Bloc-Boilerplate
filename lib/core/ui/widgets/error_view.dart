import 'package:enterprise_mvvm/core/error/failure.dart';
import 'package:enterprise_mvvm/core/error/failure_message.dart';
import 'package:enterprise_mvvm/core/theme/app_tokens.dart';
import 'package:enterprise_mvvm/core/ui/widgets/global_button.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.failure, this.onRetry});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              failureMessage(l10n, failure),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              GlobalButton(
                onPressed: onRetry,
                label: l10n.retry,
                useGradient: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
