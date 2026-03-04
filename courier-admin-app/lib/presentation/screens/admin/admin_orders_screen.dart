import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/format_utils.dart';
import '../../blocs/admin/admin_bloc.dart';
import '../../../data/models/admin/admin_order_model.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});
  @override State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String? _filter;

  static const _filters = [null, 'dispute', 'new', 'delivery', 'done', 'cancelled'];
  static const _labels  = ['Все', 'Споры', 'Новые', 'В пути', 'Завершены', 'Отменены'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminBloc>()..add(AdminLoadOrders(status: _filter)),
      child: Builder(builder: (ctx) => Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(title: const Text('Заказы'), backgroundColor: AppColors.bgDark),
        body: Column(children: [
          // Filter chips
          SizedBox(height: 48, child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            itemBuilder: (_, i) {
              final selected = _filter == _filters[i];
              return Padding(
                padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _filter = _filters[i]);
                    ctx.read<AdminBloc>().add(AdminLoadOrders(status: _filters[i]));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.purple : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AppColors.purple : AppColors.border),
                    ),
                    child: Center(child: Text(_labels[i],
                      style: TextStyle(color: selected ? Colors.white : AppColors.textMuted,
                        fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.normal))),
                  ),
                ),
              );
            },
          )),
          Expanded(child: BlocBuilder<AdminBloc, AdminState>(
            builder: (_, state) {
              if (state.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.purple));
              if (state.orders.isEmpty) return const Center(child: Text('Нет заказов', style: TextStyle(color: AppColors.textSecondary)));
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.orders.length,
                itemBuilder: (_, i) => _OrderRow(order: state.orders[i]),
              );
            },
          )),
        ]),
      )),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final AdminOrderModel order;
  const _OrderRow({required this.order});

  Color get _statusColor => switch (order.status) {
    'new'       => AppColors.blue,
    'delivery'  => AppColors.orange,
    'done'      => AppColors.green,
    'cancelled' => AppColors.textMuted,
    'dispute'   => AppColors.red,
    _           => AppColors.purple,
  };

  String get _statusLabel => switch (order.status) {
    'new'       => 'Новый',
    'confirmed' => 'Подтверждён',
    'packed'    => 'Упакован',
    'delivery'  => 'В пути',
    'delivered' => 'Доставлен',
    'done'      => 'Завершён',
    'cancelled' => 'Отменён',
    'dispute'   => '⚠️ Спор',
    _           => order.status,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: order.status == 'dispute' ? AppColors.red.withOpacity(0.4) : AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('#${order.id.substring(order.id.length - 6).toUpperCase()}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: _statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _statusColor.withOpacity(0.3))),
            child: Text(_statusLabel, style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(order.productTitle, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Row(children: [
          Text('${order.buyerName} → ${order.sellerName}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const Spacer(),
          Text(FormatUtils.priceTiyin(order.totalTiyin),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }
}
