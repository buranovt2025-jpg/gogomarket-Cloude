import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final user = auth is AuthAuthenticated ? auth.user : null;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text('Профиль', style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.bgDark,
        actions: [IconButton(icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary), onPressed: () => context.push(Routes.settings))],
      ),
      body: ListView(padding: EdgeInsets.all(16.w), children: [
        // Avatar + name
        Center(child: Column(children: [
          Container(width: 80.w, height: 80.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.accent, AppColors.purple]),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text((user?.name ?? user?.phone ?? 'U')[0].toUpperCase(),
              style: TextStyle(color: Colors.white, fontSize: 34.sp, fontWeight: FontWeight.w700, fontFamily: 'Playfair')))),
          SizedBox(height: 10.h),
          Text(user?.name ?? user?.phone ?? '', style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 4.h),
          Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: (user?.isSeller == true ? AppColors.green : AppColors.blue).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(user?.isSeller == true ? '🏪 Продавец' : '🛍️ Покупатель',
              style: TextStyle(color: user?.isSeller == true ? AppColors.green : AppColors.blue, fontSize: 12.sp, fontWeight: FontWeight.w500))),
        ])),
        SizedBox(height: 24.h),

        // Stats
        Row(children: [
          _StatBox('12', 'Заказов'),
          _StatBox('3', 'Отзывов'),
          _StatBox('8', 'Избранных'),
        ]),
        SizedBox(height: 20.h),

        // Seller dashboard button (if seller)
        if (user?.isSeller == true)
          _MenuItem('📊 Кабинет продавца', AppColors.green, () => context.push(Routes.dashboard)),

        // Menu items
        _MenuItem('📦 Мои заказы',       AppColors.blue,   () => context.push(Routes.orders)),
        _MenuItem('❤️ Избранное',         AppColors.red,    () {}),
        _MenuItem('💳 Способы оплаты',   AppColors.gold,   () {}),
        _MenuItem('📍 Мои адреса',       AppColors.orange, () {}),
        _MenuItem('🔔 Уведомления',      AppColors.purple, () => context.push(Routes.notifications)),
        _MenuItem('👑 GogoMarket Pro',   AppColors.accent, () => context.push(Routes.pro)),
        SizedBox(height: 12.h),
        _MenuItem('🚪 Выйти', AppColors.red, () => context.read<AuthBloc>().add(AuthLogoutEvent()), danger: true),
      ]),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value, label;
  const _StatBox(this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    margin: EdgeInsets.symmetric(horizontal: 4.w),
    padding: EdgeInsets.symmetric(vertical: 14.h),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
    child: Column(children: [
      Text(value, style: TextStyle(color: AppColors.textPrimary, fontSize: 20.sp, fontWeight: FontWeight.w700)),
      Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
    ]),
  ));
}

class _MenuItem extends StatelessWidget {
  final String label; final Color color; final VoidCallback onTap; final bool danger;
  const _MenuItem(this.label, this.color, this.onTap, {this.danger = false});
  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 8.h),
    child: ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      tileColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
      leading: Container(width: 36, height: 36,
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(label.split(' ').first, style: const TextStyle(fontSize: 16)))),
      title: Text(label.split(' ').skip(1).join(' '),
        style: TextStyle(color: danger ? AppColors.red : AppColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w500)),
      trailing: danger ? null : const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14),
    ),
  );
}
