import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

// ── Data models ───────────────────────────────────────────────────────────────
class _FeedItem {
  final String id, title, seller, price, views, emoji;
  final bool isVideo;
  final Color color;
  final String? realPhotoUrl;
  const _FeedItem({required this.id, required this.title, required this.seller,
    required this.price, required this.views, required this.isVideo,
    required this.color, required this.emoji, this.realPhotoUrl});
}

class _Story {
  final String name, emoji;
  final Color ring;
  final bool isMe, hasNew;
  const _Story({required this.name, required this.emoji, required this.ring,
    this.isMe = false, this.hasNew = true});
}

const _stories = [
  _Story(name: 'Мой',      emoji: '➕', ring: Color(0xFF444444), isMe: true,  hasNew: false),
  _Story(name: 'Aisha',    emoji: '👗', ring: Color(0xFFFF5001), hasNew: true),
  _Story(name: 'Kamola',   emoji: '💄', ring: Color(0xFFE91E8C), hasNew: true),
  _Story(name: 'TechZone', emoji: '📱', ring: Color(0xFF1F87E8), hasNew: true),
  _Story(name: 'Sport',    emoji: '🏋️', ring: Color(0xFF00C566), hasNew: false),
  _Story(name: 'Home',     emoji: '🏠', ring: Color(0xFFFF9800), hasNew: true),
  _Story(name: 'Sneaker',  emoji: '👟', ring: Color(0xFF9C27B0), hasNew: false),
  _Story(name: 'Beauty',   emoji: '✨', ring: Color(0xFFFF4081), hasNew: true),
];

final _mockItems = [
  _FeedItem(id:'r1', title:'Платье летнее',     seller:'Aisha Fashion',  price:'185 000', views:'12,4K', isVideo:true,  color:const Color(0xFF1A1040), emoji:'👗'),
  _FeedItem(id:'p9', title:'Сыворотка Vitamin', seller:'Kamola Beauty',  price:'189 000', views:'21K',   isVideo:false, color:const Color(0xFF301020), emoji:'💄'),
  _FeedItem(id:'r3', title:'Наушники TWS',      seller:'TechZone UZ',    price:'380 000', views:'8,9K',  isVideo:true,  color:const Color(0xFF0D2030), emoji:'🎧'),
  _FeedItem(id:'p5', title:'Джинсы mom fit',    seller:'Aisha Fashion',  price:'210 000', views:'5,6K',  isVideo:false, color:const Color(0xFF1A2010), emoji:'👖'),
  _FeedItem(id:'r4', title:'Тренировка утром',  seller:'Sport Life',     price:'145 000', views:'15,6K', isVideo:true,  color:const Color(0xFF0D2010), emoji:'🏋️'),
  _FeedItem(id:'p11', title:'Палетка теней',    seller:'Kamola Beauty',  price:'240 000', views:'3,2K',  isVideo:false, color:const Color(0xFF301525), emoji:'👁️'),
  _FeedItem(id:'r6', title:'Пальто оверсайз',   seller:'Aisha Fashion',  price:'680 000', views:'32K',   isVideo:true,  color:const Color(0xFF251A10), emoji:'🧥'),
  _FeedItem(id:'p14', title:'Наушники TWS Pro', seller:'TechZone UZ',    price:'380 000', views:'4,1K',  isVideo:false, color:const Color(0xFF102030), emoji:'🎵'),
  _FeedItem(id:'r7', title:'Макияж 5 минут',    seller:'Kamola Beauty',  price:'240 000', views:'45K',   isVideo:true,  color:const Color(0xFF300A20), emoji:'💋'),
  _FeedItem(id:'p22', title:'Свеча Ваниль',     seller:'Home Comfort',   price:'85 000',  views:'9,3K',  isVideo:false, color:const Color(0xFF201510), emoji:'🕯️'),
  _FeedItem(id:'r8', title:'Смарт-часы GT4',    seller:'TechZone UZ',    price:'520 000', views:'11K',   isVideo:true,  color:const Color(0xFF102040), emoji:'⌚'),
  _FeedItem(id:'p7', title:'Пальто оверсайз',   seller:'Aisha Fashion',  price:'680 000', views:'34K',   isVideo:false, color:const Color(0xFF252015), emoji:'🧣'),
  _FeedItem(id:'r2', title:'Результат 7 дней',  seller:'Kamola Beauty',  price:'189 000', views:'21K',   isVideo:true,  color:const Color(0xFF2A1020), emoji:'🌟'),
  _FeedItem(id:'p19', title:'Кроссовки бег',    seller:'Sport Life',     price:'380 000', views:'28K',   isVideo:false, color:const Color(0xFF101530), emoji:'👟'),
  _FeedItem(id:'r5', title:'Уютный вечер',      seller:'Home Comfort',   price:'85 000',  views:'7,8K',  isVideo:true,  color:const Color(0xFF201510), emoji:'🏠'),
  _FeedItem(id:'p13', title:'Парфюм Rose Musk', seller:'Kamola Beauty',  price:'450 000', views:'52K',   isVideo:false, color:const Color(0xFF300A20), emoji:'🌸'),
  _FeedItem(id:'p20', title:'Коврик для йоги',  seller:'Sport Life',     price:'120 000', views:'4,2K',  isVideo:false, color:const Color(0xFF0A2010), emoji:'🧘'),
  _FeedItem(id:'p15', title:'Смарт-часы GT4',   seller:'TechZone UZ',    price:'520 000', views:'3,2K',  isVideo:false, color:const Color(0xFF0A1020), emoji:'📱'),
];

