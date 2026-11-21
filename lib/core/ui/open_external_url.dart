import 'package:enterprise_mvvm/core/services/app_url_launcher.dart';
import 'package:enterprise_mvvm/core/ui/widgets/app_messenger.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

Future<void> openExternalUrl(BuildContext context, String? url) async {
  final opened = await const AppUrlLauncher().open(url);
  if (!opened && context.mounted) {
    AppMessenger.show(
      context,
      message: AppLocalizations.of(context).couldNotOpenLink,
      isError: true,
      icon: Icons.link_off,
    );
  }
}
