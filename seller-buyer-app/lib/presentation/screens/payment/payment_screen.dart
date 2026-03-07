import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/format.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final int amountTiyin;
  const PaymentScreen({super.key, required this.orderId, required this.amountTiyin});
  @override State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selected = 'click';
  bool _loading = false;
  String? _error;

  Future<void> _pay() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = getIt<ApiClient>();
      if (_selected == 'cash') {
        if (mounted) _showSuccess();
        return;
      }
      final res = await api.initiatePayment(orderId: widget.orderId, provider: _selected);
      final payUrl = res['payUrl'] as String;
      final uri = Uri.parse(payUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) _checkStatus();
      } else {
        setState(() => _error = 'Не удалось открыть платёжную страницу');
      }
    } catch (e) {
      setState(() => _error = 'Ошибка: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkStatus() async {
    try {
      final api = getIt<ApiClient>();
      final status = await api.getPaymentStatus(widget.orderId);
      if (mounted && status == 'paid') _showSuccess();
    } catch (_) {}
  }

  void _showSuccess() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72.w, height: 72.w,
              decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
              child: Icon(Icons.check, color: Colors.white, size: 36.sp),
            ),
            SizedBox(height: 16.h),
            Text('Оплата прошла!', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 6.h),
            Text('Заказ подтверждён ✅', style: TextStyle(fontSize: 14.sp, color: AppColors.textMuted)),
            SizedBox(height: 24.h),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/home/feed'),
                child: const Text('На главную'),
              )),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Оплата'), leading: BackButton(onPressed: () => context.pop())),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Сумма
          Container(
            width: double.infinity, padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.accentBg, borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Column(children: [
              Text('К оплате', style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp)),
              SizedBox(height: 4.h),
              Text(FormatUtils.priceTiyin(widget.amountTiyin),
                style: TextStyle(color: AppColors.accent, fontSize: 28.sp, fontWeight: FontWeight.w800)),
            ]),
          ),
          SizedBox(height: 24.h),
          Text('Способ оплаты', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 12.h),
          _Option(s: _selected == 'click', onTap: () => setState(()=>_selected='click'),
            icon: '💳', name: 'Click', sub: 'Карта Uzcard / Humo / Visa', color: const Color(0xFF1F87E8)),
          SizedBox(height: 8.h),
          _Option(s: _selected == 'payme', onTap: () => setState(()=>_selected='payme'),
            icon: '🔵', name: 'Payme', sub: 'Payme кошелёк, любая карта', color: const Color(0xFF00AAFF)),
          SizedBox(height: 8.h),
          _Option(s: _selected == 'cash', onTap: () => setState(()=>_selected='cash'),
            icon: '💵', name: 'Наличными', sub: 'Оплата при получении', color: AppColors.green),
          const Spacer(),
          if (_error != null)
            Container(
              margin: EdgeInsets.only(bottom: 12.h), padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
              child: Text(_error!, style: TextStyle(color: AppColors.red, fontSize: 13.sp)),
            ),
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _pay,
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 54.h)),
              child: _loading
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_selected == 'cash' ? 'Подтвердить заказ' : 'Оплатить',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
            )),
          SizedBox(height: 12.h),
          Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.lock_outline, size: 11.sp, color: AppColors.textMuted),
            SizedBox(width: 4.w),
            Text('Безопасная оплата SSL', style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
          ])),
          SizedBox(height: 20.h),
        ]),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final bool s; final VoidCallback onTap;
  final String icon, name, sub; final Color color;
  const _Option({required this.s, required this.onTap, required this.icon, required this.name, required this.sub, required this.color});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: s ? color.withOpacity(0.08) : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: s ? color : Theme.of(context).dividerColor, width: s ? 2 : 1),
      ),
      child: Row(children: [
        Container(width: 42.w, height: 42.w,
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10.r)),
          child: Center(child: Text(icon, style: TextStyle(fontSize: 20.sp)))),
        SizedBox(width: 12.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
          Text(sub, style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted)),
        ])),
        s ? Icon(Icons.check_circle, color: color, size: 20.sp)
          : Icon(Icons.radio_button_unchecked, color: Theme.of(context).dividerColor, size: 20.sp),
      ]),
    ),
  );
}
