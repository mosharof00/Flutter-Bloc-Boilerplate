import 'package:enterprise_mvvm/core/theme/app_tokens.dart';
import 'package:enterprise_mvvm/core/ui/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';

class ShimmerList extends StatelessWidget {
  const ShimmerList({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 72,
    this.borderRadius,
    this.spacing = AppSpacing.sm,
    this.padding,
  });

  final int itemCount;
  final double itemHeight;
  final double? borderRadius;
  final double spacing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (BuildContext context, int index) =>
          SizedBox(height: spacing),
      itemBuilder: (BuildContext context, int index) =>
          ShimmerBox(height: itemHeight, borderRadius: borderRadius),
    );
  }
}
