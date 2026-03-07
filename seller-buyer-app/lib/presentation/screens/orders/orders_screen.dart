import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/format.dart';

// ── Модель ───────────────────────────────────────────────────────────────────
class OrderModel {
  final String id, shortId, productTitle, sellerName, status;
  final int totalTiyin;
  final DateTime createdAt;
  final String? trackingStep;

  OrderModel({required this.id, required this.shortId, required this.productTitle,
    required this.sellerName, required this.status, required this.totalTiyin,
    required this.createdAt, this.trackingStep});

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
    id:           j['id'] as String,
    shortId:      (j['id'] as String).substring(0, 8).toUpperCase(),
    productTitle: (j['items'] as List?)?.firstOrNull?['title'] as String? ?? 'Заказ',
    sellerName:   j['sellerName'] as String? ?? 'Магазин',
    status:       j['status'] as String? ?? 'new',
    totalTiyin:   (j['totalTiyin'] as num?)?.toInt() ?? 0,
    createdAt:    DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

// ── Экран ────────────────────────────────────────────────────────────────────
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override State<OrdersScreen> createState() => _State();
}

class _State extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<OrderModel> _all = [];
  bool _loading = true;

  static const _tabs = [
    (null,        'Все'),
    ('active',    'Активные'),
    ('done',      'Выполнен'),
    ('cancelled', 'Отменён'),
  ];

  @override void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
    _load();
  }
  @override void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final res = await getIt<ApiClient>().getMyOrders();
      setState(() {
        _all = res.map((j) => OrderModel.fromJson(Map<String,dynamic>.from(j))).toList();
        _loading = false;
      });
    } catch (_) {
      // Fallback mock
      setState(() {
        _all = [
          OrderModel(id: 'ord-1234-abcd', shortId: 'ORD-1234', productTitle: 'Платье летнее Zara style',
            sellerName: 'Aisha Fashion', status: 'delivery', totalTiyin: 18500000, createdAt: DateTime.now().subtract(const Duration(hours: 3))),
          OrderModel(id: 'ord-5678-efgh', shortId: 'ORD-5678', productTitle: 'Кроссовки Nike Air Max',
            sellerName: 'SneakerShop', status: 'confirmed', totalTiyin: 42000000, createdAt: DateTime.now().subtract(const Duration(hours: 8))),
          OrderModel(id: 'ord-9abc-ijkl', shortId: 'ORD-9ABC', productTitle: 'iPhone 14 Pro чехол',
            sellerName: 'TechAccess', status: 'done', totalTiyin: 12000000, createdAt: DateTime.now().subtract(const Duration(days: 2))),
        ];
        _loading = false;
      });
    }
  }

  List<OrderModel> _filtered(String? status) {
    if (status == null) return _all;
    if (status == 'active') return _all.where((o) => ['new','confirmed','packed','delivery'].contains(o.status)).toList();
    return _all.where((o) => o.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Мои заказы'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.accent,
          tabs: _tabs.map((t) => Tab(text: t.$2)).toList(),
        ),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
        : TabBarView(
            controller: _tab,
            children: _tabs.map((t) => _OrderList(
              orders: _filtered(t.$1),
              onRefresh: _load,
            )).toList(),
          ),
    );
  }
}

// ── Список заказов ────────────────────────────────────────────────────────────
class _OrderList extends StatelessWidget {
  final List<OrderModel> orders;
  final Future<void> Function() onRefresh;
  const _OrderList({required this.orders, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('📦', style: TextStyle(fontSize: 56.sp)),
        SizedBox(height: 12.h),
        Text('Заказов нет', style: TextStyle(fontSize: 16.sp, color: AppColors.textMuted)),
      ]),
    );

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: orders.length,
        itemBuilder: (_, i) => _OrderCard(order: orders[i]),
      ),
    );
  }
}

// ── Карточка заказа ───────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  static const _statusLabel = {
    'new':       'Новый',
    'confirmed': 'Подтверждён',
    'packed':    'Упакован',
    'delivery':  'В доставке',
    'done':      'Выполнен',
    'cancelled': 'Отменён',
    'dispute':   'Спор',
  };

  static const _statusColor = {
    'new':       Color(0xFF1F87E8),
    'confirmed': Color(0xFF9C27B0),
    'packed':    Color(0xFFFF9800),
    'delivery':  AppColors.accent,
    'done':      AppColors.green,
    'cancelled': AppColors.red,
    'dispute':   AppColors.red,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _statusColor[order.status] ?? AppColors.textMuted;

    return GestureDetector(
      onTap: () => context.push('/order/${order.id}'),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBgCard : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0,2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            Text('#${order.shortId}', style: TextStyle(
              fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(_statusLabel[order.status] ?? order.status,
                style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.w700)),
            ),
          ]),
          SizedBox(height: 10.h),

          // Product
          Text(order.productTitle, style: TextStyle(
            fontSize: 15.sp, fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.titleMedium?.color)),
          SizedBox(height: 2.h),
          Text(order.sellerName, style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted)),
          SizedBox(height: 12.h),

          // Трекинг — только для активных
          if (['confirmed','packed','delivery'].contains(order.status)) ...[
            _TrackingBar(status: order.status),
            SizedBox(height: 12.h),
          ],

          // Footer
          Row(children: [
            Text(FormatUtils.priceTiyin(order.totalTiyin),
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColors.accent)),
            const Spacer(),
            Text(FormatUtils.dateShort(order.createdAt),
              style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted)),
            SizedBox(width: 4.w),
            Icon(Icons.arrow_forward_ios, size: 12.sp, color: AppColors.textMuted),
          ]),
        ]),
      ),
    );
  }
}

// ── Трекинг-бар ──────────────────────────────────────────────────────────────
class _TrackingBar extends StatelessWidget {
  final String status;
  const _TrackingBar({required this.status});

  static const _steps = [
    ('confirmed', 'Подтверждён', Icons.check_circle_outline),
    ('packed',    'Упакован',    Icons.inventory_2_outlined),
    ('delivery',  'В пути',      Icons.local_shipping_outlined),
    ('done',      'Доставлен',   Icons.home_outlined),
  ];

  int get _activeIdx {
    final idx = _steps.indexWhere((s) => s.$1 == status);
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: List.generate(_steps.length * 2 - 1, (i) {
      if (i.isOdd) {
        // Линия
        final done = i ~/ 2 < _activeIdx;
        return Expanded(child: Container(
          height: 2.h,
          color: done ? AppColors.accent : AppColors.accent.withOpacity(0.2),
        ));
      }
      final idx = i ~/ 2;
      final step = _steps[idx];
      final done = idx <= _activeIdx;
      return Column(children: [
        Container(
          width: 28.w, height: 28.w,
          decoration: BoxDecoration(
            color: done ? AppColors.accent : AppColors.accent.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(step.$3, size: 14.sp,
            color: done ? Colors.white : AppColors.accent.withOpacity(0.5)),
        ),
        SizedBox(height: 4.h),
        SizedBox(width: 52.w,
          child: Text(step.$2, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 8.sp,
              color: done ? AppColors.accent : AppColors.textMuted,
              fontWeight: done ? FontWeight.w700 : FontWeight.w400))),
      ]);
    }));
  }
}