const _cats = ['Все', 'Одежда', 'Обувь', 'Красота', 'Техника', 'Дом', 'Спорт'];

// ── Screen ────────────────────────────────────────────────────────────────────
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
  int _catIdx = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            // ── AppBar ────────────────────────────────────────────────
            SliverAppBar(
              pinned: true, floating: true, snap: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0, shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              titleSpacing: 16.w,
              toolbarHeight: 52.h,
              title: Row(children: [
                Image.asset(
                  isDark
                    ? 'assets/images/logo_horizontal_light.png'
                    : 'assets/images/logo_horizontal_dark.png',
                  height: 24.h, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Text('GogoMarket',
                    style: TextStyle(color: AppColors.accent, fontSize: 18.sp, fontWeight: FontWeight.w900)),
                ),
                const Spacer(),
                _IconBtn(icon: Icons.search_rounded, onTap: () => context.push(Routes.search), isDark: isDark),
                SizedBox(width: 6.w),
                _IconBtn(icon: Icons.notifications_none_rounded, onTap: () => context.push(Routes.notifications), isDark: isDark, badge: 2),
                SizedBox(width: 6.w),
                BlocBuilder<CartBloc, CartState>(
                  builder: (_, s) => _IconBtn(icon: Icons.shopping_bag_outlined, onTap: () => context.push(Routes.cart), isDark: isDark, badge: s.totalQty),
                ),
              ]),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(38.h),
                child: SizedBox(
                  height: 38.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 6.h),
                    itemCount: _cats.length,
                    itemBuilder: (_, i) {
                      final on = i == _catIdx;
                      return GestureDetector(
                        onTap: () { HapticFeedback.selectionClick(); setState(() => _catIdx = i); },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          margin: EdgeInsets.only(right: 6.w),
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: on ? AppColors.accent
                                : isDark ? Colors.white.withOpacity(0.07)
                                         : Colors.black.withOpacity(0.055),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(_cats[i], style: TextStyle(
                            color: on ? Colors.white
                                : isDark ? Colors.white.withOpacity(0.60) : Colors.black.withOpacity(0.54),
                            fontSize: 12.sp,
                            fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                          )),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Stories ───────────────────────────────────────────────
            SliverToBoxAdapter(child: _StoriesRow(isDark: isDark)),

            // ── Trending header ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
                child: Row(children: [
                  Text('В тренде', style: TextStyle(
                    fontSize: 16.sp, fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black,
                  )),
                  SizedBox(width: 6.w),
                  Text('🔥', style: TextStyle(fontSize: 14.sp)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: Text('Все', style: TextStyle(
                      fontSize: 13.sp, color: AppColors.accent, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
            ),

            // ── Grid ─────────────────────────────────────────────────
            BlocBuilder<FeedBloc, FeedState>(
              builder: (ctx, state) {
                List<_FeedItem> items = _mockItems;
                if (state is FeedLoaded && state.products.isNotEmpty) {
                  final real = state.products.take(9).map((p) => _FeedItem(
                    id: p.id, title: p.title, seller: p.sellerName ?? '',
                    price: FormatUtils.priceTiyin(p.priceTiyin),
                    views: _fmtV(p.viewCount), isVideo: false,
                    color: const Color(0xFF1A1A1A), emoji: '🛍️',
                    realPhotoUrl: p.firstPhoto,
                  )).toList();
                  final merged = <_FeedItem>[];
                  int ri = 0, mi = 0;
                  while (mi < _mockItems.length) {
                    if (ri < real.length && mi % 3 == 0) merged.add(real[ri++]);
                    merged.add(_mockItems[mi++]);
                  }
                  items = merged;
                }
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _GridCell(item: items[i % items.length]),
                      childCount: items.length + 6,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 6.h,
                      crossAxisSpacing: 6.w,
                      childAspectRatio: 0.65,
                    ),
                  ),
                );
              },
            ),

            SliverToBoxAdapter(child: SizedBox(height: 110.h)),
          ],
        ),
      ),
    );
  }

  static String _fmtV(int v) {
    if (v >= 1000000) return '${(v/1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v/1000).toStringAsFixed(1)}K';
    return '$v';
  }
}

