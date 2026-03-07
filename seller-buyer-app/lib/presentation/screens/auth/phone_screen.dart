import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';

class PhoneScreen extends StatelessWidget {
  const PhoneScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<AuthBloc>(),
    child: const _PhoneBody(),
  );
}

class _PhoneBody extends StatefulWidget {
  const _PhoneBody();
  @override State<_PhoneBody> createState() => _PhoneBodyState();
}

class _PhoneBodyState extends State<_PhoneBody> {
  final _ctrl  = TextEditingController();
  final _focus = FocusNode();
  bool _loading = false;

  String get _phone => '+998${_ctrl.text.replaceAll(RegExp(r'\D'), '')}';
  bool   get _valid  => _ctrl.text.replaceAll(RegExp(r'\D'), '').length == 9;

  @override void dispose() { _ctrl.dispose(); _focus.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (!_valid || _loading) return;
    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    context.read<AuthBloc>().add(AuthSendOtpEvent(_phone));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthOtpSent) {
          setState(() => _loading = false);
          ctx.push('${Routes.otp}?phone=${Uri.encodeComponent(state.phone)}');
        } else if (state is AuthError) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
          ));
        }
      },
      child: GestureDetector(
        onTap: () => _focus.unfocus(),
        child: Scaffold(
          backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
          body: SafeArea(
            child: Column(children: [
              // ── Top decorative block ────────────────────────────────
              Expanded(
                flex: 4,
                child: Stack(children: [
                  // Background gradient blob
                  Positioned(
                    top: -60.h, left: -40.w,
                    child: Container(
                      width: 260.w, height: 260.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          AppColors.accent.withOpacity(isDark ? 0.18 : 0.12),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0.h, right: -60.w,
                    child: Container(
                      width: 180.w, height: 180.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          AppColors.accent.withOpacity(isDark ? 0.10 : 0.07),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                  // Logo + welcome text
                  Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      // Logo icon
                      Container(
                        width: 80.w, height: 80.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22.r),
                          gradient: const LinearGradient(
                            colors: [AppColors.accent, Color(0xFFFF8533)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.4),
                              blurRadius: 24, offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text('G', style: TextStyle(
                            color: Colors.white, fontSize: 42.sp,
                            fontWeight: FontWeight.w900, fontFamily: 'Playfair',
                          )),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text('GogoMarket', style: TextStyle(
                        fontSize: 28.sp, fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                        letterSpacing: -0.5,
                      )),
                      SizedBox(height: 6.h),
                      Text('Маркетплейс нового поколения', style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark ? Colors.white.withOpacity(0.38) : Colors.black.withOpacity(0.38),
                        fontWeight: FontWeight.w500,
                      )),
                    ]),
                  ),
                ]),
              ),

              // ── Bottom input block ──────────────────────────────────
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141414) : const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                        blurRadius: 24, offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Войти', style: TextStyle(
                      fontSize: 26.sp, fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF111111),
                      letterSpacing: -0.3,
                    )),
                    SizedBox(height: 5.h),
                    Text('Введите номер телефона', style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.white.withOpacity(0.38) : Colors.black.withOpacity(0.38),
                    )),
                    SizedBox(height: 28.h),

                    // Phone input
                    Text('Номер телефона', style: TextStyle(
                      fontSize: 12.sp, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white.withOpacity(0.54) : Colors.black.withOpacity(0.54),
                      letterSpacing: 0.5,
                    )),
                    SizedBox(height: 8.h),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: _focus.hasFocus
                            ? AppColors.accent
                            : (isDark ? Colors.white10 : Colors.black.withOpacity(0.08)),
                          width: _focus.hasFocus ? 1.5 : 1,
                        ),
                        boxShadow: _focus.hasFocus ? [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.15),
                            blurRadius: 12, offset: const Offset(0, 4),
                          ),
                        ] : [],
                      ),
                      child: Row(children: [
                        SizedBox(width: 16.w),
                        // Flag + prefix
                        Row(children: [
                          Text('🇺🇿', style: TextStyle(fontSize: 18.sp)),
                          SizedBox(width: 8.w),
                          Text('+998', style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black.withOpacity(0.87),
                          )),
                        ]),
                        // Divider
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                          width: 1, height: 22.h,
                          color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.12),
                        ),
                        // Input
                        Expanded(
                          child: TextField(
                            controller: _ctrl,
                            focusNode: _focus,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                              fontSize: 17.sp, fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black.withOpacity(0.87),
                              letterSpacing: 0.5,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(9),
                            ],
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '90 123 45 67',
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white.withOpacity(0.20) : Colors.black.withOpacity(0.20),
                                fontSize: 16.sp, fontWeight: FontWeight.w400,
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                            ),
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Clear
                        if (_ctrl.text.isNotEmpty)
                          GestureDetector(
                            onTap: () { _ctrl.clear(); setState(() {}); },
                            child: Padding(
                              padding: EdgeInsets.only(right: 12.w),
                              child: Icon(Icons.close_rounded,
                                color: isDark ? Colors.white.withOpacity(0.30) : Colors.black.withOpacity(0.30), size: 18.sp),
                            ),
                          ),
                      ]),
                    ),
                    SizedBox(height: 24.h),

                    // CTA Button
                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: ElevatedButton(
                          onPressed: _valid ? _send : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            disabledBackgroundColor: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r)),
                            elevation: _valid ? 6 : 0,
                            shadowColor: AppColors.accent.withOpacity(0.45),
                          ),
                          child: _loading
                            ? SizedBox(width: 22.w, height: 22.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                            : Text('Получить код',
                                style: TextStyle(
                                  fontSize: 16.sp, fontWeight: FontWeight.w800,
                                  color: _valid ? Colors.white
                                    : (isDark ? Colors.white.withOpacity(0.20) : Colors.black.withOpacity(0.20)),
                                  letterSpacing: 0.3,
                                )),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    Center(child: Text(
                      'Нажимая «Получить код» вы принимаете\nПользовательское соглашение',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? Colors.white.withOpacity(0.24) : Colors.black.withOpacity(0.24),
                        height: 1.6,
                      ),
                    )),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
