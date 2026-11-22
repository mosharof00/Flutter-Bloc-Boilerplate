import 'dart:async';

import 'package:enterprise_mvvm/app/roles/role_label.dart';
import 'package:enterprise_mvvm/core/session/session.dart';
import 'package:enterprise_mvvm/core/theme/app_tokens.dart';
import 'package:enterprise_mvvm/core/theme/locale_cubit.dart';
import 'package:enterprise_mvvm/core/theme/theme_cubit.dart';
import 'package:enterprise_mvvm/core/ui/widgets/app_button.dart';
import 'package:enterprise_mvvm/core/ui/widgets/gradient_scaffold.dart';
import 'package:enterprise_mvvm/features/auth/ui/session/session_view_model.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.viewModel, super.key});

  final SessionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<SessionViewModel, Session>(
      bloc: viewModel,
      builder: (BuildContext context, Session session) {
        if (session is! SessionAuthenticated) {
          return GradientScaffold(
            appBar: AppBar(title: Text(l10n.profileTitle)),
            body: const SizedBox.shrink(),
          );
        }
        return GradientScaffold(
          appBar: AppBar(
            title: Text(l10n.profileTitle),
            actions: <Widget>[
              IconButton(
                key: const Key('profile_theme_toggle'),
                tooltip: l10n.themeToggle,
                onPressed: () => unawaited(context.read<ThemeCubit>().toggle()),
                icon: const Icon(Icons.brightness_6_outlined),
              ),
              IconButton(
                key: const Key('profile_locale_toggle'),
                tooltip: l10n.languageToggle,
                onPressed: () =>
                    unawaited(context.read<LocaleCubit>().toggle()),
                icon: const Icon(Icons.language),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  key: const Key('profile_display_name'),
                  session.user.displayName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  key: const Key('profile_active_role'),
                  l10n.activeRole(roleLabel(l10n, session.activeRole)),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                AppButton(
                  key: const Key('profile_logout'),
                  label: l10n.logoutAction,
                  onPressed: () => unawaited(viewModel.logout()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
