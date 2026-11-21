import 'package:url_launcher/url_launcher.dart';

final class AppUrlLauncher {
  const AppUrlLauncher();

  /// Opens [raw] outside the app. A missing scheme is treated as https.
  Future<bool> open(String? raw) async {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) {
      return false;
    }
    final parsed = Uri.tryParse(value);
    if (parsed == null) {
      return false;
    }
    final uri = parsed.hasScheme ? parsed : Uri.parse('https://$value');
    try {
      if (!await canLaunchUrl(uri)) {
        return false;
      }
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }
}
