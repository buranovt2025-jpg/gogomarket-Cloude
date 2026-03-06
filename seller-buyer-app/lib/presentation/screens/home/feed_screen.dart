import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/format.dart';
import '../../../data/models/product/product_model.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/feed/feed_bloc.dart';

// Feed item types for mixed layout
enum _ItemType { large, small, reel, story }

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});
  @override Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<FeedBloc>()..add(FeedLoadEvent()),
    child: const _FeedBody(),
  );
}

class _FeedBody extends StatefulWidget {
  const _FeedBody();
  @override State<_FeedBody> createState() => _FeedBodyState();
}

class _FeedBodyState extends State<_FeedBody> {
  final _scroll = ScrollController();
  int _catIdx = 0;
  final _cats = ['Все', 'Одежда', 'Обувь', 'Красота', 'Техника', 'Дом', 'Спорт'];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
        context.read<FeedBloc>().add(FeedLoadMoreEvent());
      }
    });
  }

  @override void dispose() { _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          // ── AppBar ─────────────────────────────────────────────────
          SliverAppBar(
            pinned: true, floating: true, snap: true,
            backgroundColor: AppColors.bgDark,
            elevation: 0,
            titleSpacing: 16.w,
            title: Row(children: [
              RichText(text: TextSpan(children: [
                TextSpan(text: 'Gogo', style: TextStyle(color: AppColors.accent, fontSize: 22.sp, fontWeight: FontWeight.w800)),
                TextSpan(text: 'Market', style: TextStyle(color: AppColors.textPrimary, fontSize: 22.sp, fontWeight: FontWeight.w800)),
              ])),
              const Spacer(),
              IconButton(icon: const Icon(Icons.search, color: AppColors.textPrimary), onPressed: () => context.push(Routes.search)),
              IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary), onPressed: () {}),
            ]),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(40.h),
              child: SizedBox(height: 40.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  itemCount: _cats.length,
                  itemBuilder: (_, i) {
                    final on = i == _catIdx;
                    return GestureDetector(
                      onTap: () => setState(() => _catIdx = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: 8.w),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: on ? AppColors.accent : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_cats[i], style: TextStyle(
                          color: on ? Colors.black : AppColors.textSecondary,
                          fontSize: 12.sp, fontWeight: on ? FontWeight.w700 : FontWeight.normal,
                        )),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // ── Stories ────────────────────────────────────────────────
          SliverToBoxAdapter(child: _Stories()),

          // ── Feed ───────────────────────────────────────────────────
          BlocBuilder<FeedBloc, FeedState>(
            builder: (ctx, state) {
              if (state is FeedLoading) return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
              );
              if (state is FeedError) return SliverFillRemaining(child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.wifi_off, color: AppColors.textMuted, size: 48),
                  SizedBox(height: 12.h),
                  Text(state.message, style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp)),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => ctx.read<FeedBloc>().add(FeedLoadEvent()),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                    child: const Text('Повторить', style: TextStyle(color: Colors.black)),
                  ),
                ]),
              ));
              if (state is FeedLoaded) {
                return _InstagramFeed(products: state.products, hasMore: state.hasMore);
              }
              return const SliverToBoxAdapter(child: SizedBox());
            },
          ),
        ],
      ),
    );
  }
}

// ── Instagram-style feed ──────────────────────────────────────────────────────
class _InstagramFeed extends StatelessWidget {
  final List<ProductModel> products;
  final bool hasMore;
  const _InstagramFeed({required this.products, required this.hasMore});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SliverFillRemaining(
      child: Center(child: Text('Нет товаров', style: TextStyle(color: AppColors.textMuted))),
    );

    // Build mixed layout items
    final items = <Widget>[];
    int i = 0;
    while (i < products.length) {
      final pattern = (i ~/ 5) % 4;
      if (pattern == 0 && i < products.length) {
        // Full-width large card
        items.add(_LargeCard(product: products[i])); i++;
      } else if (pattern == 1 && i + 1 < products.length) {
        // Two columns
        items.add(_TwoColRow(left: products[i], right: products[i+1])); i += 2;
      } else if (pattern == 2 && i < products.length) {
        // Full-width with different aspect ratio
        items.add(_WideCard(product: products[i])); i++;
      } else if (pattern == 3 && i + 2 < products.length) {
        // Three in a row
        items.add(_ThreeColRow(a: products[i], b: products[i+1], c: products[i+2])); i += 3;
      } else {
        // Fallback
        items.add(_LargeCard(product: products[i])); i++;
      }
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, idx) {
          if (idx == items.length) return hasMore
            ? const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: AppColors.accent)))
            : SizedBox(height: 80.h);
          return Padding(padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h), child: items[idx]);
        },
        childCount: items.length + 1,
      ),
    );
  }
}

