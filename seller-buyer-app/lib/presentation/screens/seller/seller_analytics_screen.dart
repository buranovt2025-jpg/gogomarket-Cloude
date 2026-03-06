import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format.dart';

class SellerAnalyticsScreen extends StatefulWidget {
  const SellerAnalyticsScreen({super.key});
  @override State<SellerAnalyticsScreen> createState() => _SellerAnalyticsScreenState();
}

class _SellerAnalyticsScreenState extends State<SellerAnalyticsScreen> {
  int _period = 7; // days

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text('Аналитика', style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.bgDark, foregroundColor: AppColors.textPrimary,
        actions: [
          _PeriodBtn('7д',  7),
          _PeriodBtn('30д', 30),
          _PeriodBtn('90д', 90),
          SizedBox(width: 8.w),
        ],
      ),
      body: ListView(padding: EdgeInsets.all(16.w), children: [
        // KPI
        GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10.w, mainAxisSpacing: 10.h, childAspectRatio: 1.6,
          children: [
            _KpiCard('Выручка',     '2 400 000', 'сум', '+18%', AppColors.green),
            _KpiCard('Заказов',     '47',         'шт',  '+5',   AppColors.blue),
            _KpiCard('Просмотры',   '3 210',      'чел', '+32%', AppColors.purple),
            _KpiCard('Конверсия',   '1.46%',      '',    '+0.3%',AppColors.gold),
          ],
        ),
        SizedBox(height: 20.h),

        // Revenue chart
        _ChartBox('Выручка (тыс. сум)', LineChart(LineChartData(
          gridData: FlGridData(drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1)),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1,
              getTitlesWidget: (v, _) => Text(['Пн','Вт','Ср','Чт','Пт','Сб','Вс'][v.toInt()],
                style: TextStyle(color: AppColors.textMuted, fontSize: 9.sp)))),
          ),
          lineBarsData: [LineChartBarData(
            spots: [180.0, 240, 190, 350, 280, 420, 390].asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList(),
            isCurved: true, color: AppColors.accent, barWidth: 2.5,
            dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 3, color: AppColors.accent, strokeWidth: 1, strokeColor: Colors.white)),
            belowBarData: BarAreaData(show: true, color: AppColors.accent.withOpacity(0.08)),
          )],
        ))),
        SizedBox(height: 16.h),

        // Top products
        Text('ТОП ТОВАРЫ', style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp, fontWeight: FontWeight.w600, letterSpacing: 1)),
        SizedBox(height: 10.h),
        ..._topProducts.asMap().entries.map((e) => _TopRow(rank: e.key + 1, item: e.value)),
        SizedBox(height: 40.h),
      ]),
    );
  }

  Widget _PeriodBtn(String label, int days) => GestureDetector(
    onTap: () => setState(() => _period = days),
    child: Container(margin: EdgeInsets.only(left: 4.w), padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: _period == days ? AppColors.accent : AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _period == days ? AppColors.accent : AppColors.border),
      ),
      child: Text(label, style: TextStyle(color: _period == days ? Colors.white : AppColors.textMuted, fontSize: 11.sp, fontWeight: FontWeight.w600))),
  );

  static const _topProducts = [
    ('Платье летнее Zara style', 850000, 18),
    ('Топ базовый белый',         420000, 12),
    ('Брюки wide leg',            630000, 9),
    ('Блуза шёлковая',            390000, 7),
  ];
}

class _KpiCard extends StatelessWidget {
  final String label, value, unit, delta; final Color color;
  const _KpiCard(this.label, this.value, this.unit, this.delta, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 10.sp)),
      const Spacer(),
      RichText(text: TextSpan(children: [
        TextSpan(text: value, style: TextStyle(color: color, fontSize: 18.sp, fontWeight: FontWeight.w800)),
        if (unit.isNotEmpty) TextSpan(text: ' $unit', style: TextStyle(color: AppColors.textMuted, fontSize: 10.sp)),
      ])),
      if (delta.isNotEmpty)
        Text(delta, style: TextStyle(color: AppColors.green, fontSize: 10.sp, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _ChartBox extends StatelessWidget {
  final String title; final Widget chart;
  const _ChartBox(this.title, this.chart);
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: 13.sp, fontWeight: FontWeight.w600)),
      SizedBox(height: 16.h),
      SizedBox(height: 150.h, child: chart),
    ]),
  );
}

class _TopRow extends StatelessWidget {
  final int rank; final (String, int, int) item;
  const _TopRow({required this.rank, required this.item});
  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 8.h),
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
    child: Row(children: [
      Text('$rank', style: TextStyle(color: rank == 1 ? AppColors.gold : AppColors.textMuted, fontSize: 15.sp, fontWeight: FontWeight.w700)),
      SizedBox(width: 12.w),
      Expanded(child: Text(item.$1, style: TextStyle(color: AppColors.textPrimary, fontSize: 13.sp, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(FormatUtils.price(item.$2), style: TextStyle(color: AppColors.textPrimary, fontSize: 13.sp, fontWeight: FontWeight.w600)),
        Text('${item.$3} прод.', style: TextStyle(color: AppColors.textMuted, fontSize: 10.sp)),
      ]),
    ]),
  );
}
