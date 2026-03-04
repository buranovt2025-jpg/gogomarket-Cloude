import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';

class ProScreen extends StatefulWidget {
  const ProScreen({super.key});
  @override State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  int _selected = 1; // default: Бизнес

  static final _plans = [
    _Plan('Старт',   50000,  AppColors.blue,   ['20 товаров', '10 рилсов/мес', 'Базовая аналитика', 'Чат с покупателями']),
    _Plan('Бизнес',  150000, AppColors.accent, ['Без лимитов', '∞ рилсов', 'Полная аналитика', 'Продвижение товаров', 'Приоритет в поиске', 'Стримы'], popular: true),
    _Plan('Магазин', 400000, AppColors.purple, ['Всё из Бизнес', 'API интеграция', 'Выделенный менеджер', 'Таргет-реклама', 'Мультипользователь', 'SLA поддержка 24/7']),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        foregroundColor: AppColors.textPrimary,
        title: Text('GogoMarket Pro', style: TextStyle(fontFamily: 'Playfair', fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: Column(children: [
        Expanded(child: ListView(padding: EdgeInsets.all(16.w), children: [
          // Header
          Center(child: Column(children: [
            Text('⭐', style: TextStyle(fontSize: 48.sp)),
            SizedBox(height: 8.h),
            Text('Для серьёзного бизнеса', style: TextStyle(fontFamily: 'Playfair', fontSize: 22.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            SizedBox(height: 6.h),
            Text('Продавайте больше с Pro-инструментами', style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp)),
          ])),
          SizedBox(height: 24.h),

          // Plans
          ...List.generate(_plans.length, (i) {
            final p = _plans[i];
            final sel = _selected == i;
            return GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: sel ? LinearGradient(colors: [p.color.withOpacity(0.15), p.color.withOpacity(0.05)]) : null,
                  color: sel ? null : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? p.color : AppColors.border, width: sel ? 2 : 1),
                  boxShadow: sel ? [BoxShadow(color: p.color.withOpacity(0.2), blurRadius: 16)] : null,
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(p.name, style: TextStyle(color: sel ? p.color : AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700)),
                    if (p.popular) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(color: p.color, borderRadius: BorderRadius.circular(20)),
                        child: Text('Хит', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w700)),
                      ),
                    ],
                    const Spacer(),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: sel ? p.color : Colors.transparent,
                        border: Border.all(color: sel ? p.color : AppColors.border, width: 2),
                      ),
                      child: sel ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                    ),
                  ]),
                  SizedBox(height: 4.h),
                  RichText(text: TextSpan(children: [
                    TextSpan(text: _fmt(p.pricePerMonth), style: TextStyle(color: p.color, fontSize: 22.sp, fontWeight: FontWeight.w800)),
                    TextSpan(text: ' сум/мес', style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp)),
                  ])),
                  SizedBox(height: 12.h),
                  Wrap(spacing: 6.w, runSpacing: 6.h, children: p.features.map((f) => Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check_circle, color: p.color, size: 14),
                    SizedBox(width: 4.w),
                    Text(f, style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp)),
                  ])).toList()),
                ]),
              ),
            );
          }),

          SizedBox(height: 8.h),
          Center(child: Text('Отмена подписки в любое время', style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp))),
        ])),

        // Bottom CTA
        Container(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 36.h),
          decoration: const BoxDecoration(color: AppColors.bgCard, border: Border(top: BorderSide(color: AppColors.border))),
          child: SizedBox(
            width: double.infinity, height: 52.h,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _plans[_selected].color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4, shadowColor: _plans[_selected].color.withOpacity(0.4),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Подключить ${_plans[_selected].name}', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                SizedBox(width: 8.w),
                Text('— ${_fmt(_plans[_selected].pricePerMonth)} сум/мес',
                  style: TextStyle(fontSize: 12.sp, color: Colors.white70)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${n ~/ 1000000}.${(n % 1000000) ~/ 100000}M';
    if (n >= 1000) return '${n ~/ 1000}K';
    return '$n';
  }
}

class _Plan {
  final String name; final int pricePerMonth; final Color color;
  final List<String> features; final bool popular;
  const _Plan(this.name, this.pricePerMonth, this.color, this.features, {this.popular = false});
}
