import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../../core/router/app_router.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});
  @override State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _code = '';
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() { if (_countdown > 0) _countdown--; });
      return _countdown > 0;
    });
  }

  void _verify() {
    if (_code.length == 4) {
      context.read<AuthBloc>().add(AuthLoginEvent(phone: widget.phone, code: _code));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthAuthenticated) {
          if (state.user.isCourier) ctx.go(Routes.courierMap);
          else if (state.user.isAdmin) ctx.go(Routes.adminDashboard);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text('Неверный код: ${state.message}'), backgroundColor: AppColors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(title: const Text('Подтверждение'), backgroundColor: AppColors.bgDark, foregroundColor: AppColors.textPrimary),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text('Код отправлен на\n${widget.phone}',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 32),
              PinCodeTextField(
                appContext: context,
                length: 4,
                animationType: AnimationType.fade,
                keyboardType: TextInputType.number,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 56,
                  fieldWidth: 56,
                  activeFillColor: AppColors.bgCard,
                  inactiveFillColor: AppColors.bgCard,
                  selectedFillColor: AppColors.bgCard,
                  activeColor: AppColors.green,
                  inactiveColor: AppColors.border,
                  selectedColor: AppColors.green,
                ),
                enableActiveFill: true,
                textStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                onChanged: (v) => setState(() => _code = v),
                onCompleted: (_) => _verify(),
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (ctx, state) => SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: _code.length == 4 && state is! AuthLoading ? _verify : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: state is AuthLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Войти', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: _countdown > 0
                  ? Text('Повторить через ${_countdown}с', style: const TextStyle(color: AppColors.textMuted))
                  : TextButton(onPressed: _startTimer, child: const Text('Отправить снова', style: TextStyle(color: AppColors.green))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
