import 'package:enterprise_mvvm/core/theme/app_tokens.dart';
import 'package:enterprise_mvvm/core/ui/widgets/cached_image.dart';
import 'package:enterprise_mvvm/features/products/domain/models/product.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final thumbnail = product.thumbnail;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        leading: thumbnail == null || thumbnail.isEmpty
            ? const Icon(Icons.inventory_2_outlined)
            : CachedImage(
                imgUrl: thumbnail,
                width: 56,
                height: 56,
                borderRadius: AppRadii.sm,
                fit: BoxFit.cover,
              ),
        title: Text(product.title),
        subtitle: Text(product.price.toStringAsFixed(2)),
      ),
    );
  }
}
