import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('Заработок'), backgroundColor: AppColors.bgDark),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Today card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.green.withOpacity(0.3), AppColors.green.withOpacity(0.1)]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.green.withOpacity(0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('СЕГОДНЯ', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('144 000', style: TextStyle(color: AppColors.textPrimary, fontSize: 34, fontWeight: FontWeight.w700, fontFamily: 'DM Sans')),
              Row(children: [
                const Text('сум · ', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                const Text('8 доставок', style: TextStyle(color: AppColors.green, fontSize: 14, fontWeight: FontWeight.w600)),
              ]),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _PeriodCard('Неделя', '892K', '47 дост.')),
            const SizedBox(width: 10),
            Expanded(child: _PeriodCard('Месяц', '3.2M', '182 дост.')),
          ]),
          const SizedBox(height: 20),
          // Bar chart
          const Text('ПОСЛЕДНИЕ 7 ДНЕЙ', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 200,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) => Text(
                      ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'][v.toInt()],
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                    ),
                  )),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: [120, 85, 144, 98, 130, 160, 90].asMap().entries.map((e) =>
                  BarChartGroupData(x: e.key, barRods: [
                    BarChartRodData(
                      toY: e.value.toDouble(),
                      color: e.key == 2 ? AppColors.green : AppColors.green.withOpacity(0.4),
                      width: 26, borderRadius: BorderRadius.circular(6),
                    ),
                  ])
                ).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('ИСТОРИЯ ВЫПЛАТ', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ..._transactions.map((t) => _TransactionRow(t)),
        ],
      ),
    );
  }

  static final _transactions = [
    {'label': 'Доставка #A14F22', 'date': 'Сегодня 14:32', 'amount': 18000, 'type': 'plus'},
    {'label': 'Доставка #B9C11A', 'date': 'Сегодня 12:15', 'amount': 22000, 'type': 'plus'},
    {'label': 'Вывод на карту',   'date': 'Вчера 20:00',   'amount': 500000, 'type': 'minus'},
    {'label': 'Доставка #C77D03', 'date': 'Вчера 16:44',   'amount': 15000, 'type': 'plus'},
  ];
}

class _PeriodCard extends StatelessWidget {
  final String period, amount, subs;
  const _PeriodCard(this.period, this.amount, this.subs);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(period, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      Text('$amount сум', style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
      Text(subs, style: const TextStyle(color: AppColors.green, fontSize: 11)),
    ]),
  );
}

class _TransactionRow extends StatelessWidget {
  final Map<String, dynamic> t;
  const _TransactionRow(this.t);
  @override
  Widget build(BuildContext context) {
    final isPlus = t['type'] == 'plus';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(width: 38, height: 38,
          decoration: BoxDecoration(color: isPlus ? AppColors.green.withOpacity(0.12) : AppColors.red.withOpacity(0.12), shape: BoxShape.circle),
          child: Center(child: Text(isPlus ? '↗️' : '↙️', style: const TextStyle(fontSize: 16)))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t['label'] as String, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
          Text(t['date'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ])),
        Text('${isPlus ? '+' : '-'}${FormatUtils.price(t['amount'] as int)}',
          style: TextStyle(color: isPlus ? AppColors.green : AppColors.red, fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
