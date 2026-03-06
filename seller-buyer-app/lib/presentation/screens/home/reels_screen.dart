import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/format.dart';
import '../../blocs/cart/cart_bloc.dart';

class _Reel {
  final String id, productId, title, seller, sellerId;
  final int price, likes, comments;
  final Color color;
  final String emoji;
  const _Reel({required this.id, required this.productId, required this.title,
    required this.seller, required this.sellerId, required this.price,
    required this.likes, required this.comments, required this.color, required this.emoji});
}

final _reels = [
  _Reel(id:'1', productId:'p0', title:'Платье летнее Zara style', seller:'Aisha Fashion', sellerId:'s0', price:18500000, likes:1240, comments:48, color:const Color(0xFF1A1040), emoji:'👗'),
  _Reel(id:'2', productId:'p1', title:'Кроссовки Nike Air Max', seller:'SneakerShop', sellerId:'s1', price:42000000, likes:890, comments:22, color:const Color(0xFF0D2030), emoji:'👟'),
  _Reel(id:'3', productId:'p2', title:'Помада матовая Rose', seller:'BeautyUZ', sellerId:'s2', price:8900000, likes:2100, comments:91, color:const Color(0xFF301020), emoji:'💄'),
  _Reel(id:'4', productId:'p3', title:'iPhone 14 чехол', seller:'TechUZ', sellerId:'s3', price:12000000, likes:445, comments:15, color:const Color(0xFF102030), emoji:'📱'),
  _Reel(id:'5', productId:'p4', title:'Постельное бельё', seller:'HomeStyle', sellerId:'s4', price:15000000, likes:778, comments:33, color:const Color(0xFF102020), emoji:'🏠'),
];

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});
  @override State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final _ctrl = PageController();
  int _cur = 0;
  final Set<String> _liked = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _Tab('Все', true), SizedBox(width: 8.w), _Tab('Подписки', false),
        ]),
      ),
      body: PageView.builder(
        controller: _ctrl,
        scrollDirection: Axis.vertical,
        itemCount: _reels.length,
        onPageChanged: (i) => setState(() => _cur = i),
        itemBuilder: (_, i) => _ReelPage(
          reel: _reels[i],
          isLiked: _liked.contains(_reels[i].id),
          onLike: () => setState(() {
            _liked.contains(_reels[i].id) ? _liked.remove(_reels[i].id) : _liked.add(_reels[i].id);
          }),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String t; final bool a;
  const _Tab(this.t, this.a);
  @override Widget build(BuildContext context) => Text(t, style: TextStyle(
    color: a ? Colors.white : Colors.white54, fontSize: 15.sp,
    fontWeight: a ? FontWeight.w700 : FontWeight.normal,
  ));
}

class _ReelPage extends StatelessWidget {
  final _Reel reel; final bool isLiked; final VoidCallback onLike;
  const _ReelPage({required this.reel, required this.isLiked, required this.onLike});

  String _n(int n) => n >= 1000 ? '${(n/1000).toStringAsFixed(1)}K' : '$n';

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      // BG
      Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [reel.color, Colors.black],
        )),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(reel.emoji, style: TextStyle(fontSize: 96.sp)),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.play_circle_outline, color: Colors.white38, size: 16.sp),
              SizedBox(width: 6.w),
              Text('Видео скоро', style: TextStyle(color: Colors.white38, fontSize: 12.sp)),
            ]),
          ),
        ])),
      ),

      // Gradient bottom
      Positioned(left:0, right:0, bottom:0, height: 280.h,
        child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
        ))),
      ),

      // Right actions
      Positioned(right: 12.w, bottom: 100.h,
        child: Column(children: [
          GestureDetector(
            onTap: () => context.push(Routes.storefront(reel.sellerId)),
            child: Stack(alignment: Alignment.bottomCenter, clipBehavior: Clip.none, children: [
              Container(width: 44.w, height: 44.w,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.bgCard),
                child: Center(child: Text(reel.seller[0],
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18.sp)))),
              Positioned(bottom: -8, child: Container(width: 18, height: 18,
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white, size: 11))),
            ]),
          ),
          SizedBox(height: 20.h),
          _Btn(icon: isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? AppColors.red : Colors.white, label: _n(reel.likes + (isLiked?1:0)), onTap: onLike),
          SizedBox(height: 16.h),
          _Btn(icon: Icons.chat_bubble_outline, label: _n(reel.comments), onTap: (){}),
          SizedBox(height: 16.h),
          _Btn(icon: Icons.share_outlined, label: 'Поделиться', onTap: (){}),
          SizedBox(height: 16.h),
          BlocBuilder<CartBloc, CartState>(builder: (ctx, s) {
            final inCart = s.items.any((i) => i.product.id == reel.productId);
            return _Btn(icon: inCart ? Icons.shopping_bag : Icons.shopping_bag_outlined,
              color: inCart ? AppColors.accent : Colors.white, label: 'Корзина', onTap: (){});
          }),
        ]),
      ),

      // Bottom info
      Positioned(left: 14.w, right: 70.w, bottom: 20.h,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('@${reel.seller}', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
            SizedBox(width: 8.w),
            Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
              decoration: BoxDecoration(border: Border.all(color: Colors.white54), borderRadius: BorderRadius.circular(20)),
              child: Text('+ Подписаться', style: TextStyle(color: Colors.white, fontSize: 10.sp))),
          ]),
          SizedBox(height: 6.h),
          Text(reel.title, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500)),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () => context.push(Routes.productDetail(reel.productId)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('🛍️', style: TextStyle(fontSize: 16.sp)),
                SizedBox(width: 8.w),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(reel.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 11.sp)),
                  Text(FormatUtils.priceTiyin(reel.price),
                    style: TextStyle(color: AppColors.accent, fontSize: 13.sp, fontWeight: FontWeight.w700)),
                ]),
                SizedBox(width: 8.w),
                const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 11),
              ]),
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _Btn extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap; final Color color;
  const _Btn({required this.icon, required this.label, required this.onTap, this.color = Colors.white});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Icon(icon, color: color, size: 28.sp, shadows: const [Shadow(color: Colors.black54, blurRadius: 8)]),
      SizedBox(height: 2.h),
      Text(label, style: TextStyle(color: Colors.white, fontSize: 11.sp,
        shadows: const [Shadow(color: Colors.black54, blurRadius: 4)])),
    ]),
  );
}
