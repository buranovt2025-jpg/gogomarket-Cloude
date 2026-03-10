import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';

class UpgradeTierScreen extends StatefulWidget {
  const UpgradeTierScreen({super.key});

  @override
  State<UpgradeTierScreen> createState() => _UpgradeTierScreenState();
}

class _UpgradeTierScreenState extends State<UpgradeTierScreen>
    with SingleTickerProviderStateMixin {
  final _shopNameController = TextEditingController();
  bool _agreed = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthTierUpgraded) {
          HapticFeedback.heavyImpact();
          _showSuccessSheet(context, isDark);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.red,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF5F5F5),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            slivers: [
              // ── AppBar
              SliverAppBar(
                pinned: true,
                backgroundColor: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF5F5F5),
                elevation: 0,
                leading: GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20.sp,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                ),
                title: Text('Начать продавать',
                  style: TextStyle(
                    fontSize: 17.sp, fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  )),
                centerTitle: true,
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),

                      // ── Tier cards
                      _TierCard(
                        emoji: '🛍️',
                        tier: 2,
                        title: 'Частный продавец',
                        subtitle: 'Бесплатно — без верификации',
                        color: AppColors.green,
                        features: const [
                          '10 товаров в неделю',
                          '3 рилса в неделю',
                          '1 история в день',
                          'Бесплатное продление',
                          'Чат с покупателями',
                        ],
                        isDark: isDark,
                        isCurrent: false,
                        isRecommended: true,
                      ),
                      SizedBox(height: 12.h),

                      _TierCard(
                        emoji: '🏪',
                        tier: 3,
                        title: 'Бизнес',
                        subtitle: 'Требует верификации ИНН + подписки',
                        color: AppColors.accent,
                        features: const [
                          'Неограниченные товары',
                          'Неограниченные рилсы',
                          'Полная витрина с брендингом',
                          'Аналитика продаж',
                          'Продвижение в ленте',
                        ],
                        isDark: isDark,
                        isCurrent: false,
                        isRecommended: false,
                        isLocked: true,
                      ),
                      SizedBox(height: 28.h),

                      // ── Shop name input
                      Text('Название магазина (опционально)',
                        style: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.4),
                          letterSpacing: 0.5,
                        )),
                      SizedBox(height: 8.h),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
                          ),
                        ),
                        child: TextField(
                          controller: _shopNameController,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Мой магазин',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                              fontSize: 15.sp,
                            ),
                            prefixIcon: Icon(Icons.store_rounded,
                              color: AppColors.green, size: 20.sp),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 16.h),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // ── Agreement
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _agreed = !_agreed);
                        },
                        child: Row(children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22.w, height: 22.w,
                            decoration: BoxDecoration(
                              color: _agreed ? AppColors.green : Colors.transparent,
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: _agreed ? AppColors.green : (isDark
                                    ? Colors.white.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.3)),
                                width: 2,
                              ),
                            ),
                            child: _agreed
                                ? Icon(Icons.check_rounded,
                                    color: Colors.white, size: 14.sp)
                                : null,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.6)
                                      : Colors.black.withOpacity(0.6),
                                ),
                                children: [
                                  const TextSpan(text: 'Я согласен с '),
                                  TextSpan(
                                    text: 'правилами платформы',
                                    style: TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(text: ' для продавцов'),
                                ],
                              ),
                            ),
                          ),
                        ]),
                      ),
                      SizedBox(height: 32.h),

                      // ── CTA Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthUpgradingTier;
                          return GestureDetector(
                            onTap: _agreed && !isLoading ? _onActivate : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              height: 54.h,
                              decoration: BoxDecoration(
                                gradient: _agreed
                                    ? const LinearGradient(
                                        colors: [AppColors.green, Color(0xFF22C55E)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      )
                                    : null,
                                color: !_agreed
                                    ? (isDark
                                        ? Colors.white.withOpacity(0.08)
                                        : Colors.black.withOpacity(0.08))
                                    : null,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: _agreed
                                    ? [BoxShadow(
                                        color: AppColors.green.withOpacity(0.4),
                                        blurRadius: 16, offset: const Offset(0, 6),
                                      )]
                                    : null,
                              ),
                              child: Center(
                                child: isLoading
                                    ? SizedBox(
                                        width: 22.w, height: 22.w,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2.5,
                                        ),
                                      )
                                    : Row(mainAxisSize: MainAxisSize.min, children: [
                                        Text('🛍️  ', style: TextStyle(fontSize: 18.sp)),
                                        Text(
                                          'Активировать уровень 2',
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w800,
                                            color: _agreed
                                                ? Colors.white
                                                : (isDark
                                                    ? Colors.white.withOpacity(0.3)
                                                    : Colors.black.withOpacity(0.3)),
                                          ),
                                        ),
                                      ]),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Note
                      Center(
                        child: Text(
                          'Бесплатно. Активация мгновенная.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark
                                ? Colors.white.withOpacity(0.35)
                                : Colors.black.withOpacity(0.35),
                          ),
                        ),
                      ),
                      SizedBox(height: 60.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onActivate() {
    HapticFeedback.mediumImpact();
    final shopName = _shopNameController.text.trim();
    context.read<AuthBloc>().add(AuthUpgradeTierEvent(
      tier: 2,
      shopName: shopName.isNotEmpty ? shopName : null,
    ));
  }

  void _showSuccessSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 48.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('🎉', style: TextStyle(fontSize: 64.sp)),
          SizedBox(height: 16.h),
          Text('Вы теперь продавец!',
            style: TextStyle(
              fontSize: 22.sp, fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            )),
          SizedBox(height: 8.h),
          Text(
            'Уровень 2 активирован. Начните добавлять\nтовары и рилсы прямо сейчас.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 28.h),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Container(
              width: double.infinity, height: 52.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, Color(0xFFFF8533)],
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [BoxShadow(
                  color: AppColors.accent.withOpacity(0.35),
                  blurRadius: 16, offset: const Offset(0, 6),
                )],
              ),
              child: Center(child: Text('Начать продавать',
                style: TextStyle(
                  color: Colors.white, fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                ))),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Tier Card ─────────────────────────────────────────────────────────────────