// ── Icon button ───────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final int badge;
  const _IconBtn({required this.icon, required this.onTap, required this.isDark, this.badge = 0});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36.w, height: 36.w,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.055),
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: Stack(alignment: Alignment.center, children: [
        Icon(icon, size: 19.sp, color: isDark ? Colors.white.withOpacity(0.80) : Colors.black.withOpacity(0.87)),
        if (badge > 0) Positioned(
          top: 5.h, right: 5.w,
          child: Container(
            width: 8.w, height: 8.w,
            decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
          ),
        ),
      ]),
    ),
  );
}

// ── Stories ───────────────────────────────────────────────────────────────────
class _StoriesRow extends StatelessWidget {
  final bool isDark;
  const _StoriesRow({required this.isDark});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 96.h,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 6.h),
      itemCount: _stories.length,
      itemBuilder: (_, i) => _StoryItem(story: _stories[i], isDark: isDark),
    ),
  );
}

class _StoryItem extends StatelessWidget {
  final _Story story;
  final bool isDark;
  const _StoryItem({required this.story, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        width: 64.w,
        margin: EdgeInsets.only(right: 12.w),
        child: Column(children: [
          // Ring + avatar
          SizedBox(
            width: 64.w, height: 64.w,
            child: Stack(alignment: Alignment.center, children: [
              // Gradient ring for stories with new content
              if (story.hasNew && !story.isMe)
                Container(
                  width: 64.w, height: 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const SweepGradient(
                      colors: [Color(0xFFFF5001), Color(0xFFFF9800), Color(0xFFE91E8C), Color(0xFFFF5001)],
                    ),
                  ),
                ),
              // Seen ring
              if (!story.hasNew && !story.isMe)
                Container(
                  width: 64.w, height: 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.24) : Colors.black.withOpacity(0.15),
                      width: 2,
                    ),
                  ),
                ),
              // Inner white gap
              if (!story.isMe)
                Container(
                  width: 57.w, height: 57.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? const Color(0xFF0D0D0D) : Colors.white,
                  ),
                ),
              // Avatar circle
              Container(
                width: story.isMe ? 64.w : 52.w,
                height: story.isMe ? 64.w : 52.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: story.isMe
                    ? (isDark ? const Color(0xFF242424) : const Color(0xFFF0F0F0))
                    : story.ring.withOpacity(0.85),
                  border: story.isMe
                    ? Border.all(
                        color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
                        width: 1.5,
                      )
                    : null,
                ),
                child: story.isMe
                  ? Icon(Icons.add_rounded, color: AppColors.accent, size: 24.sp)
                  : Center(child: Text(story.emoji, style: TextStyle(fontSize: 22.sp))),
              ),
              // Live dot
              if (story.hasNew && !story.isMe)
                Positioned(
                  bottom: 2.h, right: 2.w,
                  child: Container(
                    width: 14.w, height: 14.w,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF0D0D0D) : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ]),
          ),
          SizedBox(height: 5.h),
          Text(
            story.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: story.hasNew ? FontWeight.w700 : FontWeight.w400,
              color: story.hasNew
                ? (isDark ? Colors.white : Colors.black.withOpacity(0.87))
                : (isDark ? Colors.white.withOpacity(0.38) : Colors.black.withOpacity(0.38)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Grid cell ─────────────────────────────────────────────────────────────────
class _GridCell extends StatelessWidget {
  final _FeedItem item;
  const _GridCell({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (item.isVideo) context.go(Routes.reels);
        else context.push(Routes.productDetail(item.id));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(fit: StackFit.expand, children: [
          // BG
          if (item.realPhotoUrl != null)
            CachedNetworkImage(
              imageUrl: item.realPhotoUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _GradBg(item: item),
            )
          else
            _GradBg(item: item),

          // Scrim
          Positioned(
            left: 0, right: 0, bottom: 0,
            height: 72.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                ),
              ),
            ),
          ),

          // Reel badge
          if (item.isVideo)
            Positioned(
              top: 7.h, left: 7.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.54),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 9.sp),
                  SizedBox(width: 1.w),
                  Text('REEL', style: TextStyle(color: Colors.white, fontSize: 7.5.sp, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ]),
              ),
            ),

          // Bottom info
          Positioned(
            left: 7.w, right: 7.w, bottom: 6.h,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              // Views
              Row(children: [
                Icon(Icons.remove_red_eye_outlined, color: Colors.white.withOpacity(0.45), size: 9.sp),
                SizedBox(width: 2.w),
                Text(item.views, style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 9.sp, fontWeight: FontWeight.w500)),
              ]),
              SizedBox(height: 2.h),
              // Price
              Text(item.price + ' сум', style: TextStyle(
                color: Colors.white,
                fontSize: 10.5.sp, fontWeight: FontWeight.w800,
                shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 6)],
              )),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _GradBg extends StatelessWidget {
  final _FeedItem item;
  const _GradBg({required this.item});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [item.color, const Color(0xFF050505)],
      ),
    ),
    child: Center(child: Text(item.emoji, style: TextStyle(fontSize: 36.sp))),
  );
}
