import 'package:enterprise_mvvm/core/theme/app_tokens.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          AppLocalizations.of(context).emptyTitle,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
