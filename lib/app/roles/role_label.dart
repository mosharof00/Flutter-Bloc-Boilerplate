import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';

String roleLabel(AppLocalizations l10n, AppRole role) {
  return switch (role) {
    AppRole.member => l10n.roleMember,
    AppRole.admin => l10n.roleAdmin,
    // GENERATOR: role-labels
  };
}
