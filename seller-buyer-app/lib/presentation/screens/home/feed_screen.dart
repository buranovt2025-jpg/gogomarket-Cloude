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

// ─────────────────────────────────────────────────────────────────────────────
// Mock feed items (products + reels mixed)
// ─────────────────────────────────────────────────────────────────────────────
class _FeedItem {
  final String id, title, seller, price, views;
  final bool isVideo;
  final Color color;
  final String emoji;
  const _FeedItem({required this.id, required this.title, required this.seller,
    required this.price, required this.views, required this.isVideo,
    required this.color, required this.emoji});
}

final _mockItems = [
  _FeedItem(id:'r1', title:'Платье летнее Zara style 🌸', seller:'Aisha Fashion', price:'185 000', views:'12,4 тыс', isVideo:true,  color:const Color(0xFF1A1040), emoji:'👗'),
  _FeedItem(id:'p9', title:'Сыворотка Vitamin C', seller:'Kamola Beauty', price:'189 000', views:'21 тыс',   isVideo:false, color:const Color(0xFF301020), emoji:'💄'),
  _FeedItem(id:'r3', title:'Наушники TWS обзор 🎧', seller:'TechZone UZ', price:'380 000', views:'8,9 тыс',  isVideo:true,  color:const Color(0xFF0D2030), emoji:'🎧'),
  _FeedItem(id:'p5', title:'Джинсы mom fit синие', seller:'Aisha Fashion', price:'210 000', views:'5,6 тыс',  isVideo:false, color:const Color(0xFF1A2010), emoji:'👖'),
  _FeedItem(id:'r4', title:'Утренняя тренировка 💪', seller:'Sport Life', price:'145 000', views:'15,6 тыс', isVideo:true,  color:const Color(0xFF0D2010), emoji:'🏋️'),
  _FeedItem(id:'p11', title:'Палетка теней Nude', seller:'Kamola Beauty', price:'240 000', views:'3,2 тыс',  isVideo:false, color:const Color(0xFF301525), emoji:'👁️'),
  _FeedItem(id:'r6', title:'Пальто оверсайз — 5 образов', seller:'Aisha Fashion', price:'680 000', views:'32 тыс',  isVideo:true,  color:const Color(0xFF251A10), emoji:'🧥'),
  _FeedItem(id:'p14', title:'Наушники TWS Pro ANC', seller:'TechZone UZ', price:'380 000', views:'4,1 тыс',  isVideo:false, color:const Color(0xFF102030), emoji:'🎵'),
  _FeedItem(id:'r7', title:'Макияж за 5 минут 💄', seller:'Kamola Beauty', price:'240 000', views:'45 тыс',  isVideo:true,  color:const Color(0xFF300A20), emoji:'💋'),
  _FeedItem(id:'p22', title:'Свеча соя Ваниль', seller:'Home Comfort', price:'85 000', views:'9,3 тыс',  isVideo:false, color:const Color(0xFF201510), emoji:'🕯️'),
  _FeedItem(id:'r8', title:'Смарт-часы GT4 ⌚', seller:'TechZone UZ', price:'520 000', views:'11 тыс',  isVideo:true,  color:const Color(0xFF102040), emoji:'⌚'),
  _FeedItem(id:'p7', title:'Пальто oversize бежевое', seller:'Aisha Fashion', price:'680 000', views:'34 тыс',  isVideo:false, color:const Color(0xFF252015), emoji:'🧣'),
  _FeedItem(id:'r2', title:'Результат за 7 дней ✨', seller:'Kamola Beauty', price:'189 000', views:'21 тыс',  isVideo:true,  color:const Color(0xFF2A1020), emoji:'🌟'),
  _FeedItem(id:'p19', title:'Кроссовки для бега', seller:'Sport Life', price:'380 000', views:'28 тыс',  isVideo:false, color:const Color(0xFF101530), emoji:'👟'),
  _FeedItem(id:'r5', title:'Уютный вечер дома 🕯️', seller:'Home Comfort', price:'85 000', views:'7,8 тыс',  isVideo:true,  color:const Color(0xFF201510), emoji:'🏠'),
  _FeedItem(id:'p13', title:'Парфюм Rose Musk 50ml', seller:'Kamola Beauty', price:'450 000', views:'52 тыс',  isVideo:false, color:const Color(0xFF300A20), emoji:'🌸'),
  _FeedItem(id:'p20', title:'Коврик для йоги 6мм', seller:'Sport Life', price:'120 000', views:'4,2 тыс',  isVideo:false, color:const Color(0xFF0A2010), emoji:'🧘'),
  _FeedItem(id:'p15', title:'Смарт-часы GT4', seller:'TechZone UZ', price:'520 000', views:'3,2 тыс',  isVideo:false, color:const Color(0xFF0A1020), emoji:'📱'),
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
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
  final _cats = ['Все', 'Одежда', 'Обувь', 'Красота', 'Техника', 'Дом', 'Спорт'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ──────────────────────────────────────────────
          SliverAppBar(
            pinned: true, floating: true, snap: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor, elevation: 0,
            titleSpacing: 14.w,
            title: Row(children: [
              RichText(text: TextSpan(children: [
                TextSpan(text: 'Gogo', style: TextStyle(color: AppColors.accent, fontSize: 22.sp, fontWeight: FontWeight.w800)),
                TextSpan(text: 'Market', style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w800)),
              ])),
              const Spacer(),
              IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () => context.push(Routes.search)),
              IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
            ]),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(80.h),
              child: Column(children: [
                // Stories
                SizedBox(height: 44.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    itemCount: 9,
                    itemBuilder: (_, i) {
                      final stories = [
                        ['➕','Мой'], ['👗','Aisha'], ['💄','Kamola'], ['📱','TechZone'],
                        ['🏋️','Sport'], ['🕯️','Home'], ['👟','Sneaker'], ['✨','Beauty'], ['🔥','Новинки'],
                      ];
                      final s = stories[i];
                      final isAdd = i == 0;
                      return GestureDetector(
                        onTap: () {},
                        child: Container(
                          margin: EdgeInsets.only(right: 8.w),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Container(
                              width: 34.w, height: 34.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isAdd ? null : const LinearGradient(
                                  colors: [AppColors.accent, Color(0xFFFF6B35)],
                                ),
                                color: isAdd ? const Color(0xFF222222) : null,
                                border: isAdd ? Border.all(color: const Color(0xFF444444), width: 1.5) : null,
                              ),
                              child: Center(child: Text(s[0], style: TextStyle(fontSize: 16.sp))),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
                // Categories
                SizedBox(height: 36.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    itemCount: _cats.length,
                    itemBuilder: (_, i) {
                      final on = i == _catIdx;
                      return GestureDetector(
                        onTap: () => setState(() => _catIdx = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: EdgeInsets.only(right: 6.w),
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: on ? AppColors.accent : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(_cats[i], style: TextStyle(
                            color: on ? Colors.black : Colors.white60,
                            fontSize: 11.sp, fontWeight: on ? FontWeight.w700 : FontWeight.normal,
                          )),
                        ),
                      );
                    },
                  ),
                ),
              ]),
            ),
          ),

          // ── 3-column grid ─────────────────────────────────────────
          BlocBuilder<FeedBloc, FeedState>(
            builder: (ctx, state) {
              // Merge server products into mock items if loaded
              List<_FeedItem> items = _mockItems;

              if (state is FeedLoaded && state.products.isNotEmpty) {
                // Insert real products as non-video items at the top
                final realItems = state.products.take(6).map((p) => _FeedItem(
                  id: p.id, title: p.title, seller: p.sellerName ?? 'Продавец',
                  price: FormatUtils.priceTiyin(p.priceTiyin),
                  views: _fmtV(p.viewCount), isVideo: false,
                  color: const Color(0xFF1A1A1A), emoji: '🛍️',
                )).toList();
                // Interleave: real item every 3 mock items
                final merged = <_FeedItem>[];
                int ri = 0, mi = 0;
                while (mi < _mockItems.length) {
                  if (ri < realItems.length && mi % 3 == 0) {
                    merged.add(realItems[ri++]);
                  }
                  merged.add(_mockItems[mi++]);
                }
                items = merged;
              }

              return SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _GridCell(item: items[i % items.length]),
                  childCount: items.length + 6, // extra rows
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  childAspectRatio: 0.65,
                ),
              );
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: 80.h)),
        ],
      ),
    );
  }

  static String _fmtV(int v) {
    if (v >= 1000000) return '${(v/1000000).toStringAsFixed(1)} млн';
    if (v >= 1000) return '${(v/1000).toStringAsFixed(1)} тыс';
    return '$v';
  }
}

