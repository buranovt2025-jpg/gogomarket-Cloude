import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/format.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() { super.initState(); _tab = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  static final _orders = [
    _Order('ORD-A4F2', 'Платье летнее Zara style', 'Aisha Fashion', 18500000, 'new',       DateTime.now().subtract(const Duration(hours: 2)),  'ord1'),
    _Order('ORD-B9C1', 'Кроссовки Nike Air Max',   'SneakerShop',   42000000, 'delivery',  DateTime.now().subtract(const Duration(hours: 8)),  'ord2'),
    _Order('ORD-C7D0', 'Помада матовая Rose',        'BeautyUZ',      8900000,  'done',      DateTime.now().subtract(const Duration(days: 2)),   'ord3'),
    _Order('ORD-D5E8', 'iPhone 14 Pro чехол',        'TechAccessUZ',  12000000, 'cancelled', DateTime.now().subtract(const Duration(days: 4)),   'ord4'),
    _Order('ORD-E2F1', 'Постельное бельё Premium',   'HomeStyle',     15000000, 'done',      DateTime.now().subtract(const Duration(days: 7)),   'ord5'),
  ];

  List<_Order> _filtered(String? status) => status == null
    ? _orders
    : _orders.where((o) => o.status == status).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text('Мои заказы', style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.bgDark,
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textMuted,
          isScrollable: true,
          tabs: const [Tab(text: 'Все'), Tab(text: 'Активные'), Tab(text: 'Доставлено'), Tab(text: 'Отменено')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _OrderList(orders: _filtered(null)),
          _OrderList(orders: _filtered('delivery')..addAll(_filtered('new')..addAll(_filtered('packed')))),
          _OrderList(orders: _filtered('done')),
          _OrderList(orders: _filtered('cancelled')),
        ],
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<_Order> orders;
  const _OrderList({required this.orders});
  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('📭', style: TextStyle(fontSize: 48.sp)),
      SizedBox(height: 12.h),
      Text('Нет заказов', style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp)),
    ]));
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: orders.length,
      itemBuilder: (_, i) => _OrderCard(order: orders[i]),
    );
  }
}

class _Order {
  final String num, title, seller, status, id;
  final int priceTiyin;
  final DateTime createdAt;
  const _Order(this.num, this.title, this.seller, this.priceTiyin, this.status, this.createdAt, this.id);
}

class _OrderCard extends StatelessWidget {
  final _Order order;
  const _OrderCard({required this.order});

  static const _statusMap = {
    'new':       ('Новый',      AppColors.blue),
    'confirmed': ('Подтверждён',AppColors.blue),
    'packed':    ('Упакован',   AppColors.orange),
    'delivery':  ('В пути 🛵',  AppColors.accent),
    'delivered': ('Доставлен',  AppColors.green),
    'done':      ('Завершён ✓', AppColors.green),
    'cancelled': ('Отменён',    AppColors.textMuted),
    'dispute':   ('Спор ⚠️',   AppColors.red),
  };

  @override
  Widget build(BuildContext context) {
    final (label, color) = _statusMap[order.status] ?? ('—', AppColors.textMuted);
    return GestureDetector(
      onTap: () => context.push(Routes.orderDetail(order.id)),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: order.status == 'delivery' ? AppColors.accent.withOpacity(0.4) : AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            Text(order.num, style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp, fontWeight: FontWeight.w500)),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
              child: Text(label, style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.w600)),
            ),
          ]),
          SizedBox(height: 8.h),

          // Product
          Text(order.title, style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
          SizedBox(height: 4.h),
          Text(order.seller, style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp)),
          SizedBox(height: 10.h),

          // Footer
          Row(children: [
            Text(FormatUtils.priceTiyin(order.priceTiyin ~/ 100), style: TextStyle(color: AppColors.textPrimary, fontSize: 15.sp, fontWeight: FontWeight.w700)),
            const Spacer(),
            if (order.status == 'delivery')
              GestureDetector(
                onTap: () => context.push(Routes.tracking(order.id)),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.accent.withOpacity(0.3))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.location_on, color: AppColors.accent, size: 14),
                    SizedBox(width: 4.w),
                    Text('Отследить', style: TextStyle(color: AppColors.accent, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                  ]),
                ),
              )
            else
              Text(FormatUtils.timeAgo(order.createdAt), style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
          ]),
        ]),
      ),
    );
  }
}
