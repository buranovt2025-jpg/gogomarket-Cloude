import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/format.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../widgets/gogo_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: BlocBuilder<CartBloc, CartState>(
          builder: (_, s) => Text('Корзина (${s.totalQty})', style: const TextStyle(color: AppColors.textPrimary)),
        ),
        backgroundColor: AppColors.bgDark,
        foregroundColor: AppColors.textPrimary,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (ctx, s) => s.items.isNotEmpty
              ? TextButton(
                  onPressed: () => ctx.read<CartBloc>().add(CartClear()),
                  child: Text('Очистить', style: TextStyle(color: AppColors.red, fontSize: 13.sp)),
                )
              : const SizedBox(),
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (ctx, state) {
          if (state.items.isEmpty) return _Empty();
          return Column(children: [
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (_, i) => _CartItem(item: state.items[i]),
              ),
            ),
            _CheckoutBar(state: state),
          ]);
        },
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final CartItem item;
  const _CartItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        // Photo
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(width: 72.w, height: 72.w,
            child: item.product.photos.isNotEmpty
              ? CachedNetworkImage(imageUrl: item.product.photos.first.url, fit: BoxFit.cover)
              : Container(color: AppColors.bgSurface, child: const Icon(Icons.image_outlined, color: AppColors.textMuted))),
        ),
        SizedBox(width: 12.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.product.title,
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13.sp, fontWeight: FontWeight.w500)),
          SizedBox(height: 4.h),
          Text(FormatUtils.priceTiyin(item.product.priceTiyin),
            style: TextStyle(color: AppColors.accent, fontSize: 15.sp, fontWeight: FontWeight.w700)),
        ])),
        SizedBox(width: 8.w),
        // Qty controls
        Column(children: [
          _QtyBtn(Icons.add, () => context.read<CartBloc>().add(CartUpdate(item.product.id, item.qty + 1))),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Text('${item.qty}', style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w700)),
          ),
          _QtyBtn(item.qty > 1 ? Icons.remove : Icons.delete_outline,
            () => context.read<CartBloc>().add(CartUpdate(item.product.id, item.qty - 1)),
            color: item.qty <= 1 ? AppColors.red : null),
        ]),
      ]),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap; final Color? color;
  const _QtyBtn(this.icon, this.onTap, {this.color});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 28, height: 28,
      decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 16, color: color ?? AppColors.textSecondary)),
  );
}

class _CheckoutBar extends StatelessWidget {
  final CartState state;
  const _CheckoutBar({required this.state});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
    decoration: const BoxDecoration(
      color: AppColors.bgCard,
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('${state.totalQty} товаров', style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp)),
        Text(FormatUtils.priceTiyin(state.totalTiyin ~/ 100),
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700)),
      ]),
      SizedBox(height: 12.h),
      GogoButton(label: 'Оформить заказ', variant: ButtonVariant.primary, onPressed: () => context.push(Routes.orders)),
    ]),
  );
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text('🛒', style: TextStyle(fontSize: 56.sp)),
    SizedBox(height: 16.h),
    Text('Корзина пуста', style: TextStyle(color: AppColors.textSecondary, fontSize: 18.sp, fontWeight: FontWeight.w600)),
    SizedBox(height: 6.h),
    Text('Добавляйте товары из ленты', style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp)),
    SizedBox(height: 24.h),
    SizedBox(width: 200.w, child: GogoButton(label: 'В ленту', onPressed: () => context.go(Routes.feed))),
  ]));
}
