import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});
  @override State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String _role = 'buyer';
  final _nameCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  static const _roles = [
    {
      'id': 'buyer',
      'icon': '🛍️',
      'title': 'Покупатель',
      'subtitle': 'Покупаю товары через рилсы и витрины',
      'features': ['Бесплатно', 'Рилсы и лента', 'Чат с продавцами', 'Отслеживание заказов'],
    },
    {
      'id': 'seller',
      'icon': '🏪',
      'title': 'Продавец',
      'subtitle': 'Продаю товары через свою витрину',
      'features': ['До 20 товаров бесплатно', 'Рилсы о товарах', 'Заказы и аналитика', 'Верификация ИНН'],
    },
  ];

  Future<void> _continue() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);

    // If seller — go to verification flow
    if (_role == 'seller') {
      context.go(Routes.sellerVerify);
      return;
    }

    // Buyer — just go to feed (name update happens in profile)
    context.go(Routes.feed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 40.w, height: 40.w,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accent2]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text('G', style: TextStyle(
                      color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w700, fontFamily: 'Playfair',
                    ))),
                  ),
                  const Spacer(),
                  // Skip (already logged in users)
                  TextButton(
                    onPressed: () => context.go(Routes.feed),
                    child: Text('Пропустить', style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp)),
                  ),
                ]),
                SizedBox(height: 20.h),
                Text('Добро пожаловать!', style: TextStyle(
                  fontFamily: 'Playfair', fontSize: 26.sp,
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                )),
                SizedBox(height: 6.h),
                Text('Расскажите о себе', style: TextStyle(color: AppColors.textSecondary, fontSize: 15.sp)),
              ]),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // ── Name ─────────────────────────────────────────────
                  Text('КАК ВАС ЗОВУТ?', style: TextStyle(
                    color: AppColors.textMuted, fontSize: 11.sp,
                    fontWeight: FontWeight.w600, letterSpacing: 1.2,
                  )),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _nameCtrl,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp),
                      decoration: InputDecoration(
                        hintText: 'Ваше имя',
                        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 15.sp),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        prefixIcon: const Icon(Icons.person_outline, color: AppColors.textMuted),
                      ),
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // ── Role cards ────────────────────────────────────────
                  Text('КТО ВЫ?', style: TextStyle(
                    color: AppColors.textMuted, fontSize: 11.sp,
                    fontWeight: FontWeight.w600, letterSpacing: 1.2,
                  )),
                  SizedBox(height: 10.h),

                  ...(_roles as List<Map<String, dynamic>>).map((r) {
                    final selected = _role == r['id'];
                    return GestureDetector(
                      onTap: () => setState(() => _role = r['id'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.accent.withOpacity(0.08) : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected ? AppColors.accent : AppColors.border,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(children: [
                          Text(r['icon'] as String, style: TextStyle(fontSize: 32.sp)),
                          SizedBox(width: 14.w),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Text(r['title'] as String, style: TextStyle(
                                color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w700,
                              )),
                              const Spacer(),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 22, height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selected ? AppColors.accent : Colors.transparent,
                                  border: Border.all(
                                    color: selected ? AppColors.accent : AppColors.border, width: 2,
                                  ),
                                ),
                                child: selected
                                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                                  : null,
                              ),
                            ]),
                            SizedBox(height: 4.h),
                            Text(r['subtitle'] as String, style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12.sp,
                            )),
                            if (selected) ...[
                              SizedBox(height: 10.h),
                              Wrap(
                                spacing: 6, runSpacing: 6,
                                children: (r['features'] as List<String>).map((f) => Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(f, style: TextStyle(
                                    color: AppColors.accent, fontSize: 11.sp, fontWeight: FontWeight.w500,
                                  )),
                                )).toList(),
                              ),
                            ],
                          ])),
                        ]),
                      ),
                    );
                  }),
                  SizedBox(height: 24.h),
                ]),
              ),
            ),

            // ── Bottom CTA ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
              child: SizedBox(
                width: double.infinity, height: 52.h,
                child: ElevatedButton(
                  onPressed: _nameCtrl.text.trim().isNotEmpty && !_loading ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    disabledBackgroundColor: AppColors.bgCard,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                    shadowColor: AppColors.accent.withOpacity(0.4),
                  ),
                  child: _loading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(
                          _role == 'seller' ? 'Стать продавцом' : 'Начать покупать',
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(width: 6.w),
                        Icon(Icons.arrow_forward_ios, size: 14.sp),
                      ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