// ── Card widgets ──────────────────────────────────────────────────────────────

class _LargeCard extends StatelessWidget {
  final ProductModel product;
  const _LargeCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(Routes.productDetail(product.id)),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16.r)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Stack(fit: StackFit.expand, children: [
                _Img(url: product.photoUrls.isNotEmpty ? product.photoUrls.first : null),
                if (product.hasDiscount) Positioned(top: 10.h, left: 10.w,
                  child: _Badge('-${product.discountPercent}%', AppColors.red)),
                Positioned(top: 8.h, right: 8.w, child: _CartBtn(product: product)),
              ]),
            ),
          ),
          // Info
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Seller row
              Row(children: [
                CircleAvatar(radius: 12.r, backgroundColor: AppColors.bgSurface,
                  child: Text(product.sellerName?[0] ?? 'S',
                    style: TextStyle(color: AppColors.accent, fontSize: 10.sp, fontWeight: FontWeight.w700))),
                SizedBox(width: 6.w),
                Text(product.sellerName ?? 'Продавец',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
                const Spacer(),
                Icon(Icons.star, color: const Color(0xFFFFC107), size: 12.sp),
                SizedBox(width: 2.w),
                Text(product.avgRating.toStringAsFixed(1),
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp)),
              ]),
              SizedBox(height: 8.h),
              Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 6.h),
              Row(children: [
                Text(FormatUtils.priceTiyin(product.priceTiyin),
                  style: TextStyle(color: AppColors.accent, fontSize: 16.sp, fontWeight: FontWeight.w800)),
                if (product.hasDiscount) ...[
                  SizedBox(width: 8.w),
                  Text(FormatUtils.priceTiyin(product.oldPriceTiyin!),
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp, decoration: TextDecoration.lineThrough)),
                ],
                const Spacer(),
                Text('${product.saleCount} продаж',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _WideCard extends StatelessWidget {
  final ProductModel product;
  const _WideCard({required this.product});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push(Routes.productDetail(product.id)),
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16.r)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: AspectRatio(aspectRatio: 16/9,
          child: Stack(fit: StackFit.expand, children: [
            _Img(url: product.photoUrls.isNotEmpty ? product.photoUrls.first : null),
            Positioned(left:0, right:0, bottom:0, child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              )),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600)),
                  Text(FormatUtils.priceTiyin(product.priceTiyin),
                    style: TextStyle(color: AppColors.accent, fontSize: 14.sp, fontWeight: FontWeight.w800)),
                ])),
                _CartBtn(product: product, dark: false),
              ]),
            )),
            if (product.hasDiscount) Positioned(top: 10.h, left: 10.w,
              child: _Badge('-${product.discountPercent}%', AppColors.red)),
          ]),
        ),
      ),
    ),
  );
}

class _TwoColRow extends StatelessWidget {
  final ProductModel left, right;
  const _TwoColRow({required this.left, required this.right});
  @override Widget build(BuildContext context) => Row(children: [
    Expanded(child: _SmallCard(product: left)),
    Expanded(child: _SmallCard(product: right)),
  ]);
}

class _ThreeColRow extends StatelessWidget {
  final ProductModel a, b, c;
  const _ThreeColRow({required this.a, required this.b, required this.c});
  @override Widget build(BuildContext context) => Row(children: [
    Expanded(child: _TinyCard(product: a)),
    Expanded(child: _TinyCard(product: b)),
    Expanded(child: _TinyCard(product: c)),
  ]);
}

class _SmallCard extends StatelessWidget {
  final ProductModel product;
  const _SmallCard({required this.product});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push(Routes.productDetail(product.id)),
    child: Container(
      margin: EdgeInsets.all(3.w),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12.r)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
          child: AspectRatio(aspectRatio: 0.85, child: Stack(fit: StackFit.expand, children: [
            _Img(url: product.photoUrls.isNotEmpty ? product.photoUrls.first : null),
            if (product.hasDiscount) Positioned(top: 6.h, left: 6.w,
              child: _Badge('-${product.discountPercent}%', AppColors.red)),
            Positioned(top: 6.h, right: 6.w, child: _CartBtn(product: product, size: 26)),
          ]))),
        Padding(padding: EdgeInsets.all(8.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 11.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 4.h),
          Text(FormatUtils.priceTiyin(product.priceTiyin),
            style: TextStyle(color: AppColors.accent, fontSize: 12.sp, fontWeight: FontWeight.w800)),
        ])),
      ]),
    ),
  );
}

