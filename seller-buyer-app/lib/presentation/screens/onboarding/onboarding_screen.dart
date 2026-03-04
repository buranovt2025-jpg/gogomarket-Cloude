import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  static const _pages = [
    _Page('🎬', 'Покупай через рилсы', 'Смотри видео о товарах от продавцов.\nЛайкай, сохраняй, заказывай.', AppColors.accent),
    _Page('🏪', 'Витрины продавцов', 'У каждого продавца свой Instagram-профиль.\nПодписывайся, следи за новинками.', AppColors.purple),
    _Page('💬', 'Торгуйся в чате', 'Пиши продавцу напрямую.\nОтправляй оффер прямо из чата.', AppColors.blue),
    _Page('🛵', 'Быстрая доставка', 'Отслеживай курьера на карте в реальном времени.\nЗнаешь, где твой заказ.', AppColors.green),
  ];

  Future<void> _done() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go(Routes.phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(children: [
          // ── Skip ─────────────────────────────────────────────────────
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 16.h, 20.w, 0),
              child: TextButton(
                onPressed: _done,
                child: Text('Пропустить', style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp)),
              ),
            ),
          ),

          // ── Pages ─────────────────────────────────────────────────────
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) {
                final p = _pages[i];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    // Illustration
                    Container(
                      width: 180.w, height: 180.w,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(colors: [
                          p.color.withOpacity(0.25),
                          p.color.withOpacity(0.05),
                        ]),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text(p.emoji, style: TextStyle(fontSize: 72.sp))),
                    ),
                    SizedBox(height: 40.h),
                    Text(p.title, style: TextStyle(
                      fontFamily: 'Playfair', fontSize: 26.sp,
                      fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                      height: 1.2,
                    ), textAlign: TextAlign.center),
                    SizedBox(height: 14.h),
                    Text(p.subtitle, style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 15.sp, height: 1.6,
                    ), textAlign: TextAlign.center),
                  ]),
                );
              },
            ),
          ),

          // ── Indicator + CTA ────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 40.h),
            child: Column(children: [
              SmoothPageIndicator(
                controller: _ctrl,
                count: _pages.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppColors.accent,
                  dotColor: AppColors.border,
                  dotHeight: 6, dotWidth: 6, expansionFactor: 3,
                ),
              ),
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity, height: 52.h,
                child: ElevatedButton(
                  onPressed: _page < _pages.length - 1
                    ? () => _ctrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut)
                    : _done,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                    shadowColor: AppColors.accent.withOpacity(0.4),
                  ),
                  child: Text(
                    _page < _pages.length - 1 ? 'Далее' : 'Начать',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Page {
  final String emoji, title, subtitle;
  final Color color;
  const _Page(this.emoji, this.title, this.subtitle, this.color);
}
