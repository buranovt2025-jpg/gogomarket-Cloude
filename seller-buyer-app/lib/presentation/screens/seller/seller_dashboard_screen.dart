import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/format.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _Header()),
        SliverToBoxAdapter(child: _KpiRow()),
        SliverToBoxAdapter(child: _RevenueChart()),
        SliverToBoxAdapter(child: _QuickActions()),
        SliverToBoxAdapter(child: _RecentOrders()),
      ])),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.addProduct),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add),
        label: Text('Добавить товар', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Кабинет продавца', style: TextStyle(fontFamily: 'Playfair', fontSize: 22.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text('Добро пожаловать 👋', style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp)),
      ])),
      GestureDetector(
        onTap: () => context.push(Routes.notifications),
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 20),
        ),
      ),
    ]),
  );
}

class _KpiRow extends StatelessWidget {
  static final _kpis = [
    {'icon': '💰', 'label': 'Выручка', 'value': '2.4M', 'delta': '+18%', 'color': AppColors.green},
    {'icon': '📦', 'label': 'Заказов',  'value': '47',   'delta': '+5',   'color': AppColors.blue},
    {'icon': '🛍️', 'label': 'Товаров', 'value': '18',   'delta': '+2',   'color': AppColors.purple},
    {'icon': '⭐', 'label': 'Рейтинг',  'value': '4.8',  'delta': '',     'color': AppColors.gold},
  ];
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 12.w),
    child: Row(children: _kpis.map((k) => Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: (k['color'] as Color).withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: (k['color'] as Color).withOpacity(0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k['icon'] as String, style: TextStyle(fontSize: 18.sp)),
          SizedBox(height: 4.h),
          Text(k['value'] as String, style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w700)),
          Text(k['label'] as String, style: TextStyle(color: AppColors.textMuted, fontSize: 9.sp)),
          if ((k['delta'] as String).isNotEmpty)
            Text(k['delta'] as String, style: TextStyle(color: k['color'] as Color, fontSize: 9.sp, fontWeight: FontWeight.w600)),
        ]),
      ),
    )).toList()),
  );
}

class _RevenueChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(16.w),
    child: Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Выручка (7 дней)', style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 16.h),
        SizedBox(
          height: 130.h,
          child: LineChart(LineChartData(
            gridData: FlGridData(drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1)),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1,
                getTitlesWidget: (v, _) => Text(['Пн','Вт','Ср','Чт','Пт','Сб','Вс'][v.toInt()],
                  style: TextStyle(color: AppColors.textMuted, fontSize: 9.sp)))),
            ),
            lineBarsData: [LineChartBarData(
              spots: [180, 240, 190, 350, 280, 420, 390]
                .asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList(),
              isCurved: true, color: AppColors.accent, barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: AppColors.accent.withOpacity(0.08)),
            )],
          )),
        ),
      ]),
    ),
  );
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Row(children: [
      _ActionBtn('📦', 'Товары',     Routes.addProduct),
      SizedBox(width: 10.w),
      _ActionBtn('🎬', 'Рилс',       Routes.createReel),
      SizedBox(width: 10.w),
      _ActionBtn('📋', 'Заказы',     Routes.sellerOrders),
      SizedBox(width: 10.w),
      _ActionBtn('📈', 'Аналитика',  Routes.analytics),
    ]),
  );
}

class _ActionBtn extends StatelessWidget {
  final String icon, label, route;
  const _ActionBtn(this.icon, this.label, this.route);
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(
    onTap: () => context.push(route),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Text(icon, style: TextStyle(fontSize: 22.sp)),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 9.sp)),
      ]),
    ),
  ));
}

class _RecentOrders extends StatelessWidget {
  static const _orders = [
    {'id': 'A4F22', 'product': 'Платье летнее', 'buyer': 'Камола У.',  'status': 'new',    'amount': 185000},
    {'id': 'B9C11', 'product': 'Джинсы Slim',   'buyer': 'Малика Р.',  'status': 'packed', 'amount': 320000},
    {'id': 'C7D03', 'product': 'Топ базовый',   'buyer': 'Дилноза А.', 'status': 'done',   'amount': 95000},
  ];
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Последние заказы', style: TextStyle(color: AppColors.textPrimary, fontSize: 15.sp, fontWeight: FontWeight.w600)),
        const Spacer(),
        TextButton(onPressed: () => context.push(Routes.sellerOrders), child: Text('Все', style: TextStyle(color: AppColors.accent, fontSize: 13.sp))),
      ]),
      ..._orders.map((o) => Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('#${o['id']}', style: TextStyle(color: AppColors.textMuted, fontSize: 10.sp)),
            Text(o['product'] as String, style: TextStyle(color: AppColors.textPrimary, fontSize: 13.sp, fontWeight: FontWeight.w500)),
            Text(o['buyer'] as String, style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
          ]),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _statusBadge(o['status'] as String),
            SizedBox(height: 4.h),
            Text(FormatUtils.price(o['amount'] as int), style: TextStyle(color: AppColors.textPrimary, fontSize: 13.sp, fontWeight: FontWeight.w600)),
          ]),
        ]),
      )),
    ]),
  );

  static Widget _statusBadge(String status) {
    final map = {
      'new':    ('Новый',     AppColors.blue),
      'packed': ('Упакован',  AppColors.orange),
      'done':   ('Доставлен', AppColors.green),
    };
    final (label, color) = map[status] ?? ('—', AppColors.textMuted);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