class _TinyCard extends StatelessWidget {
  final ProductModel product;
  const _TinyCard({required this.product});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push(Routes.productDetail(product.id)),
    child: Container(
      margin: EdgeInsets.all(2.w),
      child: ClipRRect(borderRadius: BorderRadius.circular(8.r),
        child: AspectRatio(aspectRatio: 1.0, child: Stack(fit: StackFit.expand, children: [
          _Img(url: product.photoUrls.isNotEmpty ? product.photoUrls.first : null),
          Positioned(bottom: 0, left: 0, right: 0, child: Container(
            padding: EdgeInsets.all(4.w),
            color: Colors.black54,
            child: Text(FormatUtils.priceTiyin(product.priceTiyin),
              style: TextStyle(color: AppColors.accent, fontSize: 9.sp, fontWeight: FontWeight.w700),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          )),
        ]))),
    ),
  );
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _Img extends StatelessWidget {
  final String? url;
  const _Img({this.url});
  @override Widget build(BuildContext context) => url != null
    ? CachedNetworkImage(imageUrl: url!, fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _placeholder())
    : _placeholder();

  Widget _placeholder() => Container(color: AppColors.bgSurface,
    child: Center(child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: 32)));
}

class _Badge extends StatelessWidget {
  final String text; final Color color;
  const _Badge(this.text, this.color);
  @override Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8.r)),
    child: Text(text, style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w700)),
  );
}

class _CartBtn extends StatelessWidget {
  final ProductModel product; final bool dark; final double size;
  const _CartBtn({required this.product, this.dark = true, this.size = 30});
  @override Widget build(BuildContext context) => BlocBuilder<CartBloc, CartState>(
    builder: (ctx, s) {
      final inCart = s.items.any((i) => i.product.id == product.id);
      return GestureDetector(
        onTap: () => ctx.read<CartBloc>().add(CartAdd(CartItem(product: product))),
        child: Container(
          width: size.w, height: size.w,
          decoration: BoxDecoration(
            color: inCart ? AppColors.accent : (dark ? Colors.black54 : Colors.white24),
            shape: BoxShape.circle,
          ),
          child: Icon(inCart ? Icons.check : Icons.add,
            color: inCart ? Colors.black : Colors.white, size: (size * 0.55).sp),
        ),
      );
    },
  );
}

// ── Stories ───────────────────────────────────────────────────────────────────
class _Stories extends StatelessWidget {
  final _s = const [
    {'n':'Aisha','e':'👗'}, {'n':'Nike','e':'👟'}, {'n':'Beauty','e':'💄'},
    {'n':'Tech','e':'📱'}, {'n':'Home','e':'🏠'}, {'n':'Sport','e':'⚽'},
  ];
  const _Stories();
  @override Widget build(BuildContext context) => SizedBox(height: 88.h,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      itemCount: _s.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) return _Story(n:'Мой', e:'➕', add: true);
        return _Story(n: _s[i-1]['n']!, e: _s[i-1]['e']!);
      },
    ),
  );
}

class _Story extends StatelessWidget {
  final String n, e; final bool add;
  const _Story({required this.n, required this.e, this.add = false});
  @override Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(right: 12.w),
    child: Column(children: [
      Container(
        width: 54.w, height: 54.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: add ? null : const LinearGradient(colors: [AppColors.accent, Color(0xFFFF6B35)]),
          color: add ? AppColors.bgCard : null,
          border: add ? Border.all(color: AppColors.bgSurface, width: 2) : null,
        ),
        padding: const EdgeInsets.all(2),
        child: CircleAvatar(backgroundColor: AppColors.bgCard,
          child: Text(e, style: TextStyle(fontSize: 22.sp))),
      ),
      SizedBox(height: 4.h),
      Text(n, style: TextStyle(color: AppColors.textSecondary, fontSize: 10.sp), maxLines: 1),
    ]),
  );
}
