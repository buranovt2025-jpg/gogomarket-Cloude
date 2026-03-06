import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: const _PhoneBody(),
    );
  }
}

class _PhoneBody extends StatefulWidget {
  const _PhoneBody();
  @override State<_PhoneBody> createState() => _PhoneBodyState();
}

class _PhoneBodyState extends State<_PhoneBody> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  String get _phone => '+998${_ctrl.text.replaceAll(RegExp(r'\D'), '')}';
  bool get _valid  => _ctrl.text.replaceAll(RegExp(r'\D'), '').length == 9;

  Future<void> _send() async {
    if (!_valid || _loading) return;
    setState(() => _loading = true);
    context.read<AuthBloc>().add(AuthSendOtpEvent(_phone));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthOtpSent) {
          setState(() => _loading = false);
          ctx.push('${Routes.otp}?phone=${Uri.encodeComponent(state.phone)}');
        } else if (state is AuthError) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60.h),
                Center(
                  child: Text('GogoMarket', style: TextStyle(
                    color: AppColors.accent, fontSize: 28.sp, fontWeight: FontWeight.w800,
                  )),
                ),
                SizedBox(height: 48.h),
                Text('Введите номер телефона', style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 22.sp, fontWeight: FontWeight.w700,
                )),
                SizedBox(height: 8.h),
                Text('Мы отправим код подтверждения', style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 14.sp,
                )),
                SizedBox(height: 32.h),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Text('+998 ', style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp)),
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp),
                          decoration: const InputDecoration(
                            border: InputBorder.none, hintText: '90 123 45 67',
                            hintStyle: TextStyle(color: AppColors.textMuted),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _valid ? _send : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : Text('Получить код', style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
