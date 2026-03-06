import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});
  @override State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _streamCtrl = StreamController<ErrorAnimationType>();
  String _code = '';
  int _countdown = 60;
  bool _loading = false;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamCtrl.close();
    super.dispose();
  }

  void _startCountdown() {
    setState(() { _countdown = 60; _canResend = false; });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_countdown > 0) { _countdown--; }
        else { _canResend = true; t.cancel(); }
      });
    });
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    try {
      context.read<AuthBloc>().add(AuthSendOtpEvent(widget.phone));
      _startCountdown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Код отправлен повторно'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (_) {}
  }

  Future<void> _verify() async {
    if (_code.length != 4 || _loading) return;
    setState(() => _loading = true);
    context.read<AuthBloc>().add(
      AuthVerifyOtpEvent(phone: widget.phone, code: _code),
    );
  }

  void _onAuthState(BuildContext ctx, AuthState state) {
    if (state is AuthVerifying) return;
    setState(() => _loading = false);

    if (state is AuthAuthenticated) {
      // Route based on role and onboarding status
      if (state.user.isSeller) {
        ctx.go(Routes.dashboard);
      } else if (state.user.isBuyer) {
        // Check if new user needs role selection (no name set)
        if (state.user.name == null || state.user.name!.isEmpty) {
          ctx.go(Routes.roleSelect);
        } else {
          ctx.go(Routes.feed);
        }
      } else {
        ctx.go(Routes.feed);
      }
    } else if (state is AuthError) {
      _streamCtrl.add(ErrorAnimationType.shake);
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(
            state.message.contains('Invalid') ? 'Неверный код' : state.message,
          )),
        ]),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  String get _maskedPhone {
    if (widget.phone.length >= 12) {
      return '${widget.phone.substring(0, 7)}***${widget.phone.substring(10)}';
    }
    return widget.phone;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _onAuthState,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                // ── Header ────────────────────────────────────────────
                Text('Введите код', style: TextStyle(
                  fontFamily: 'Playfair', fontSize: 28.sp,
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                )),
                SizedBox(height: 8.h),
                RichText(text: TextSpan(
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 15.sp),
                  children: [
                    const TextSpan(text: 'SMS отправлен на '),
                    TextSpan(
                      text: _maskedPhone,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                  ],
                )),
                SizedBox(height: 40.h),

                // ── PIN input ─────────────────────────────────────────
                PinCodeTextField(
                  appContext: context,
                  length: 4,
                  errorAnimationController: _streamCtrl,
                  animationType: AnimationType.fade,
                  keyboardType: TextInputType.number,
                  autoFocus: true,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(14),
                    fieldHeight: 60.h,
                    fieldWidth: 60.w,
                    activeFillColor: AppColors.bgCard,
                    inactiveFillColor: AppColors.bgCard,
                    selectedFillColor: AppColors.bgSurface,
                    activeColor: AppColors.accent,
                    inactiveColor: AppColors.border,
                    selectedColor: AppColors.accent,
                    errorBorderColor: AppColors.red,
                  ),
                  enableActiveFill: true,
                  cursorColor: AppColors.accent,
                  textStyle: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  onChanged: (v) => setState(() => _code = v),
                  onCompleted: (_) => _verify(),
                  beforeTextPaste: (text) => text?.length == 4,
                ),
                SizedBox(height: 32.h),

                // ── Verify button ─────────────────────────────────────
                SizedBox(
                  width: double.infinity, height: 52.h,
                  child: ElevatedButton(
                    onPressed: _code.length == 4 && !_loading ? _verify : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      disabledBackgroundColor: AppColors.bgCard,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: _code.length == 4 ? 4 : 0,
                      shadowColor: AppColors.accent.withOpacity(0.4),
                    ),
                    child: _loading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text('Подтвердить', style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
                SizedBox(height: 20.h),

                // ── Resend ────────────────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: _canResend ? _resend : null,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _canResend
                        ? Text('Отправить снова', key: const ValueKey('resend'),
                            style: TextStyle(
                              color: AppColors.accent, fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.accent,
                            ))
                        : RichText(
                            key: const ValueKey('countdown'),
                            text: TextSpan(
                              style: TextStyle(fontSize: 14.sp, color: AppColors.textMuted),
                              children: [
                                const TextSpan(text: 'Повторить через '),
                                TextSpan(
                                  text: '${_countdown}с',
                                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                    ),
                  ),
                ),

                const Spacer(),

                // ── Dev hint ──────────────────────────────────────────
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text('DEV: код 1234', style: TextStyle(
                      color: AppColors.textMuted, fontSize: 11.sp,
                    )),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
