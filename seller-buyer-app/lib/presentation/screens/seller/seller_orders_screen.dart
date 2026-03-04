import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  static const _orders = [
    ('ORD-A4F2', 'Платье летнее', 'Камола У.',  18500000, 'new'),
    ('ORD-B9C1', 'Топ базовый',   'Малика Р.',  9800000,  'packed'),
    ('ORD-C7D0', 'Брюки wide leg','Дилноза А.', 24000000, 'delivery'),
    ('ORD-D5E8', 'Блуза шёлк',    'Зарина Н.',  32000000, 'done'),
  ];

  static const _statusMap = {
    'new':      ('Новый',       AppColors.blue),
    'packed':   ('Упакован',    AppColors.orange),
    'delivery': ('В пути 🛵',   AppColors.accent),
    'done':     ('Завершён ✓',  AppColors.green),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text('Заказы магазина', style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.bgDark, foregroundColor: AppColors.textPrimary,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _orders.length,
        itemBuilder: (_, i) {
          final o = _orders[i];
          final (label, color) = _statusMap[o.$5] ?? ('—', AppColors.textMuted);
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o.$1, style: TextStyle(color: AppColors.textMuted, fontSize: 10.sp)),
                SizedBox(height: 2.h),
                Text(o.$2, style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                Text('Покупатель: ${o.$3}', style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(label, style: TextStyle(color: color, fontSize: 10.sp, fontWeight: FontWeight.w600)),
                ),
                SizedBox(height: 4.h),
                Text(FormatUtils.priceTiyin(o.$4 ~/ 100), style: TextStyle(color: AppColors.textPrimary, fontSize: 13.sp, fontWeight: FontWeight.w700)),
              ]),
            ]),
          );
        },
      ),
    );
  }
}
