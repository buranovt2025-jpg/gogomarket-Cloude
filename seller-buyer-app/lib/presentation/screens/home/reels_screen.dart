import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/format.dart';
import '../../blocs/cart/cart_bloc.dart';

class _ReelItem {
  final String id, productId, productTitle, sellerName, sellerId;
  final int priceTiyin, likes, comments;
  final Color bgColor;
  final String emoji;
  const _ReelItem({
    required this.id, required this.productId, required this.productTitle,
    required this.sellerName, required this.sellerId,
    required this.priceTiyin, required this.likes, required this.comments,
    required this.bgColor, required this.emoji,
  });
}

final _mockReels = [
  _ReelItem(id: '1', productId: 'p0', productTitle: 'Платье летнее Zara style', sellerName: 'Aisha Fashion',
    sellerId: 's0', priceTiyin: 18500000, likes: 1240, comments: 48,
    bgColor: const Color(0xFF1A1040), emoji: '👗'),
  _ReelItem(id: '2', productId: 'p1', productTitle: 'Кроссовки Nike Air Max', sellerName: 'SneakerShop',
    sellerId: 's1', priceTiyin: 42000000, likes: 890, comments: 22,
    bgColor: const Color(0xFF0D2030), emoji: '👟'),
  _ReelItem(id: '3', productId: 'p2', productTitle: 'Помада матовая Rose', sellerName: 'BeautyUZ',
    sellerId: 's2', priceTiyin: 8900000, likes: 2100, comments: 91,
    bgColor: const Color(0xFF301020), emoji: '💄'),
  _ReelItem(id: '4', productId: 'p3', productTitle: 'iPhone 14 чехол', sellerName: 'TechUZ',
    sellerId: 's3', priceTiyin: 12000000, likes: 445, comments: 15,
    bgColor: const Color(0xFF102030), emoji: '📱'),
  _ReelItem(id: '5', productId: 'p4', productTitle: 'Постельное бельё premium', sellerName: 'HomeStyle',
    sellerId: 's4', priceTiyin: 15000000, likes: 778, comments: 33,
    bgColor: const Color(0xFF102020), emoji: '🏠'),
];

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});
  @override State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final _ctrl = PageController();
  int _current = 0;
  final Set<String> _liked = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _TabBtn('Все', true), SizedBox(width: 8.w), _TabBtn('Подписки', false),
        ]),
      ),
      body: PageView.builder(
        controller: _ctrl,
        scrollDirection: Axis.vertical,
        itemCount: _mockReels.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (_, i) => _ReelPage(
          reel: _mockReels[i],
          isLiked: _liked.contains(_mockReels[i].id),
          onLike: () => setState(() {
            if (_liked.contains(_mockReels[i].id)) _liked.remove(_mockReels[i].id);
            else _liked.add(_mockReels[i].id);
          }),
        ),
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label; final bool active;
  const _TabBtn(this.label, this.active);
  @override
  Widget build(BuildContext context) => Text(label, style: TextStyle(
    color: active ? Colors.white : Colors.white54,
    fontSize: 15.sp, fontWeight: active ? FontWeight.w700 : FontWeight.normal,
  ));
}

class _ReelPage extends StatelessWidget {
  final _ReelItem reel;
  final bool isLiked;
  final VoidCallback onLike;
  const _ReelPage({required this.reel, required this.isLiked, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [

      // ── Background ──────────────────────────────────────────────────
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [reel.bgColor, Colors.black],
          ),
        ),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(reel.emoji, style: TextStyle(fontSize: 100.sp)),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.play_circle_outline, color: Colors.white54, size: 20.sp),
              SizedBox(width: 8.w),
              Text('Видео скоро', style: TextStyle(color: Colors.white54, fontSize: 13.sp)),
            ]),
          ),
        ])),
      ),

      // ── Bottom gradient ─────────────────────────────────────────────
      Positioned(left: 0, right: 0, bottom: 0, height: 300.h,
        child: DecoratedBox(decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
          ),
        )),
      ),

      // ── Right actions ────────────────────────────────────────────────
      Positioned(right: 12.w, bottom: 120.h,
        child: Column(children: [
          // Avatar
          GestureDetector(
            onTap: () => context.push(Routes.storefront(reel.sellerId)),
            child: Stack(alignment: Alignment.bottomCenter, clipBehavior: Clip.none, children: [
              Container(
                width: 46.w, height: 46.w,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.bgCard),
                child: Center(child: Text(reel.sellerName[0],
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18.sp))),
              ),
              Positioned(bottom: -8, child: Container(
                width: 20, height: 20,
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white, size: 12),
              )),
            ]),
          ),
          SizedBox(height: 22.h),

          _ActionBtn(icon: isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? AppColors.red : Colors.white,
            label: _fmt(reel.likes + (isLiked ? 1 : 0)), onTap: onLike),
          SizedBox(height: 18.h),

          _ActionBtn(icon: Icons.chat_bubble_outline, label: _fmt(reel.comments), onTap: () {}),
          SizedBox(height: 18.h),

          _ActionBtn(icon: Icons.share_outlined, label: 'Поделиться', onTap: () {}),
          SizedBox(height: 18.h),

          BlocBuilder<CartBloc, CartState>(builder: (ctx, state) {
            final inCart = state.items.any((i) => i.product.id == reel.productId);
            return _ActionBtn(
              icon: inCart ? Icons.shopping_bag : Icons.shopping_bag_outlined,
              color: inCart ? AppColors.accent : Colors.white,
              label: 'Корзина', onTap: () {},
            );
          }),
        ]),
      ),

      // ── Bottom info ──────────────────────────────────────────────────
      Positioned(left: 16.w, right: 72.w, bottom: 28.h,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('@${reel.sellerName}',
              style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white54),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('+ Подписаться', style: TextStyle(color: Colors.white, fontSize: 10.sp)),
            ),
          ]),
          SizedBox(height: 6.h),
          Text(reel.productTitle,
            style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w500)),
          SizedBox(height: 12.h),

          // Product card
          GestureDetector(
            onTap: () => context.push(Routes.productDetail(reel.productId)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('🛍️', style: TextStyle(fontSize: 18.sp)),
                SizedBox(width: 8.w),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(reel.productTitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 12.sp)),
                  Text(FormatUtils.priceTiyin(reel.priceTiyin),
                    style: TextStyle(color: AppColors.accent, fontSize: 14.sp, fontWeight: FontWeight.w700)),
                ]),
                SizedBox(width: 10.w),
                const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 12),
              ]),
            ),
          ),
        ]),
      ),
    ]);
  }

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';
}

class _ActionBtn extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap; final Color color;
  const _ActionBtn({required this.icon, required this.label, required this.onTap, this.color = Colors.white});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Icon(icon, color: color, size: 30.sp,
        shadows: const [Shadow(color: Colors.black54, blurRadius: 8)]),
      SizedBox(height: 3.h),
      Text(label, style: TextStyle(color: Colors.white, fontSize: 11.sp,
        shadows: const [Shadow(color: Colors.black54, blurRadius: 4)])),
    ]),
  );
}
