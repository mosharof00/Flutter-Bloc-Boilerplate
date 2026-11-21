import 'package:enterprise_mvvm/app/roles/admin/admin_home_view_model.dart';
import 'package:enterprise_mvvm/app/roles/role_home_screen.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({required this.viewModel, super.key});

  final AdminHomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return RoleHomeScreen(
      title: AppLocalizations.of(context).adminHomeTitle,
      viewModel: viewModel,
    );
  }
}
