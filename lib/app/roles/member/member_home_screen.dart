import 'package:enterprise_mvvm/app/roles/member/member_home_view_model.dart';
import 'package:enterprise_mvvm/app/roles/role_home_screen.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class MemberHomeScreen extends StatelessWidget {
  const MemberHomeScreen({required this.viewModel, super.key});

  final MemberHomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return RoleHomeScreen(
      title: AppLocalizations.of(context).memberHomeTitle,
      viewModel: viewModel,
    );
  }
}
