import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/feed/feed_bloc.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/product_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FeedBloc>()..add(FeedLoadEvent()),
      child: const _FeedBody(),
    );
  }
}

class _FeedBody extends StatefulWidget {
  const _FeedBody();
  @override State<_FeedBody> createState() => _FeedBodyState();
}

class _FeedBodyState extends State<_FeedBody> {
  final _scroll = ScrollController();

  static const _categories = ['Все', '👗 Одежда', '👟 Обувь', '💄 Красота', '📱 Техника', '🏠 Дом', '🍎 Еда'];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        context.read<FeedBloc>().add(FeedLoadMore());
      }
    });
  }

  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (ctx, inner) => [
            SliverToBoxAdapter(child: _Header()),
            SliverToBoxAdapter(child: _ModeToggle()),
            SliverToBoxAdapter(child: _CategoryBar()),
          ],
          body: BlocBuilder<FeedBloc, FeedState>(
            builder: (ctx, state) {
              if (state.isLoading) return _Shimmer();
              if (state.error != null && state.products.isEmpty) return _Error(state.error!, () => ctx.read<FeedBloc>().add(FeedRefresh()));
              if (state.products.isEmpty) return _Empty(state.mode);

              return RefreshIndicator(
                color: AppColors.accent,
                backgroundColor: AppColors.bgCard,
                onRefresh: () async => ctx.read<FeedBloc>().add(FeedRefresh()),
                child: GridView.builder(
                  controller: _scroll,
                  padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 100.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: state.products.length + (state.isLoadingMore ? 2 : 0),
                  itemBuilder: (_, i) {
                    if (i >= state.products.length) return _ShimmerCard();
                    final p = state.products[i];
                    return ProductCard(
                      product: p,
                      onTap: () => context.push(Routes.productDetail(p.id)),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = (context.watch<AuthBloc>().state as AuthAuthenticated?)?.user;
    final cartCount = context.watch<CartBloc>().state.totalQty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(children: [
        // Logo
        RichText(text: TextSpan(
          style: TextStyle(fontFamily: 'Playfair', fontSize: 22.sp, fontWeight: FontWeight.w700),
          children: const [
            TextSpan(text: 'Gogo', style: TextStyle(color: AppColors.textPrimary)),
            TextSpan(text: 'Market', style: TextStyle(color: AppColors.accent)),
          ],
        )),
        const Spacer(),

        // Search
        GestureDetector(
          onTap: () => context.push(Routes.search),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          ),
        ),
        SizedBox(width: 8.w),

        // Cart with badge
        GestureDetector(
          onTap: () => context.push(Routes.cart),
          child: Stack(children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.shopping_bag_outlined, color: AppColors.textSecondary, size: 20),
            ),
            if (cartCount > 0)
              Positioned(
                top: 0, right: 0,
                child: Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                  child: Center(child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))),
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}

// ── Mode toggle (Дискавери / Подписки) ───────────────────────────────────────
class _ModeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      buildWhen: (a, b) => a.mode != b.mode,
      builder: (ctx, state) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: Container(
          height: 36.h,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Row(children: [
            _Tab('Дискавери', state.mode == 'discover', () => ctx.read<FeedBloc>().add(FeedLoad(mode: 'discover'))),
            _Tab('Подписки',  state.mode == 'following', () => ctx.read<FeedBloc>().add(FeedLoad(mode: 'following'))),
          ]),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;
  const _Tab(this.text, this.active, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(text, style: TextStyle(
          color: active ? Colors.white : AppColors.textMuted,
          fontSize: 13.sp, fontWeight: active ? FontWeight.w600 : FontWeight.normal,
        )),
      ),
    ),
  );
}

// ── Category bar ──────────────────────────────────────────────────────────────
class _CategoryBar extends StatelessWidget {
  static const _cats = ['Все', '👗 Одежда', '👟 Обувь', '💄 Красота', '📱 Техника', '🏠 Дом', '🍎 Еда'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      buildWhen: (a, b) => a.category != b.category,
      builder: (ctx, state) => SizedBox(
        height: 40.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: 16.w, right: 8.w),
          itemCount: _cats.length,
          itemBuilder: (_, i) {
            final label    = _cats[i];
            final catKey   = i == 0 ? null : label.split(' ').last.toLowerCase();
            final selected = (i == 0 && state.category == null) || state.category == catKey;
            return GestureDetector(
              onTap: () => ctx.read<FeedBloc>().add(FeedSetCategory(catKey)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? AppColors.accent : AppColors.border),
                ),
                alignment: Alignment.center,
                child: Text(label, style: TextStyle(
                  color: selected ? Colors.white : AppColors.textMuted,
                  fontSize: 12.sp,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                )),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Empty / Error ─────────────────────────────────────────────────────────────
class _Empty extends StatelessWidget {
  final String mode;
  const _Empty(this.mode);
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(mode == 'following' ? '👥' : '🛍️', style: TextStyle(fontSize: 48.sp)),
    SizedBox(height: 14.h),
    Text(mode == 'following' ? 'Подпишитесь на продавцов' : 'Нет товаров',
      style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp)),
  ]));
}

class _Error extends StatelessWidget {
  final String msg; final VoidCallback onRetry;
  const _Error(this.msg, this.onRetry);
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text('😕', style: TextStyle(fontSize: 40.sp)),
    SizedBox(height: 12.h),
    Text('Ошибка загрузки', style: TextStyle(color: AppColors.textSecondary, fontSize: 15.sp)),
    SizedBox(height: 12.h),
    TextButton(onPressed: onRetry, child: Text('Повторить', style: TextStyle(color: AppColors.accent, fontSize: 14.sp))),
  ]));
}

// ── Shimmer loading ───────────────────────────────────────────────────────────
class _Shimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 0),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, crossAxisSpacing: 10.w, mainAxisSpacing: 10.h, childAspectRatio: 0.68,
    ),
    itemCount: 8,
    itemBuilder: (_, __) => _ShimmerCard(),
  );
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.bgCard, highlightColor: AppColors.bgSurface,
    child: Container(
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16)),
    ),
  );
}
