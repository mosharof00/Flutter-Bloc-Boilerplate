import 'dart:async';

import 'package:enterprise_mvvm/core/services/connectivity_service.dart';
import 'package:enterprise_mvvm/core/theme/app_tokens.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({
    super.key,
    required this.connectivity,
    required this.child,
  });

  final ConnectivityService connectivity;
  final Widget child;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  late bool _online = widget.connectivity.isOnline;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.connectivity.onStatusChanged.listen((bool online) {
      if (mounted) {
        setState(() => _online = online);
      }
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: <Widget>[
        if (!_online)
          Material(
            color: scheme.errorContainer,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    AppLocalizations.of(context).offlineBanner,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: scheme.onErrorContainer),
                  ),
                ),
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
