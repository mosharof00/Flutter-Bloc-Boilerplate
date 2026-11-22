import 'dart:async';

import 'package:enterprise_mvvm/app/roles/role_label.dart';
import 'package:enterprise_mvvm/core/access/app_role.dart';
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

class RoleHomeScreen extends StatelessWidget {
  const RoleHomeScreen({
    super.key,
    required this.title,
    required this.viewModel,
  });

  final String title;
  final SessionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<SessionViewModel, Session>(
      bloc: viewModel,
      builder: (BuildContext context, Session session) {
        if (session is! SessionAuthenticated) {
          return const GradientScaffold(body: SizedBox.shrink());
        }
        final next = _nextRole(session);
        return GradientScaffold(
          appBar: AppBar(
            title: Text(title),
            actions: <Widget>[
              IconButton(
                key: const Key('theme_toggle'),
                tooltip: l10n.themeToggle,
                onPressed: () => unawaited(context.read<ThemeCubit>().toggle()),
                icon: const Icon(Icons.brightness_6_outlined),
              ),
              IconButton(
                key: const Key('locale_toggle'),
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
                  key: const Key('display_name'),
                  l10n.signedInAs(session.user.displayName),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  key: const Key('active_role'),
                  l10n.activeRole(roleLabel(l10n, session.activeRole)),
                ),
                const Spacer(),
                if (next != null) ...<Widget>[
                  AppButton(
                    key: const Key('role_switch'),
                    label: l10n.switchToRole(roleLabel(l10n, next)),
                    useGradient: false,
                    onPressed: () => unawaited(viewModel.switchRole(next)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                AppButton(
                  key: const Key('logout'),
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

AppRole? _nextRole(SessionAuthenticated session) {
  if (session.user.roles.length < 2) {
    return null;
  }
  final roles = session.user.roles.toList();
  final index = roles.indexOf(session.activeRole);
  if (index < 0) {
    return roles.first;
  }
  return roles[(index + 1) % roles.length];
}
