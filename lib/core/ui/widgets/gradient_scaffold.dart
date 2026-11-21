import 'package:enterprise_mvvm/core/theme/app_gradients.dart';
import 'package:enterprise_mvvm/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({super.key, required this.body, this.appBar});

  final Widget body;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    final gradient = Theme.of(context).extension<AppGradients>()?.surface;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: Scaffold(
        backgroundColor: AppPalette.transparent,
        appBar: appBar,
        body: body,
      ),
    );
  }
}
