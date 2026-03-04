import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/format.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  static const _steps = [
    ('Принят',      Icons.check_circle_outline),
    ('Упаковка',    Icons.inventory_2_outlined),
    ('В пути',      Icons.local_shipping_outlined),
    ('Доставлен',   Icons.home_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    const currentStep = 2; // In delivery
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text('Заказ #${orderId.toUpperCase().substring(orderId.length > 6 ? orderId.length - 6 : 0)}',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.bgDark,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(icon: const Icon(Icons.support_agent_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(padding: EdgeInsets.all(16.w), children: [
        // Status banner
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.accent.withOpacity(0.2), AppColors.accent.withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          ),
          child: Column(children: [
            Text('🛵', style: TextStyle(fontSize: 36.sp)),
            SizedBox(height: 8.h),
            Text('Заказ в пути', style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 4.h),
            Text('Ожидаемое время: ~25 минут', style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp)),
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push(Routes.tracking(orderId)),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.accent, side: const BorderSide(color: AppColors.accent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.map_outlined, size: 16),
                label: Text('Смотреть на карте', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
        SizedBox(height: 16.h),

        // Progress steps
        _Section('СТАТУС ДОСТАВКИ', Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Row(children: List.generate(_steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              final done = i ~/ 2 < currentStep;
              return Expanded(child: Container(height: 2, color: done ? AppColors.accent : AppColors.border));
            }
            final idx  = i ~/ 2;
            final done = idx < currentStep;
            final curr = idx == currentStep;
            return Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 36, height: 36,
                decoration: BoxDecoration(
                  color: done || curr ? AppColors.accent : AppColors.bgSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: done || curr ? AppColors.accent : AppColors.border),
                ),
                child: Center(child: Icon(_steps[idx].$2, size: 16, color: done || curr ? Colors.white : AppColors.textMuted)),
              ),
              SizedBox(height: 4.h),
              SizedBox(width: 56.w, child: Text(_steps[idx].$1, textAlign: TextAlign.center,
                style: TextStyle(color: done || curr ? AppColors.textPrimary : AppColors.textMuted, fontSize: 9.sp))),
            ]);
          })),
        )),
        SizedBox(height: 12.h),

        // Product
        _Section('ТОВАР', Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Row(children: [
            Container(width: 60.w, height: 60.w, decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text('👗', style: TextStyle(fontSize: 28.sp)))),
            SizedBox(width: 12.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Платье летнее Zara style', style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w500)),
              SizedBox(height: 2.h),
              Text('Aisha Fashion  ·  Размер M', style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp)),
            ])),
            Text('185 000 сум', style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w700)),
          ]),
        )),
        SizedBox(height: 12.h),

        // Delivery info
        _Section('ДОСТАВКА', _InfoCard([
          ('📍 Откуда', 'Aisha Fashion, Yunusobod'),
          ('🏠 Куда', 'ул. Амира Темура 108, кв. 24'),
          ('🛵 Курьер', 'Санжар К.  +998 90 *** 45 67'),
        ])),
        SizedBox(height: 12.h),

        // Total
        _Section('ИТОГ', Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(children: [
            _Row('Товар',     '185 000 сум'),
            _Row('Доставка', 'Бесплатно', green: true),
            _Row('Скидка',   '-15 000 сум', red: true),
            const Divider(color: AppColors.border, height: 20),
            _Row('Итого', '170 000 сум', bold: true),
          ]),
        )),
        SizedBox(height: 20.h),

        // Actions
        if (orderId == 'ord1') // new order — can cancel
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.red, side: const BorderSide(color: AppColors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: Text('Отменить заказ', style: TextStyle(fontSize: 14.sp)),
          ),
        SizedBox(height: 40.h),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String title; final Widget child;
  const _Section(this.title, this.child);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp, fontWeight: FontWeight.w600, letterSpacing: 1)),
    SizedBox(height: 8.h),
    child,
  ]);
}

class _InfoCard extends StatelessWidget {
  final List<(String, String)> rows;
  const _InfoCard(this.rows);
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
    child: Column(children: rows.map((r) => Padding(
      padding: EdgeInsets.only(bottom: r == rows.last ? 0 : 10.h),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 100.w, child: Text(r.$1, style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp))),
        Expanded(child: Text(r.$2, style: TextStyle(color: AppColors.textPrimary, fontSize: 12.sp, fontWeight: FontWeight.w500))),
      ]),
    )).toList()),
  );
}

class _Row extends StatelessWidget {
  final String label, value; final bool green, red, bold;
  const _Row(this.label, this.value, {this.green = false, this.red = false, this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 4.h),
    child: Row(children: [
      Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp)),
      const Spacer(),
      Text(value, style: TextStyle(
        color: green ? AppColors.green : red ? AppColors.red : AppColors.textPrimary,
        fontSize: bold ? 15.sp : 13.sp, fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
      )),
    ]),
  );
}
