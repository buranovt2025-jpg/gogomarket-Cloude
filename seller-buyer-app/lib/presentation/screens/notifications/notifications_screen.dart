import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static final _notifs = [
    _Notif('📦', 'Заказ в пути', 'Ваш заказ #ORD-B9C1 передан курьеру', DateTime.now().subtract(const Duration(minutes: 15)), false, AppColors.accent),
    _Notif('💰', 'Скидка 20%', 'Aisha Fashion дарит скидку на все платья сегодня!', DateTime.now().subtract(const Duration(hours: 1)), false, AppColors.red),
    _Notif('💬', 'Новое сообщение', 'SneakerShop: "Ваш заказ готов к отправке"', DateTime.now().subtract(const Duration(hours: 3)), true, AppColors.blue),
    _Notif('⭐', 'Оцените покупку', 'Как вам платье от Aisha Fashion?', DateTime.now().subtract(const Duration(days: 1)), true, AppColors.gold),
    _Notif('🎉', 'Добро пожаловать!', 'Вы зарегистрировались в GogoMarket', DateTime.now().subtract(const Duration(days: 3)), true, AppColors.green),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text('Уведомления', style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.bgDark,
        foregroundColor: AppColors.textPrimary,
        actions: [
          TextButton(onPressed: () {}, child: Text('Прочитать все', style: TextStyle(color: AppColors.accent, fontSize: 12.sp))),
        ],
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: _notifs.length,
        separatorBuilder: (_, __) => SizedBox(height: 8.h),
        itemBuilder: (_, i) => _NotifCard(n: _notifs[i]),
      ),
    );
  }
}

class _Notif {
  final String icon, title, body;
  final DateTime time;
  final bool read;
  final Color color;
  const _Notif(this.icon, this.title, this.body, this.time, this.read, this.color);
}

class _NotifCard extends StatelessWidget {
  final _Notif n;
  const _NotifCard({required this.n});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: n.read ? AppColors.bgCard : n.color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: n.read ? AppColors.border : n.color.withOpacity(0.25)),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 42.w, height: 42.w,
        decoration: BoxDecoration(color: n.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(n.icon, style: TextStyle(fontSize: 20.sp)))),
      SizedBox(width: 12.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(n.title, style: TextStyle(
            color: AppColors.textPrimary, fontSize: 14.sp,
            fontWeight: n.read ? FontWeight.w500 : FontWeight.w700,
          ))),
          Text(FormatUtils.timeAgo(n.time), style: TextStyle(color: AppColors.textMuted, fontSize: 10.sp)),
        ]),
        SizedBox(height: 3.h),
        Text(n.body, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
      ])),
      if (!n.read) ...[
        SizedBox(width: 8.w),
        Container(width: 8, height: 8, decoration: BoxDecoration(color: n.color, shape: BoxShape.circle)),
      ],
    ]),
  );
}
