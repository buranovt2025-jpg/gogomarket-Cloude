import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/format.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  static final _chats = [
    {'id': 'ch1', 'name': 'Aisha Fashion', 'last': 'Есть размер M?', 'time': DateTime.now().subtract(const Duration(minutes: 5)), 'unread': 2, 'avatar': '👗'},
    {'id': 'ch2', 'name': 'SneakerShop UZ', 'last': 'Отправили ваш заказ!', 'time': DateTime.now().subtract(const Duration(hours: 1)), 'unread': 0, 'avatar': '👟'},
    {'id': 'ch3', 'name': 'BeautyUZ', 'last': 'Спасибо за покупку ⭐', 'time': DateTime.now().subtract(const Duration(hours: 3)), 'unread': 0, 'avatar': '💄'},
    {'id': 'ch4', 'name': 'HomeStyle', 'last': 'Ок, доставим завтра', 'time': DateTime.now().subtract(const Duration(days: 1)), 'unread': 1, 'avatar': '🏠'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text('Сообщения', style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.bgDark,
        actions: [IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary), onPressed: () {})],
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: _chats.length,
        itemBuilder: (_, i) {
          final c = _chats[i];
          final hasUnread = (c['unread'] as int) > 0;
          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            onTap: () => context.push(Routes.chat(c['id'] as String)),
            leading: Container(
              width: 50.w, height: 50.w,
              decoration: BoxDecoration(color: AppColors.bgCard, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
              child: Center(child: Text(c['avatar'] as String, style: TextStyle(fontSize: 22.sp))),
            ),
            title: Row(children: [
              Expanded(child: Text(c['name'] as String, style: TextStyle(
                color: AppColors.textPrimary, fontSize: 14.sp,
                fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
              ))),
              Text(FormatUtils.timeAgo(c['time'] as DateTime),
                style: TextStyle(color: hasUnread ? AppColors.accent : AppColors.textMuted, fontSize: 11.sp)),
            ]),
            subtitle: Row(children: [
              Expanded(child: Text(c['last'] as String,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: hasUnread ? AppColors.textSecondary : AppColors.textMuted, fontSize: 12.sp))),
              if (hasUnread)
                Container(
                  width: 20, height: 20,
                  decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                  child: Center(child: Text('${c['unread']}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
                ),
            ]),
          );
        },
      ),
    );
  }
}
