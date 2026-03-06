import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/format.dart';
import '../../../core/network/api_client.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/product/product_bloc.dart';
import '../../widgets/gogo_button.dart';
import '../../../data/models/product/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});
  @override State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _photoIdx = 0;
  String? _selectedVariantId;
  final _pageCtrl = PageController();

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductBloc>()..add(ProductLoadEvent(widget.productId)),
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (ctx, state) {
            if (state is ProductLoading) return _Loading();
            if (state is ProductError)   return _Err(state.message, () => ctx.read<ProductBloc>().add(ProductLoadEvent(widget.productId)));
            if (state is! ProductLoaded) return const SizedBox();
            return _Body(product: state.product, photoIdx: _photoIdx, pageCtrl: _pageCtrl,
              selectedVariant: _selectedVariantId,
              onPhotoChanged: (i) => setState(() => _photoIdx = i),
              onVariantSelected: (id) => setState(() => _selectedVariantId = id));
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final ProductModel product;
  final int photoIdx;
  final PageController pageCtrl;
  final String? selectedVariant;
  final ValueChanged<int> onPhotoChanged;
  final ValueChanged<String?> onVariantSelected;

  const _Body({required this.product, required this.photoIdx, required this.pageCtrl,
    this.selectedVariant, required this.onPhotoChanged, required this.onVariantSelected});

  @override
  Widget build(BuildContext context) {
    final inCart = context.watch<CartBloc>().state.contains(product.id);

    return Stack(children: [
      CustomScrollView(slivers: [
        // ── Photo gallery ──────────────────────────────────────────────
        SliverToBoxAdapter(child: SizedBox(
          height: 380.h,
          child: Stack(children: [
            // Photos
            PageView.builder(
              controller: pageCtrl,
              itemCount: product.photoUrls.isEmpty ? 1 : product.photoUrls.length,
              onPageChanged: onPhotoChanged,
              itemBuilder: (_, i) {
                final url = product.photoUrls.isNotEmpty ? product.photoUrls[i] : '';
                return url.isEmpty
                  ? Container(color: AppColors.bgCard, child: Center(child: Icon(Icons.image_outlined, size: 64.sp, color: AppColors.textMuted)))
                  : GestureDetector(
                      onTap: () => _openGallery(context, i),
                      child: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(color: AppColors.bgCard)),
                    );
              },
            ),

            // Back
            Positioned(top: 48.h, left: 16.w,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(width: 38, height: 38,
                  decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16)),
              ),
            ),

            // Share
            Positioned(top: 48.h, right: 16.w,
              child: Container(width: 38, height: 38,
                decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: IconButton(icon: const Icon(Icons.share_outlined, color: Colors.white, size: 16), onPressed: () {})),
            ),

            // Photo dots
            if (product.photoUrls.length > 1)
              Positioned(bottom: 12.h, left: 0, right: 0,
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(product.photoUrls.length, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == photoIdx ? 16 : 6, height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == photoIdx ? AppColors.accent : Colors.white54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  )),
                ),
              ),

            // Discount
            if (product.discountPercent != null)
              Positioned(bottom: 16.h, left: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(10)),
                  child: Text('-${product.discountPercent}%',
                    style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w700)),
                ),
              ),
          ]),
        )),

        // ── Content ────────────────────────────────────────────────────
        SliverToBoxAdapter(child: Container(
          decoration: const BoxDecoration(
            color: AppColors.bgDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 120.h),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Title + price
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(product.title, style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700, height: 1.3,
                  )),
                  SizedBox(height: 6.h),
                  Row(children: [
                    if (product.originalPriceTiyin != null) ...[
                      Text(FormatUtils.priceTiyin(product.originalPriceTiyin!),
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp, decoration: TextDecoration.lineThrough, decorationColor: AppColors.textMuted)),
                      SizedBox(width: 8.w),
                    ],
                    Text(FormatUtils.priceTiyin(product.priceTiyin),
                      style: TextStyle(
                        color: product.discountPercent != null ? AppColors.accent : AppColors.textPrimary,
                        fontSize: 22.sp, fontWeight: FontWeight.w800,
                      )),
                  ]),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  if (product.avgRating != null && product.avgRating! > 0) ...[
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
                      SizedBox(width: 3.w),
                      Text(product.avgRating!.toStringAsFixed(1),
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    ]),
                    Text('${product.reviewCount} отзывов', style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
                  ],
                  SizedBox(height: 4.h),
                  Text('Продано: ${product.soldCount}', style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
                ]),
              ]),
              SizedBox(height: 16.h),

              // Seller chip
              GestureDetector(
                onTap: () => context.push(Routes.storefront(product.sellerId)),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                  child: Row(children: [
                    CircleAvatar(radius: 18, backgroundColor: AppColors.bgSurface,
                      backgroundImage: product.sellerAvatarUrl != null ? NetworkImage(product.sellerAvatarUrl!) : null,
                      child: product.sellerAvatarUrl == null ? Text((product.sellerName ?? 'S')[0],
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)) : null),
                    SizedBox(width: 10.w),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(product.sellerName ?? 'Продавец', style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      Text('Открыть витрину', style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
                    ])),
                    const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14),
                  ]),
                ),
              ),
              SizedBox(height: 16.h),

              // Variants
              if (product.variants.isNotEmpty) ...[
                Text('ВАРИАНТЫ', style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp, fontWeight: FontWeight.w600, letterSpacing: 1)),
                SizedBox(height: 8.h),
                Wrap(spacing: 8.w, runSpacing: 8.h,
                  children: product.variants.map((v) {
                    final sel = selectedVariant == v.id;
                    return GestureDetector(
                      onTap: () => onVariantSelected(sel ? null : v.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.accent : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: sel ? AppColors.accent : AppColors.border),
                        ),
                        child: Text(v.value, style: TextStyle(
                          color: sel ? Colors.white : AppColors.textPrimary,
                          fontSize: 13.sp, fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                        )),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.h),
              ],

              // Description
              if (product.description != null && product.description!.isNotEmpty) ...[
                Text('ОПИСАНИЕ', style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp, fontWeight: FontWeight.w600, letterSpacing: 1)),
                SizedBox(height: 8.h),
                Text(product.description!, style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp, height: 1.6)),
              ],
            ]),
          ),
        )),
      ]),

      // ── Bottom bar ─────────────────────────────────────────────────────
      Positioned(
        bottom: 0, left: 0, right: 0,
        child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
          decoration: BoxDecoration(
            color: AppColors.bgDark,
            border: const Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(children: [
            // Chat
            Container(
              width: 48.w, height: 48.h,
              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
              child: IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: AppColors.textSecondary, size: 20),
                onPressed: () {},
              ),
            ),
            SizedBox(width: 10.w),
            // Add to cart / In cart
            Expanded(
              child: GogoButton(
                label: inCart ? '✓ В корзине' : 'В корзину',
                variant: inCart ? ButtonVariant.outline : ButtonVariant.primary,
                onPressed: () {
                  if (inCart) {
                    context.read<CartBloc>().add(CartRemove(product.id));
                  } else {
                    context.read<CartBloc>().add(CartAdd(CartItem(product: product, variantId: selectedVariant)));
                  }
                },
              ),
            ),
            SizedBox(width: 10.w),
            // Buy now
            Expanded(
              child: GogoButton(
                label: 'Купить',
                variant: ButtonVariant.green,
                onPressed: () {
                  if (!inCart) context.read<CartBloc>().add(CartAdd(CartItem(product: product, variantId: selectedVariant)));
                  context.push(Routes.cart);
                },
              ),
            ),
          ]),
        ),
      ),
    ]);
  }

  void _openGallery(BuildContext context, int initial) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: PhotoViewGallery.builder(
          itemCount: product.photoUrls.length,
          pageController: PageController(initialPage: initial),
          builder: (_, i) => PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(product.photoUrls[i]),
            minScale: PhotoViewComputedScale.contained,
          ),
        ),
      ),
    ));
  }
}

class _Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bgDark,
    body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
  );
}
class _Err extends StatelessWidget {
  final String msg; final VoidCallback onRetry;
  const _Err(this.msg, this.onRetry);
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bgDark,
    appBar: AppBar(backgroundColor: AppColors.bgDark, foregroundColor: AppColors.textPrimary),
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('😕', style: TextStyle(fontSize: 40.sp)),
      SizedBox(height: 12.h),
      Text('Не удалось загрузить', style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp)),
      SizedBox(height: 12.h),
      TextButton(onPressed: onRetry, child: Text('Повторить', style: TextStyle(color: AppColors.accent))),
    ])),
  );
}
