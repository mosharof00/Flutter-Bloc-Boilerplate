import 'package:enterprise_mvvm/app/roles/role_home_screen.dart';
import 'package:enterprise_mvvm/app/roles/user/user_home_view_model.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({required this.viewModel, super.key});

  final UserHomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return RoleHomeScreen(
      title: AppLocalizations.of(context).userHomeTitle,
      viewModel: viewModel,
    );
  }
}
