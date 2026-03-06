import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/format.dart';
import '../../data/models/product/product_model.dart';
import '../blocs/cart/cart_bloc.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final inCart = context.watch<CartBloc>().state.contains(product.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: inCart ? AppColors.accent.withOpacity(0.4) : AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Image ─────────────────────────────────────────────────────
          Expanded(
            flex: 6,
            child: Stack(fit: StackFit.expand, children: [
              // Photo
              product.photoUrls.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.photoUrls.isNotEmpty ? product.photoUrls.first : "",
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Shimmer.fromColors(
                      baseColor: AppColors.bgCard, highlightColor: AppColors.bgSurface,
                      child: Container(color: AppColors.bgCard),
                    ),
                    errorWidget: (_, __, ___) => _NoPhoto(),
                  )
                : _NoPhoto(),

              // Discount badge
              if (product.discountPercent != null)
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.red, borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('-${product.discountPercent}%',
                      style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w700)),
                  ),
                ),

              // Boost badge
              if (product.isBoosted)
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('⚡', style: TextStyle(fontSize: 10.sp)),
                  ),
                ),

              // Cart button
              Positioned(
                bottom: 8, right: 8,
                child: GestureDetector(
                  onTap: () {
                    if (inCart) {
                      context.read<CartBloc>().add(CartRemove(product.id));
                    } else {
                      context.read<CartBloc>().add(CartAdd(CartItem(product: product)));
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: inCart ? AppColors.accent : Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        inCart ? Icons.check : Icons.add,
                        color: Colors.white, size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),

          // ── Info ──────────────────────────────────────────────────────
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.title,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12.sp, fontWeight: FontWeight.w500, height: 1.3,
                  ),
                ),
                const Spacer(),
                // Price row
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (product.originalPriceTiyin != null)
                      Text(FormatUtils.priceTiyin(product.originalPriceTiyin!),
                        style: TextStyle(
                          color: AppColors.textMuted, fontSize: 10.sp,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.textMuted,
                        ),
                      ),
                    Text(FormatUtils.priceTiyin(product.priceTiyin),
                      style: TextStyle(
                        color: product.discountPercent != null ? AppColors.accent : AppColors.textPrimary,
                        fontSize: 13.sp, fontWeight: FontWeight.w700,
                      ),
                    ),
                  ])),

                  // Rating
                  if (product.avgRating != null && product.avgRating! > 0)
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.star_rounded, color: AppColors.gold, size: 12),
                      SizedBox(width: 2.w),
                      Text(product.avgRating!.toStringAsFixed(1),
                        style: TextStyle(color: AppColors.textMuted, fontSize: 10.sp)),
                    ]),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _NoPhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.bgSurface,
    child: Center(child: Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted, size: 32.sp)),
  );
}
