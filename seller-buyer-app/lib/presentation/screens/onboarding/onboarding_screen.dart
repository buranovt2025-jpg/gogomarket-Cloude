import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override State<OnboardingScreen> createState() => _State();
}

class _State extends State<OnboardingScreen> with TickerProviderStateMixin {
  final _ctrl = PageController();
  int _page = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _pages = [
    _Page(
      emoji: '🎬',
      title: 'Покупай через\nрилсы',
      subtitle: 'Смотри видео от продавцов,\nлайкай и заказывай в один клик',
      bg1: Color(0xFF1A0500),
      bg2: Color(0xFF0D0D0D),
      accent: AppColors.accent,
    ),
    _Page(
      emoji: '🏪',
      title: 'Витрины\nпродавцов',
      subtitle: 'Подписывайся на магазины\nи следи за новинками',
      bg1: Color(0xFF001A0F),
      bg2: Color(0xFF0D0D0D),
      accent: AppColors.green,
    ),
    _Page(
      emoji: '💬',
      title: 'Торгуйся\nв чате',
      subtitle: 'Пиши продавцу напрямую\nи делай выгодные предложения',
      bg1: Color(0xFF00101A),
      bg2: Color(0xFF0D0D0D),
      accent: Color(0xFF1F87E8),
    ),
    _Page(
      emoji: '🛵',
      title: 'Быстрая\nдоставка',
      subtitle: 'Отслеживай курьера на карте\nв режиме реального времени',
      bg1: Color(0xFF1A1A00),
      bg2: Color(0xFF0D0D0D),
      accent: Color(0xFFFFB800),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override void dispose() { _ctrl.dispose(); _fadeCtrl.dispose(); super.dispose(); }

  Future<void> _done() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go(Routes.phone);
  }

  void _next() {
    HapticFeedback.selectionClick();
    if (_page < _pages.length - 1) {
      _ctrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    } else {
      _done();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _pages[_page];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: Stack(children: [

          // Animated background
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.6, -0.5),
                radius: 1.4,
                colors: [p.bg1, p.bg2],
              ),
            ),
          ),

          // Glow blob
          Positioned(
            top: 80.h, left: -100.w,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 340.w, height: 340.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [p.accent.withOpacity(0.18), Colors.transparent],
                ),
              ),
            ),
          ),

          // Skip
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 12.h, 20.w, 0),
                child: TextButton(
                  onPressed: _done,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  ),
                  child: Text('Пропустить', style: TextStyle(
                    color: Colors.white.withOpacity(0.38), fontSize: 13.sp, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ),

          // Pages
          PageView.builder(
            controller: _ctrl,
            itemCount: _pages.length,
            onPageChanged: (i) {
              setState(() => _page = i);
              _fadeCtrl.reset();
              _fadeCtrl.forward();
            },
            itemBuilder: (_, i) {
              final pg = _pages[i];
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Column(children: [
                    SizedBox(height: 100.h),

                    // Emoji in glass card
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        width: 160.w, height: 160.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              pg.accent.withOpacity(0.20),
                              pg.accent.withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(
                            color: pg.accent.withOpacity(0.25), width: 1.5),
                        ),
                        child: Center(child: Text(pg.emoji,
                          style: TextStyle(fontSize: 72.sp))),
                      ),
                    ),

                    const Spacer(),

                    // Text
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Accent line
                        Container(
                          width: 32.w, height: 3.h,
                          decoration: BoxDecoration(
                            color: pg.accent,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Text(pg.title, style: TextStyle(
                          fontSize: 36.sp, fontWeight: FontWeight.w900,
                          color: Colors.white, height: 1.15, letterSpacing: -0.8,
                        )),
                        SizedBox(height: 14.h),
                        Text(pg.subtitle, style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.white.withOpacity(0.54),
                          height: 1.6,
                        )),
                      ]),
                    ),
                    SizedBox(height: 60.h),
                  ]),
                ),
              );
            },
          ),

          // Bottom controls
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(28.w, 0, 28.w, 24.h),
                child: Row(children: [
                  // Dots
                  AnimatedSmoothIndicator(
                    activeIndex: _page,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: _pages[_page].accent,
                      dotColor: Colors.white.withOpacity(0.16),
                      dotHeight: 6.h,
                      dotWidth: 6.w,
                      expansionFactor: 3.5,
                      spacing: 5,
                    ),
                  ),
                  const Spacer(),
                  // Next / Done button
                  GestureDetector(
                    onTap: _next,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _page == _pages.length - 1 ? 140.w : 54.w,
                      height: 54.h,
                      decoration: BoxDecoration(
                        color: _pages[_page].accent,
                        borderRadius: BorderRadius.circular(27.r),
                        boxShadow: [
                          BoxShadow(
                            color: _pages[_page].accent.withOpacity(0.4),
                            blurRadius: 20, offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _page == _pages.length - 1
                          ? Text('Начать!', style: TextStyle(
                              color: Colors.white, fontSize: 15.sp,
                              fontWeight: FontWeight.w800))
                          : const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Page {
  final String emoji, title, subtitle;
  final Color bg1, bg2, accent;
  const _Page({required this.emoji, required this.title, required this.subtitle,
    required this.bg1, required this.bg2, required this.accent});
}
