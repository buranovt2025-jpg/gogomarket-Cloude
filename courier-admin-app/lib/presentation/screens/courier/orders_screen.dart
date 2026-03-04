import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/courier/courier_bloc.dart';
import '../../../data/models/courier_order_model.dart';

class CourierOrdersScreen extends StatelessWidget {
  const CourierOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CourierBloc>()..add(CourierLoadOrders()),
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          title: const Text('Доступные заказы'),
          backgroundColor: AppColors.bgDark,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.green.withOpacity(0.4)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                const Text('Онлайн', style: TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
        ),
        body: BlocBuilder<CourierBloc, CourierState>(
          builder: (ctx, state) {
            if (state.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.green));
            if (state.availableOrders.isEmpty) {
              return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('📭', style: TextStyle(fontSize: 48)),
                SizedBox(height: 16),
                Text('Нет доступных заказов', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              ]));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.availableOrders.length,
              itemBuilder: (_, i) => _OrderCard(order: state.availableOrders[i]),
            );
          },
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final CourierOrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(width: 52, height: 52, child: order.productPhotoUrl != null
              ? CachedNetworkImage(imageUrl: order.productPhotoUrl!, fit: BoxFit.cover)
              : Container(color: AppColors.bgSurface, child: const Icon(Icons.inventory_2, color: AppColors.textMuted))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(order.productTitle, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(order.buyerName, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.green.withOpacity(0.3))),
            child: Text('+${FormatUtils.price(order.feeSum)}', style: const TextStyle(color: AppColors.green, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          const Text('🏪', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Expanded(child: Text(order.sellerAddress, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          const Text('📍', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Expanded(child: Text(order.deliveryAddress, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _Chip('${order.distanceKm.toStringAsFixed(1)} км', AppColors.blue),
          const SizedBox(width: 8),
          _Chip('~${order.etaMinutes} мин', AppColors.orange),
          const Spacer(),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                context.read<CourierBloc>().add(CourierAcceptOrder(order.id));
                context.go(Routes.activeDelivery.replaceFirst(':orderId', order.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Принять', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text; final Color color;
  const _Chip(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}
