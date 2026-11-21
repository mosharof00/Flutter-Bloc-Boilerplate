import 'package:enterprise_mvvm/core/ui/widgets/app_svg_icon.dart';
import 'package:enterprise_mvvm/gen/assets.gen.dart';
import 'package:flutter/material.dart';

/// Circular icon button. The back arrow is the default icon.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.onPressed,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.size = 40,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: backgroundColor ?? scheme.surface,
      shape: const CircleBorder(),
      elevation: 1,
      shadowColor: scheme.shadow.withValues(alpha: 0.2),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox.square(
          dimension: size,
          child: Center(
            child:
                icon ??
                AppSvgIcon(
                  Assets.icons.backArrowIcon,
                  size: size * 0.4,
                  color: iconColor ?? scheme.onSurface,
                ),
          ),
        ),
      ),
    );
  }
}
