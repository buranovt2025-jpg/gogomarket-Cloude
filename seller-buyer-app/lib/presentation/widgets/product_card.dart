import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/format.dart';
import '../../data/models/product/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool compact;

  const ProductCard({super.key, required this.product, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(Routes.product.replaceFirst(':id', product.id)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    product.mainPhotoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: product.mainPhotoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _shimmer(),
                          errorWidget: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                    if (product.discountPercent != null)
                      Positioned(
                        top: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(6)),
                          child: Text('-${product.discountPercent}%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    if (product.isBoosted)
                      Positioned(
                        top: 8, right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(6)),
                          child: const Text('⚡', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(FormatUtils.price(product.priceSum),
                        style: const TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w700)),
                      if (product.oldPriceSum != null) ...[
                        const SizedBox(width: 4),
                        Text(FormatUtils.price(product.oldPriceSum!),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11, decoration: TextDecoration.lineThrough)),
                      ],
                    ],
                  ),
                  if (product.avgRating > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.gold, size: 12),
                        const SizedBox(width: 2),
                        Text('${product.avgRating.toStringAsFixed(1)} (${product.reviewCount})',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.bgCard,
    child: const Center(child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: 40)),
  );

  Widget _shimmer() => Shimmer.fromColors(
    baseColor: AppColors.bgCard,
    highlightColor: AppColors.bgSurface,
    child: Container(color: Colors.white),
  );
}
