import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final auth   = context.watch<AuthBloc>().state;
    final user   = auth is AuthAuthenticated ? auth.user : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSeller = user?.isSeller == true;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF2F2F2),
      body: CustomScrollView(
        slivers: [

          // ── Hero header ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 28.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: isDark
                    ? [const Color(0xFF1A0A00), const Color(0xFF0D0D0D)]
                    : [const Color(0xFFFFF5F0), Colors.white],
                ),
              ),
              child: Column(children: [
                // Settings + edit row
                Row(children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push(Routes.settings),
                    child: Container(
                      width: 36.w, height: 36.w,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.settings_outlined,
                        size: 18.sp,
                        color: isDark ? Colors.white.withOpacity(0.60) : Colors.black.withOpacity(0.54)),
                    ),
                  ),
                ]),
                SizedBox(height: 12.h),

                // Avatar
                Stack(alignment: Alignment.bottomRight, children: [
                  Container(
                    width: 88.w, height: 88.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, Color(0xFFFF8533)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.35),
                          blurRadius: 20, offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (user?.name ?? user?.phone ?? 'U')[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.white, fontSize: 36.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 26.w, height: 26.w,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF2F2F2),
                        width: 2,
                      ),
                    ),
                    child: Icon(Icons.edit_rounded,
                      color: AppColors.accent, size: 12.sp),
                  ),
                ]),
                SizedBox(height: 14.h),

                // Name
                Text(
                  user?.name ?? user?.phone ?? '',
                  style: TextStyle(
                    fontSize: 20.sp, fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF111111),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 6.h),

                // Role badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: (user?.tier == 3 ? AppColors.accent : user?.tier == 2 ? AppColors.green : AppColors.blue).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: (user?.tier == 3 ? AppColors.accent : user?.tier == 2 ? AppColors.green : AppColors.blue).withOpacity(0.25),
                    ),
                  ),
                  child: Text(
                    '${user?.tierEmoji ?? '👤'} ${user?.tierLabel ?? 'Покупатель'}',
                    style: TextStyle(
                      color: user?.tier == 3 ? AppColors.accent : user?.tier == 2 ? AppColors.green : AppColors.blue,
                      fontSize: 12.sp, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Stats row
                Row(children: [
                  _StatCard('12',  'Заказов',   AppColors.accent,  isDark),
                  SizedBox(width: 8.w),
                  _StatCard('4,8', 'Рейтинг',   AppColors.gold,    isDark),
                  SizedBox(width: 8.w),
                  _StatCard('23',  'Избранных', AppColors.red,     isDark),
                ]),
              ]),
            ),
          ),

          // ── Divider ───────────────────────────────────────────────
          SliverToBoxAdapter(child: SizedBox(height: 16.h)),

          // ── Menu sections ─────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverList(delegate: SliverChildListDelegate([

              // Seller section
              if (isSeller) ...[
                _SectionLabel('Продавец', isDark),
                _MenuCard(isDark: isDark, items: [
                  _Item('📊', 'Кабинет продавца', AppColors.green,  () => context.push(Routes.dashboard)),
                  _Item('📦', 'Мои заказы продавца', AppColors.blue, () => context.push(Routes.sellerOrders)),
                  _Item('📈', 'Аналитика',        AppColors.purple, () => context.push(Routes.analytics)),
                ]),
                SizedBox(height: 12.h),
              ],

              // Upgrade banner for tier 1
              if (!isSeller) ...[
                GestureDetector(
                  onTap: () => context.push(Routes.upgradeTier),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.green.withOpacity(0.15), AppColors.green.withOpacity(0.05)],
                        begin: Alignment.centerLeft, end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: AppColors.green.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 44.w, height: 44.w,
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(child: Text('🛍️', style: TextStyle(fontSize: 22.sp))),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Начать продавать', style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w800,
                          color: AppColors.green,
                        )),
                        SizedBox(height: 2.h),
                        Text('Бесплатно. Без верификации.', style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? Colors.white.withOpacity(0.45) : Colors.black.withOpacity(0.45),
                        )),
                      ])),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: AppColors.green),
                    ]),
                  ),
                ),
                SizedBox(height: 12.h),
              ],

              // Shopping section
              _SectionLabel('Покупки', isDark),
              _MenuCard(isDark: isDark, items: [
                _Item('🛍️', 'Мои заказы',    AppColors.accent, () => context.push(Routes.orders)),
                _Item('❤️', 'Избранное',      AppColors.red,    () {}),
                _Item('📍', 'Адреса',         AppColors.orange, () {}),
                _Item('💳', 'Оплата',         AppColors.gold,   () {}),
              ]),
              SizedBox(height: 12.h),

              // Account section
              _SectionLabel('Аккаунт', isDark),
              _MenuCard(isDark: isDark, items: [
                _Item('🔔', 'Уведомления', AppColors.purple, () => context.push(Routes.notifications)),
                _Item('👑', 'GogoMarket Pro', AppColors.accent, () => context.push(Routes.pro), highlight: true),
                _Item('🆘', 'Поддержка',   AppColors.blue,   () {}),
              ]),
              SizedBox(height: 12.h),

              // Logout
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.read<AuthBloc>().add(AuthLogoutEvent());
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.red.withOpacity(0.2)),
                  ),
                  child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.logout_rounded, color: AppColors.red, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text('Выйти из аккаунта', style: TextStyle(
                      color: AppColors.red, fontSize: 14.sp, fontWeight: FontWeight.w700)),
                  ])),
                ),
              ),

              SizedBox(height: 110.h),
            ])),
          ),
        ],
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  final bool isDark;
  const _StatCard(this.value, this.label, this.color, this.isDark);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(
          fontSize: 20.sp, fontWeight: FontWeight.w900,
          color: color,
        )),
        SizedBox(height: 3.h),
        Text(label, style: TextStyle(
          fontSize: 10.5.sp,
          color: isDark ? Colors.white.withOpacity(0.38) : Colors.black.withOpacity(0.38),
          fontWeight: FontWeight.w500,
        )),
      ]),
    ),
  );
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionLabel(this.text, this.isDark);
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(4.w, 0, 0, 8.h),
    child: Text(text, style: TextStyle(
      fontSize: 12.sp, fontWeight: FontWeight.w700,
      color: isDark ? Colors.white.withOpacity(0.30) : Colors.black.withOpacity(0.30),
      letterSpacing: 0.8,
    )),
  );
}

