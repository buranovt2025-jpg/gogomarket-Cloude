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

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
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
  int _catIndex = 0;
  final _categories = ['Все', 'Одежда', 'Обувь', 'Красота', 'Техника', 'Дом'];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        context.read<FeedBloc>().add(FeedLoadMoreEvent());
      }
    });
  }

  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          // ── AppBar ─────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.bgDark,
            titleSpacing: 16.w,
            title: Row(children: [
              Text('Gogo', style: TextStyle(color: AppColors.accent, fontSize: 22.sp, fontWeight: FontWeight.w800)),
              Text('Market', style: TextStyle(color: AppColors.textPrimary, fontSize: 22.sp, fontWeight: FontWeight.w800)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.textPrimary),
                onPressed: () => context.push(Routes.search),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                onPressed: () {},
              ),
            ]),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(44.h),
              child: _CategoryBar(selected: _catIndex, onSelect: (i) => setState(() => _catIndex = i), cats: _categories),
            ),
          ),

          // ── Stories ────────────────────────────────────────────────
          SliverToBoxAdapter(child: _StoriesRow()),
        ],

        // ── Products grid ───────────────────────────────────────────
        body: BlocBuilder<FeedBloc, FeedState>(
          builder: (ctx, state) {
            if (state is FeedLoading) return const Center(child: CircularProgressIndicator(color: AppColors.accent));
            if (state is FeedError) return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, color: AppColors.textMuted, size: 48),
                SizedBox(height: 12.h),
                Text(state.message, style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp)),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => ctx.read<FeedBloc>().add(FeedLoadEvent()),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                  child: const Text('Повторить', style: TextStyle(color: Colors.black)),
                ),
              ],
            ));
            if (state is FeedLoaded) {
              if (state.products.isEmpty) return Center(
                child: Text('Нет товаров', style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp)),
              );
              return RefreshIndicator(
                color: AppColors.accent,
                onRefresh: () async => ctx.read<FeedBloc>().add(FeedRefreshEvent()),
                child: GridView.builder(
                  controller: _scroll,
                  padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 80.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 12.h, crossAxisSpacing: 12.w, childAspectRatio: 0.62,
                  ),
                  itemCount: state.products.length + (state.hasMore ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == state.products.length) return const Center(child: Padding(
                      padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.accent),
                    ));
                    return _ProductCard(product: state.products[i]);
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

// ── Category Bar ──────────────────────────────────────────────────────────────
class _CategoryBar extends StatelessWidget {
  final int selected;
  final void Function(int) onSelect;
  final List<String> cats;
  const _CategoryBar({required this.selected, required this.onSelect, required this.cats});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        itemCount: cats.length,
        itemBuilder: (_, i) {
          final active = i == selected;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: active ? AppColors.accent : AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(cats[i], style: TextStyle(
                color: active ? Colors.black : AppColors.textSecondary,
                fontSize: 12.sp, fontWeight: active ? FontWeight.w700 : FontWeight.normal,
              )),
            ),
          );
        },
      ),
    );
  }
}

// ── Stories Row ───────────────────────────────────────────────────────────────
class _StoriesRow extends StatelessWidget {
  final _stories = const [
    {'name': 'Aisha', 'emoji': '👗'},
    {'name': 'Nike', 'emoji': '👟'},
    {'name': 'Beauty', 'emoji': '💄'},
    {'name': 'Tech', 'emoji': '📱'},
    {'name': 'Home', 'emoji': '🏠'},
    {'name': 'Sport', 'emoji': '⚽'},
  ];

  const _StoriesRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        itemCount: _stories.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) return _StoryItem(name: 'Мой', emoji: '➕', isAdd: true);
          final s = _stories[i - 1];
          return _StoryItem(name: s['name']!, emoji: s['emoji']!);
        },
      ),
    );
  }
}

class _StoryItem extends StatelessWidget {
  final String name, emoji;
  final bool isAdd;
  const _StoryItem({required this.name, required this.emoji, this.isAdd = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 12.w),
      child: Column(children: [
        Container(
          width: 52.w, height: 52.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isAdd ? null : const LinearGradient(
              colors: [AppColors.accent, Color(0xFFFF6B35)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            color: isAdd ? AppColors.bgCard : null,
            border: isAdd ? Border.all(color: AppColors.bgSurface, width: 2) : null,
          ),
          padding: const EdgeInsets.all(2),
          child: CircleAvatar(
            backgroundColor: AppColors.bgCard,
            child: Text(emoji, style: TextStyle(fontSize: 20.sp)),
          ),
        ),
        SizedBox(height: 4.h),
        Text(name, style: TextStyle(color: AppColors.textSecondary, fontSize: 10.sp), maxLines: 1),
      ]),
    );
  }
}

// ── Product Card ──────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(Routes.productDetail(product.id)),
      child: Container(
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16.r)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image
          Expanded(
            child: Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: SizedBox.expand(
                  child: product.photoUrls.isNotEmpty
                    ? CachedNetworkImage(imageUrl: product.photoUrls.first, fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _ImgPlaceholder())
                    : _ImgPlaceholder(),
                ),
              ),
              if (product.hasDiscount)
                Positioned(top: 8.h, left: 8.w, child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(8.r)),
                  child: Text('-${product.discountPercent}%', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w700)),
                )),
              Positioned(top: 8.h, right: 8.w, child: BlocBuilder<CartBloc, CartState>(
                builder: (ctx, state) {
                  final inCart = state.items.any((i) => i.product.id == product.id);
                  return GestureDetector(
                    onTap: () => ctx.read<CartBloc>().add(CartAdd(product)),
                    child: Container(
                      width: 30.w, height: 30.w,
                      decoration: BoxDecoration(
                        color: inCart ? AppColors.accent : Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(inCart ? Icons.check : Icons.add, color: inCart ? Colors.black : Colors.white, size: 16.sp),
                    ),
                  );
                },
              )),
            ]),
          ),
          // Info
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 12.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 6.h),
              Text(FormatUtils.priceTiyin(product.priceTiyin),
                style: TextStyle(color: AppColors.accent, fontSize: 14.sp, fontWeight: FontWeight.w800)),
              if (product.hasDiscount) ...[
                SizedBox(height: 2.h),
                Text(FormatUtils.priceTiyin(product.oldPriceTiyin!),
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp, decoration: TextDecoration.lineThrough)),
              ],
              SizedBox(height: 6.h),
              Row(children: [
                Icon(Icons.star, color: const Color(0xFFFFC107), size: 12.sp),
                SizedBox(width: 3.w),
                Text(product.avgRating.toStringAsFixed(1),
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp)),
                const Spacer(),
                Text('${product.saleCount} продаж', style: TextStyle(color: AppColors.textMuted, fontSize: 10.sp)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ImgPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.bgSurface,
    child: Center(child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: 32.sp)),
  );
}
