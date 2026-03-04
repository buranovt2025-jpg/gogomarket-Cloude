import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/format_utils.dart';
import '../../blocs/admin/admin_bloc.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminBloc>()..add(AdminLoadFinance()),
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(title: const Text('Финансы'), backgroundColor: AppColors.bgDark),
        body: BlocConsumer<AdminBloc, AdminState>(
          listener: (ctx, state) {
            if (state.toast != null) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(state.toast!), backgroundColor: AppColors.bgCard,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
            }
          },
          builder: (ctx, state) {
            final d = state.financeData;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // GMV card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.purple.withOpacity(0.4), AppColors.purple.withOpacity(0.15)]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.purple.withOpacity(0.3)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('ОБОРОТ (GMV) · МЕСЯЦ', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('${d['gmv'] ?? '847 200 000'} сум',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                        child: const Text('▲ +12.4% к прошлому месяцу', style: TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.w600))),
                    ]),
                  ]),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _FinCard('Комиссия', '${d['commission'] ?? '25 416 000'}', 'сум', AppColors.green)),
                  const SizedBox(width: 10),
                  Expanded(child: _FinCard('Подписки', '${d['subscriptions'] ?? '6 820 000'}', 'сум', AppColors.blue)),
                  const SizedBox(width: 10),
                  Expanded(child: _FinCard('Бусты', '${d['boosts'] ?? '4 100 000'}', 'сум', AppColors.gold)),
                ]),
                const SizedBox(height: 20),

                // Withdrawal requests
                const Text('ЗАПРОСЫ НА ВЫВОД', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                ..._mockWithdrawals.map((w) => _WithdrawalRow(w: w,
                  approved: state.approvedWithdrawals.contains(w['id'] as String))),
              ],
            );
          },
        ),
      ),
    );
  }

  static const _mockWithdrawals = [
    {'id': 'wd-001', 'seller': 'Aisha Fashion',   'amount': 850000, 'card': 'Uzcard ****4521', 'dt': '09:14'},
    {'id': 'wd-002', 'seller': 'TechStore UZ',    'amount': 2300000, 'card': 'Humo ****7734',  'dt': '08:55'},
    {'id': 'wd-003', 'seller': 'SportZone',       'amount': 540000, 'card': 'Uzcard ****1102', 'dt': 'Вчера'},
  ];
}

class _FinCard extends StatelessWidget {
  final String label, value, unit; final Color color;
  const _FinCard(this.label, this.value, this.unit, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
    child: Column(children: [
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
      Text(unit, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
    ]),
  );
}

class _WithdrawalRow extends StatelessWidget {
  final Map<String, dynamic> w; final bool approved;
  const _WithdrawalRow({required this.w, required this.approved});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: approved ? AppColors.green.withOpacity(0.4) : AppColors.border)),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(
        color: approved ? AppColors.green.withOpacity(0.1) : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(10)),
        child: const Center(child: Text('💸', style: TextStyle(fontSize: 18)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(w['seller'] as String, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
        Text('${w['card']} · ${w['dt']}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ])),
      if (approved)
        const Icon(Icons.check_circle, color: AppColors.green, size: 20)
      else
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(FormatUtils.price(w['amount'] as int),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => context.read<AdminBloc>().add(AdminApproveWithdrawal(w['id'] as String)),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: AppColors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.green.withOpacity(0.3))),
              child: const Text('Выплатить', style: TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.w600))),
          ),
        ]),
    ]),
  );
}