// ── Menu card ─────────────────────────────────────────────────────────────────
class _Item {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;
  final bool highlight;
  const _Item(this.emoji, this.label, this.color, this.onTap, {this.highlight = false});
}

class _MenuCard extends StatelessWidget {
  final List<_Item> items;
  final bool isDark;
  const _MenuCard({required this.items, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      borderRadius: BorderRadius.circular(18.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
          blurRadius: 12, offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(children: List.generate(items.length, (i) {
      final item = items[i];
      final isLast = i == items.length - 1;
      return GestureDetector(
        onTap: () { HapticFeedback.selectionClick(); item.onTap(); },
        behavior: HitTestBehavior.opaque,
        child: Column(children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(children: [
              Container(
                width: 36.w, height: 36.w,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(item.highlight ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(child: Text(item.emoji, style: TextStyle(fontSize: 17.sp))),
              ),
              SizedBox(width: 14.w),
              Expanded(child: Text(item.label, style: TextStyle(
                fontSize: 14.sp, fontWeight: FontWeight.w600,
                color: item.highlight
                  ? AppColors.accent
                  : (isDark ? Colors.white.withOpacity(0.87) : Color(0xFF1A1A1A)),
              ))),
              Icon(Icons.chevron_right_rounded,
                size: 18.sp,
                color: isDark ? Colors.white.withOpacity(0.20) : Colors.black.withOpacity(0.20)),
            ]),
          ),
          if (!isLast) Divider(
            height: 1, thickness: 1, indent: 66.w,
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
          ),
        ]),
      );
    })),
  );
}