// ── Single grid cell ──────────────────────────────────────────────────────────
class _GridCell extends StatelessWidget {
  final _FeedItem item;
  const _GridCell({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.isVideo) context.go(Routes.reels);
        else context.push(Routes.productDetail(item.id));
      },
      child: Stack(fit: StackFit.expand, children: [
        // Background — gradient + emoji
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [item.color, Colors.black],
            ),
          ),
          child: Center(
            child: Text(item.emoji, style: TextStyle(fontSize: 44.sp)),
          ),
        ),

        // Video play indicator (top-left)
        if (item.isVideo)
          Positioned(top: 6.h, left: 6.w,
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 18,
              shadows: const [Shadow(color: Colors.black, blurRadius: 6)])),

        // Bottom gradient
        Positioned(left: 0, right: 0, bottom: 0, height: 70.h,
          child: DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.92)],
            ),
          )),
        ),

        // Views count (bottom-left)
        Positioned(left: 5.w, bottom: 26.h,
          child: Row(children: [
            Icon(Icons.play_arrow, color: Colors.white70, size: 11.sp),
            SizedBox(width: 2.w),
            Text(item.views, style: TextStyle(
              color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w600,
              shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
            )),
          ]),
        ),

        // Price (bottom-left, below views)
        Positioned(left: 5.w, bottom: 8.h,
          child: Text(item.price, style: TextStyle(
            color: AppColors.accent, fontSize: 11.sp, fontWeight: FontWeight.w800,
            shadows: const [Shadow(color: Colors.black, blurRadius: 6)],
          )),
        ),

        // Seller name (bottom-right, small)
        Positioned(right: 4.w, bottom: 8.h,
          child: Text(item.seller.split(' ').first, style: TextStyle(
            color: Colors.white38, fontSize: 8.sp,
          )),
        ),
      ]),
    );
  }
}
