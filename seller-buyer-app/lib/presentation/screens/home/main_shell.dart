import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final idx      = _idx(location);
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final cartCount = context.watch<CartBloc>().state.totalQty;

    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
        height: 62.h,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1C1C1C).withOpacity(0.97)
              : Colors.white.withOpacity(0.97),
          borderRadius: BorderRadius.circular(32.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.5 : 0.15),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
            if (!isDark)
              BoxShadow(
                color: AppColors.accent.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
          ],
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _NavItem(icon: Icons.home_rounded,        outlineIcon: Icons.home_outlined,         label: 'Лента',   active: idx == 0, onTap: () => context.go(Routes.feed)),
            _NavItem(icon: Icons.play_circle_filled,  outlineIcon: Icons.play_circle_outline,   label: 'Рилсы',   active: idx == 1, onTap: () => context.go(Routes.reels)),
            _NavItem(icon: Icons.chat_bubble_rounded, outlineIcon: Icons.chat_bubble_outline,   label: 'Чаты',    active: idx == 2, onTap: () => context.go(Routes.chats), badge: cartCount),
            _NavItem(icon: Icons.person_rounded,      outlineIcon: Icons.person_outline_rounded, label: 'Профиль', active: idx == 3, onTap: () => context.go(Routes.profile)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, outlineIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final int badge;
  const _NavItem({
    required this.icon, required this.outlineIcon,
    required this.label, required this.active,
    required this.onTap, this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(horizontal: active ? 14.w : 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: active ? AppColors.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
              Icon(
                active ? icon : outlineIcon,
                color: active ? Colors.white : (isDark ? Colors.white.withOpacity(0.38) : Colors.black.withOpacity(0.38)),
                size: 22.sp,
              ),
              if (badge > 0)
                Positioned(
                  top: -4.h, right: active ? -2.w : -6.w,
                  child: Container(
                    width: 15.w, height: 15.w,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
                        width: 1.5,
                      ),
                    ),
                    child: Center(child: Text(
                      badge > 9 ? '9+' : '$badge',
                      style: TextStyle(
                        color: active ? AppColors.accent : Colors.white,
                        fontSize: 7.sp, fontWeight: FontWeight.w900,
                      ),
                    )),
                  ),
                ),
            ]),
          ),
          SizedBox(height: 3.h),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: active ? AppColors.accent : (isDark ? Colors.white.withOpacity(0.38) : Colors.black.withOpacity(0.38)),
              fontSize: 9.5.sp,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
            child: Text(label),
          ),
        ]),
      ),
    );
  }
}
