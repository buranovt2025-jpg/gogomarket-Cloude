import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/format.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../../data/models/product/product_model.dart';

// Mock reel data (replaced by API when backend ready)
class _ReelItem {
  final String id, videoUrl, productId, productTitle, sellerName, sellerId;
  final int priceTiyin, likes, comments;
  final String? thumbnailUrl, sellerAvatarUrl;
  const _ReelItem({
    required this.id, required this.videoUrl, required this.productId,
    required this.productTitle, required this.sellerName, required this.sellerId,
    required this.priceTiyin, required this.likes, required this.comments,
    this.thumbnailUrl, this.sellerAvatarUrl,
  });
}

final _mockReels = List.generate(5, (i) => _ReelItem(
  id: 'reel_$i', videoUrl: '', productId: 'prod_$i',
  productTitle: ['Платье летнее Zara style', 'Кроссовки Nike Air Max', 'Помада матовая Rose', 'iPhone 14 чехол', 'Постельное бельё'][i],
  sellerName: ['Aisha Fashion', 'SneakerShop', 'BeautyUZ', 'TechAccessUZ', 'HomeStyle'][i],
  sellerId: 'seller_$i',
  priceTiyin: [18500000, 42000000, 8900000, 12000000, 15000000][i],
  likes: [1240, 890, 2100, 445, 778][i],
  comments: [48, 22, 91, 15, 33][i],
));

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _TabBtn('Все', true),
          SizedBox(width: 8.w),
          _TabBtn('Подписки', false),
        ]),
      ),
      body: PageView.builder(
        controller: _ctrl,
        scrollDirection: Axis.vertical,
        itemCount: _mockReels.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (_, i) => _ReelPage(
          reel: _mockReels[i],
          isActive: i == _current,
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
  final bool isActive, isLiked;
  final VoidCallback onLike;
  const _ReelPage({required this.reel, required this.isActive, required this.isLiked, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      // ── Video / placeholder ──────────────────────────────────────────
      Container(
        color: Colors.black,
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('🎬', style: TextStyle(fontSize: 64.sp)),
          SizedBox(height: 12.h),
          Text('Видео загружается...', style: TextStyle(color: Colors.white54, fontSize: 13.sp)),
        ])),
      ),

      // ── Gradient overlays ────────────────────────────────────────────
      Positioned(left: 0, right: 0, bottom: 0,
        child: DecoratedBox(decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            stops: const [0.5, 1.0],
          ),
        )),
      ),

      // ── Right actions ────────────────────────────────────────────────
      Positioned(right: 12.w, bottom: 120.h,
        child: Column(children: [
          // Seller avatar
          GestureDetector(
            onTap: () => context.push(Routes.storefront(reel.sellerId)),
            child: Stack(alignment: Alignment.bottomCenter, children: [
              Container(width: 44.w, height: 44.w, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.bgCard),
                child: Center(child: Text(reel.sellerName[0], style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18.sp)))),
              Positioned(bottom: -6, child: Container(width: 20, height: 20,
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white, size: 12))),
            ]),
          ),
          SizedBox(height: 20.h),

          // Like
          _ActionIcon(icon: isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? AppColors.red : Colors.white,
            label: '${reel.likes + (isLiked ? 1 : 0)}', onTap: onLike),
          SizedBox(height: 16.h),

          // Comment
          _ActionIcon(icon: Icons.chat_bubble_outline, label: '${reel.comments}', onTap: () {}),
          SizedBox(height: 16.h),

          // Share
          _ActionIcon(icon: Icons.share_outlined, label: 'Поделиться', onTap: () {}),
          SizedBox(height: 16.h),

          // Cart
          BlocBuilder<CartBloc, CartState>(
            builder: (ctx, state) {
              // Build a mock product just for cart operations
              final inCart = state.items.any((i) => i.product.id == reel.productId);
              return _ActionIcon(
                icon: inCart ? Icons.shopping_bag : Icons.shopping_bag_outlined,
                color: inCart ? AppColors.accent : Colors.white,
                label: 'В корзину',
                onTap: () {},
              );
            },
          ),
        ]),
      ),

      // ── Bottom info ──────────────────────────────────────────────────
      Positioned(left: 12.w, right: 70.w, bottom: 30.h,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Seller
          Row(children: [
            Text('@${reel.sellerName}', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
            SizedBox(width: 8.w),
            Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(border: Border.all(color: Colors.white54), borderRadius: BorderRadius.circular(20)),
              child: Text('Подписаться', style: TextStyle(color: Colors.white, fontSize: 10.sp))),
          ]),
          SizedBox(height: 6.h),
          Text(reel.productTitle, style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w500)),
          SizedBox(height: 10.h),

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
                    style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w500)),
                  Text(FormatUtils.priceTiyin(reel.priceTiyin ~/ 100),
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
}

class _ActionIcon extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap; final Color color;
  const _ActionIcon({required this.icon, required this.label, required this.onTap, this.color = Colors.white});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Icon(icon, color: color, size: 28.sp, shadows: [Shadow(color: Colors.black54, blurRadius: 8)]),
      SizedBox(height: 2.h),
      Text(label, style: TextStyle(color: Colors.white, fontSize: 11.sp, shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
    ]),
  );
}
