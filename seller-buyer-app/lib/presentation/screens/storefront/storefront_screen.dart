import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/format.dart';
import '../../widgets/product_card.dart';
import '../../../data/models/product/product_model.dart';

class StorefrontScreen extends StatefulWidget {
  final String sellerId;
  const StorefrontScreen({super.key, required this.sellerId});
  @override State<StorefrontScreen> createState() => _StorefrontScreenState();
}

class _StorefrontScreenState extends State<StorefrontScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _subscribed = false;

  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  // Mock data
  static final _mockProducts = List.generate(8, (i) => ProductModel(
    id: 'p$i', sellerId: 'seller_0', title: ['Платье летнее', 'Топ базовый', 'Брюки wide leg', 'Блуза шёлк', 'Джинсы mom', 'Юбка миди', 'Пальто oversize', 'Кардиган вязаный'][i],
    priceTiyin: [18500000, 9800000, 24000000, 32000000, 21000000, 14500000, 68000000, 27000000][i],
    oldPriceTiyin: i % 3 == 0 ? [23000000, 12000000, 30000000, null, 26000000, null, 85000000, null][i] : null,
    status: 'active', photos: [], createdAt: DateTime.now(),
    avgRating: [4.9, 4.7, 4.8, 4.6, 4.9, 4.5, 4.8, 4.7][i],
    reviewCount: [124, 67, 89, 45, 210, 38, 156, 72][i],
    soldCount: [340, 180, 210, 90, 560, 70, 420, 190][i],
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200.h,
            backgroundColor: AppColors.bgDark,
            foregroundColor: AppColors.textPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [AppColors.purple.withOpacity(0.3), AppColors.accent.withOpacity(0.2)],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(children: [
              // Profile row
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(width: 72.w, height: 72.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.accent, AppColors.purple]),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bgDark, width: 3),
                  ),
                  child: Center(child: Text('A', style: TextStyle(color: Colors.white, fontSize: 30.sp, fontWeight: FontWeight.w700, fontFamily: 'Playfair')))),
                SizedBox(width: 12.w),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('Aisha Fashion', style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700)),
                    SizedBox(width: 6.w),
                    const Icon(Icons.verified, color: AppColors.blue, size: 16),
                  ]),
                  Text('Женская одежда · Ташкент', style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp)),
                ])),
              ]),
              SizedBox(height: 12.h),

              // Stats
              Row(children: [
                _Stat('1.2K', 'Подписчиков'),
                _Stat('428', 'Товаров'),
                _Stat('4.9 ⭐', 'Рейтинг'),
                _Stat('8.4K', 'Продаж'),
              ]),
              SizedBox(height: 12.h),

              // Subscribe / Message
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => setState(() => _subscribed = !_subscribed),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: _subscribed ? Colors.transparent : AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: Center(child: Text(_subscribed ? 'Подписан ✓' : 'Подписаться',
                      style: TextStyle(color: _subscribed ? AppColors.accent : Colors.white,
                        fontSize: 13.sp, fontWeight: FontWeight.w600))),
                  ),
                )),
                SizedBox(width: 10.w),
                Container(width: 40.h, height: 40.h,
                  decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: IconButton(icon: const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.textSecondary), onPressed: () {})),
              ]),
              SizedBox(height: 4.h),
            ]),
          )),

          SliverPersistentHeader(
            pinned: true,
            delegate: _TabDelegate(TabBar(
              controller: _tab,
              indicatorColor: AppColors.accent,
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.textMuted,
              tabs: const [Tab(text: 'Товары'), Tab(text: 'Рилсы'), Tab(text: 'Отзывы')],
            )),
          ),
        ],
        body: TabBarView(controller: _tab, children: [
          // Products grid
          GridView.builder(
            padding: EdgeInsets.all(12.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10.w, mainAxisSpacing: 10.h, childAspectRatio: 0.68,
            ),
            itemCount: _mockProducts.length,
            itemBuilder: (_, i) => ProductCard(
              product: _mockProducts[i],
              onTap: () => context.push(Routes.productDetail(_mockProducts[i].id)),
            ),
          ),
          // Reels
          const Center(child: Text('🎬 Рилсы продавца', style: TextStyle(color: AppColors.textMuted, fontSize: 16))),
          // Reviews
          const Center(child: Text('⭐ Отзывы покупателей', style: TextStyle(color: AppColors.textMuted, fontSize: 16))),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w700)),
    Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 10.sp)),
  ]));
}

class _TabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabDelegate(this.tabBar);
  @override double get minExtent => tabBar.preferredSize.height;
  @override double get maxExtent => tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
    Container(color: AppColors.bgDark, child: tabBar);
  @override bool shouldRebuild(_) => false;
}
