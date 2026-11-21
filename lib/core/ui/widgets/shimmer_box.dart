import 'package:enterprise_mvvm/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, this.height, this.width, this.borderRadius});

  final double? height;
  final double? width;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.surface,
      period: const Duration(milliseconds: 1500),
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(borderRadius ?? AppRadii.md),
        ),
      ),
    );
  }
}
