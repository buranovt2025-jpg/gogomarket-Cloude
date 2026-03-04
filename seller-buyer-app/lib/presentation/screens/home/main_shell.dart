import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/cart/cart_bloc.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [Routes.feed, Routes.reels, Routes.chats, Routes.profile];

  int _idx(String location) {
    final i = _tabs.indexWhere((t) => location.startsWith(t));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _idx(location);
    final cartCount = context.watch<CartBloc>().state.totalQty;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56.h,
            child: Row(children: [
              _NavItem(icon: Icons.home_outlined,          activeIcon: Icons.home,             label: 'Лента',    active: idx == 0, onTap: () => context.go(Routes.feed)),
              _NavItem(icon: Icons.play_circle_outline,    activeIcon: Icons.play_circle,      label: 'Рилсы',    active: idx == 1, onTap: () => context.go(Routes.reels)),
              _NavItem(icon: Icons.chat_bubble_outline,    activeIcon: Icons.chat_bubble,      label: 'Чаты',     active: idx == 2, onTap: () => context.go(Routes.chats), badge: cartCount),
              _NavItem(icon: Icons.person_outline,         activeIcon: Icons.person,           label: 'Профиль',  active: idx == 3, onTap: () => context.go(Routes.profile)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final int badge;
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.active, required this.onTap, this.badge = 0});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Stack(children: [
          Icon(active ? activeIcon : icon,
            color: active ? AppColors.accent : AppColors.textMuted,
            size: 24.sp),
          if (badge > 0)
            Positioned(top: 0, right: 0,
              child: Container(
                width: 14, height: 14,
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                child: Center(child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700))),
              )),
        ]),
        SizedBox(height: 2.h),
        Text(label, style: TextStyle(
          color: active ? AppColors.accent : AppColors.textMuted,
          fontSize: 10.sp, fontWeight: active ? FontWeight.w600 : FontWeight.normal,
        )),
      ]),
    ),
  );
}