class _TierCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final int tier;
  final Color color;
  final List<String> features;
  final bool isDark, isCurrent, isRecommended, isLocked;

  const _TierCard({
    required this.emoji,
    required this.tier,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.features,
    required this.isDark,
    required this.isCurrent,
    required this.isRecommended,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLocked ? 0.55 : 1.0,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isRecommended ? color.withOpacity(0.5) : color.withOpacity(0.15),
            width: isRecommended ? 2 : 1,
          ),
          boxShadow: isRecommended
              ? [BoxShadow(color: color.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 6))]
              : [],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 44.w, height: 44.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(child: Text(emoji, style: TextStyle(fontSize: 22.sp))),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(title, style: TextStyle(
                  fontSize: 15.sp, fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                )),
                if (isRecommended) ...[ SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text('Старт', style: TextStyle(
                      fontSize: 10.sp, fontWeight: FontWeight.w700, color: Colors.white,
                    )),
                  ),
                ],
                if (isLocked) ...[ SizedBox(width: 8.w),
                  Icon(Icons.lock_rounded, size: 14.sp, color: color),
                ],
              ]),
              SizedBox(height: 2.h),
              Text(subtitle, style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
              )),
            ])),
          ]),
          SizedBox(height: 16.h),
          Divider(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06)),
          SizedBox(height: 12.h),
          ...features.map((f) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(children: [
              Icon(Icons.check_circle_rounded, size: 16.sp, color: color),
              SizedBox(width: 10.w),
              Text(f, style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? Colors.white.withOpacity(0.75) : Colors.black.withOpacity(0.7),
              )),
            ]),
          )),
        ]),
      ),
    );
  }
}
