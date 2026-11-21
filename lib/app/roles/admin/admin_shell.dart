import 'dart:async';

import 'package:enterprise_mvvm/app/app_scope.dart';
import 'package:enterprise_mvvm/app/roles/admin/admin_home_screen.dart';
import 'package:enterprise_mvvm/app/roles/admin/admin_home_view_model.dart';
import 'package:flutter/material.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  AdminHomeViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dependencies = AppScope.of(context);
    _viewModel ??= AdminHomeViewModel(
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
    return AdminHomeScreen(viewModel: viewModel);
  }
}
