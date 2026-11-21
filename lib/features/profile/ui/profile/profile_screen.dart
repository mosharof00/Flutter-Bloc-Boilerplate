import 'dart:async';

import 'package:enterprise_mvvm/core/theme/app_tokens.dart';
import 'package:enterprise_mvvm/core/ui/view_model/view_state.dart';
import 'package:enterprise_mvvm/core/ui/widgets/async_view.dart';
import 'package:enterprise_mvvm/core/ui/widgets/gradient_scaffold.dart';
import 'package:enterprise_mvvm/features/profile/domain/models/profile.dart';
import 'package:enterprise_mvvm/features/profile/ui/profile/profile_view_model.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({required this.viewModel, super.key});

  final ProfileViewModel viewModel;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.viewModel.load());
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).profileTitle)),
      body: BlocBuilder<ProfileViewModel, ViewState<List<Profile>>>(
        bloc: widget.viewModel,
        builder: (BuildContext context, ViewState<List<Profile>> state) {
          return AsyncView<List<Profile>>(
            state: state,
            onRetry: widget.viewModel.load,
            isEmpty: (List<Profile> items) => items.isEmpty,
            onData: (List<Profile> items) {
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: items.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (BuildContext context, int index) {
                  return Text(items[index].title);
                },
              );
            },
          );
        },
      ),
    );
  }
}
