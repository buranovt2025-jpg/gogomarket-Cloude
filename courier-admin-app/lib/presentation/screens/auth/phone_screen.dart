import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/di/injection.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});
  @override State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  Future<void> _send() async {
    final phone = '+998${_ctrl.text.replaceAll(' ', '')}';
    if (_ctrl.text.length < 9) return;
    setState(() => _loading = true);
    try {
      await getIt<ApiClient>().sendOtp({'phone': phone});
      if (mounted) context.push('/auth/otp?phone=${Uri.encodeComponent(phone)}');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: AppColors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text('🛍️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text('GogoMarket\nStaff', style: TextStyle(
                color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w700,
              )),
              const SizedBox(height: 8),
              const Text('Курьер и Администратор', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
              const Spacer(),
              const Text('НОМЕР ТЕЛЕФОНА', style: TextStyle(
                color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1,
              )),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: AppColors.border)),
                      ),
                      child: const Text('+998', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9),
                        ],
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: '90 123 45 67',
                          hintStyle: TextStyle(color: AppColors.textMuted),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _ctrl.text.length >= 9 && !_loading ? _send : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    disabledBackgroundColor: AppColors.bgCard,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Получить код', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
