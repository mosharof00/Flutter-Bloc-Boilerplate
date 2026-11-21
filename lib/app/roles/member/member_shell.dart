import 'dart:async';

import 'package:enterprise_mvvm/app/app_scope.dart';
import 'package:enterprise_mvvm/app/roles/member/member_home_screen.dart';
import 'package:enterprise_mvvm/app/roles/member/member_home_view_model.dart';
import 'package:flutter/material.dart';

class MemberShell extends StatefulWidget {
  const MemberShell({super.key});

  @override
  State<MemberShell> createState() => _MemberShellState();
}

class _MemberShellState extends State<MemberShell> {
  MemberHomeViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dependencies = AppScope.of(context);
    _viewModel ??= MemberHomeViewModel(
      sessionRepository: dependencies.sessionRepository,
      authRepository: dependencies.authRepository,
    );
  }

  @override
  void dispose() {
    final viewModel = _viewModel;
    if (viewModel != null) {
      unawaited(viewModel.close());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel;
    if (viewModel == null) {
      return const SizedBox.shrink();
    }
    return MemberHomeScreen(viewModel: viewModel);
  }
}
