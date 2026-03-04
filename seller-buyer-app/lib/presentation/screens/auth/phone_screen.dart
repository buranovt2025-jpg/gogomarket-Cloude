import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/app_router.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});
  @override State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  bool _loading = false;
  late AnimationController _btnAnim;
  late Animation<double> _btnScale;

  @override
  void initState() {
    super.initState();
    _btnAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _btnScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _btnAnim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _btnAnim.dispose();
    super.dispose();
  }

  bool get _valid => _ctrl.text.replaceAll(' ', '').length == 9;

  String get _phone => '+998${_ctrl.text.replaceAll(' ', '')}';

  Future<void> _sendOtp() async {
    if (!_valid || _loading) return;
    await _btnAnim.forward();
    await _btnAnim.reverse();

    setState(() => _loading = true);
    try {
      await getIt<ApiClient>().sendOtp({'phone': _phone});
      if (mounted) {
        context.push('${Routes.otp}?phone=${Uri.encodeComponent(_phone)}');
      }
    } on Exception catch (e) {
      if (mounted) {
        _showError(e.toString().replaceAll('Exception:', '').trim());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
      ]),
      backgroundColor: AppColors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16.h),
    ));
  }

  // Format input as "90 123 45 67"
  String _format(String raw) {
    final d = raw.replaceAll(' ', '');
    final buf = StringBuffer();
    for (int i = 0; i < d.length && i < 9; i++) {
      if (i == 2 || i == 5 || i == 7) buf.write(' ');
      buf.write(d[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 48.h),

              // ── Logo ─────────────────────────────────────────────────
              Container(
                width: 64.w, height: 64.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accent2],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text('G', style: TextStyle(
                    color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.w700, fontFamily: 'Playfair',
                  )),
                ),
              ),
              SizedBox(height: 24.h),

              Text('GogoMarket', style: TextStyle(
                fontFamily: 'Playfair', fontSize: 28.sp,
                fontWeight: FontWeight.w700, color: AppColors.textPrimary,
              )),
              SizedBox(height: 6.h),
              Text('Введите номер для входа', style: TextStyle(
                color: AppColors.textSecondary, fontSize: 15.sp,
              )),
              SizedBox(height: 40.h),

              // ── Phone input ───────────────────────────────────────────
              Text('НОМЕР ТЕЛЕФОНА', style: TextStyle(
                color: AppColors.textMuted, fontSize: 11.sp,
                fontWeight: FontWeight.w600, letterSpacing: 1.2,
              )),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _valid ? AppColors.accent.withOpacity(0.6) : AppColors.border,
                    width: _valid ? 1.5 : 1,
                  ),
                ),
                child: Row(children: [
                  // Country code
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('🇺🇿', style: TextStyle(fontSize: 18.sp)),
                      SizedBox(width: 6.w),
                      Text('+998', style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w600,
                      )),
                    ]),
                  ),
                  // Number input
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 18.sp,
                        fontWeight: FontWeight.w500, letterSpacing: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: '90 123 45 67',
                        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 16.sp, letterSpacing: 1),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                      onChanged: (v) {
                        final raw = v.replaceAll(' ', '');
                        if (raw.length <= 9) {
                          final formatted = _format(raw);
                          _ctrl.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(offset: formatted.length),
                          );
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  if (_valid)
                    Padding(
                      padding: EdgeInsets.only(right: 14.w),
                      child: const Icon(Icons.check_circle, color: AppColors.accent, size: 20),
                    ),
                ]),
              ),
              SizedBox(height: 12.h),
              Text(
                'Отправим SMS-код на этот номер',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
              ),
              SizedBox(height: 28.h),

              // ── Button ────────────────────────────────────────────────
              ScaleTransition(
                scale: _btnScale,
                child: SizedBox(
                  width: double.infinity, height: 52.h,
                  child: ElevatedButton(
                    onPressed: _valid && !_loading ? _sendOtp : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      disabledBackgroundColor: AppColors.bgCard,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: _valid ? 4 : 0,
                      shadowColor: AppColors.accent.withOpacity(0.4),
                    ),
                    child: _loading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text('Получить код', style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // ── Social hint ───────────────────────────────────────────
              Row(children: [
                const Expanded(child: Divider(color: AppColors.border)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text('GogoMarket', style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
                ),
                const Expanded(child: Divider(color: AppColors.border)),
              ]),
              SizedBox(height: 20.h),
              Center(
                child: Text(
                  'Регистрируясь, вы принимаете\nПравила использования и Политику конфиденциальности',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
