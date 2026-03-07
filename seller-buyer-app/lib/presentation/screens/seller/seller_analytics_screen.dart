import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/format.dart';

class SellerAnalyticsScreen extends StatefulWidget {
  const SellerAnalyticsScreen({super.key});
  @override State<SellerAnalyticsScreen> createState() => _State();
}

class _State extends State<SellerAnalyticsScreen> {
  int _period = 7;
  bool _loading = true;
  Map<String, dynamic> _data = {};

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await getIt<ApiClient>().getSellerAnalytics(days: _period);
      setState(() { _data = res; _loading = false; });
    } catch (_) {
      // Mock data
      setState(() {
        _data = {
          'revenue':       12450000 * 100, // tiyins
          'revenueGrowth': 18.5,
          'orders':        47,
          'ordersGrowth':  12.3,
          'views':         2840,
          'viewsGrowth':   34.2,
          'conversion':    1.65,
          'chart': List.generate(_period, (i) => {
            'day': i,
            'revenue': (800000 + (i * 120000) + (i % 3 == 0 ? 500000 : 0)) * 100,
            'orders':  2 + i % 4,
          }),
          'topProducts': [
            {'title': 'Платье летнее Zara style', 'orders': 18, 'revenue': 3330000 * 100},
            {'title': 'Кроссовки Nike Air Max',   'orders': 12, 'revenue': 5040000 * 100},
            {'title': 'Помада матовая Rose',        'orders': 9,  'revenue': 801000 * 100},
          ],
        };
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Аналитика'),
        actions: [
          // Период
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: DropdownButton<int>(
              value: _period,
              underline: const SizedBox(),
              icon: const Icon(Icons.expand_more),
              items: const [
                DropdownMenuItem(value: 7,  child: Text('7 дней')),
                DropdownMenuItem(value: 30, child: Text('30 дней')),
                DropdownMenuItem(value: 90, child: Text('90 дней')),
              ],
              onChanged: (v) { setState(() => _period = v!); _load(); },
            ),
          ),
        ],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
        : RefreshIndicator(
            color: AppColors.accent,
            onRefresh: _load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // KPI карточки
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10.h, crossAxisSpacing: 10.w, childAspectRatio: 1.6,
                  children: [
                    _KpiCard('Выручка', FormatUtils.priceTiyin(_data['revenue'] ?? 0),
                      _data['revenueGrowth']?.toDouble() ?? 0, Icons.trending_up, AppColors.accent),
                    _KpiCard('Заказы', '${_data['orders'] ?? 0}',
                      _data['ordersGrowth']?.toDouble() ?? 0, Icons.shopping_bag_outlined, const Color(0xFF9C27B0)),
                    _KpiCard('Просмотры', '${_data['views'] ?? 0}',
                      _data['viewsGrowth']?.toDouble() ?? 0, Icons.visibility_outlined, const Color(0xFF1F87E8)),
                    _KpiCard('Конверсия', '${(_data['conversion'] ?? 0).toStringAsFixed(2)}%',
                      0, Icons.percent, AppColors.green),
                  ],
                ),
                SizedBox(height: 20.h),

                // График выручки
                _SectionTitle('Выручка за $_period дней'),
                SizedBox(height: 12.h),
                _RevenueChart(data: List<Map>.from(_data['chart'] ?? []), period: _period),
                SizedBox(height: 20.h),

                // Топ товары
                _SectionTitle('Топ товары'),
                SizedBox(height: 12.h),
                ...(((_data['topProducts'] as List?) ?? []).map((p) =>
                  _TopProductRow(product: Map<String,dynamic>.from(p)))),

                SizedBox(height: 20.h),
                // Советы
                _TipsCard(),
              ]),
            ),
          ),
    );
  }
}

// ── KPI карточка ─────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String label, value;
  final double growth;
  final IconData icon;
  final Color color;
  const _KpiCard(this.label, this.value, this.growth, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgCard : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(width: 32.w, height: 32.w,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8.r)),
            child: Icon(icon, color: color, size: 16.sp)),
          const Spacer(),
          if (growth != 0) Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: (growth > 0 ? AppColors.green : AppColors.red).withOpacity(0.12),
              borderRadius: BorderRadius.circular(6.r)),
            child: Text(
              '${growth > 0 ? '+' : ''}${growth.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w700,
                color: growth > 0 ? AppColors.green : AppColors.red)),
          ),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800,
            color: Theme.of(context).textTheme.titleLarge?.color)),
          Text(label, style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted)),
        ]),
      ]),
    );
  }
}

// ── График ─────────────────────────────────────────────────────────────────
class _RevenueChart extends StatelessWidget {
  final List<Map> data;
  final int period;
  const _RevenueChart({required this.data, required this.period});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (data.isEmpty) return const SizedBox();

    final spots = data.asMap().entries.map((e) =>
      FlSpot(e.key.toDouble(), ((e.value['revenue'] as num?) ?? 0) / 10000000)).toList();

    return Container(
      height: 180.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgCard : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: LineChart(LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: AppColors.textMuted.withOpacity(0.15), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, interval: period <= 7 ? 1 : 7,
            getTitlesWidget: (v, _) => Text('${v.toInt()+1}',
              style: TextStyle(fontSize: 9.sp, color: AppColors.textMuted)),
          )),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.accent,
          barWidth: 2.5,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [AppColors.accent.withOpacity(0.2), AppColors.accent.withOpacity(0)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
          ),
        )],
      )),
    );
  }
}

// ── Топ товар ──────────────────────────────────────────────────────────────
class _TopProductRow extends StatelessWidget {
  final Map<String,dynamic> product;
  const _TopProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgCard : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(children: [
        Container(width: 40.w, height: 40.w,
          decoration: BoxDecoration(color: AppColors.accentBg, borderRadius: BorderRadius.circular(10.r)),
          child: Icon(Icons.shopping_bag_outlined, color: AppColors.accent, size: 20.sp)),
        SizedBox(width: 12.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(product['title'] as String? ?? '', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${product['orders']} заказов', style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted)),
        ])),
        Text(FormatUtils.priceTiyin((product['revenue'] as num?)?.toInt() ?? 0),
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.accent)),
      ]),
    );
  }
}

// ── Советы ─────────────────────────────────────────────────────────────────
class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.accent, AppColors.accent.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('💡', style: TextStyle(fontSize: 20.sp)),
          SizedBox(width: 8.w),
          Text('Советы по увеличению продаж', style: TextStyle(
            color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w700)),
        ]),
        SizedBox(height: 12.h),
        _Tip('Добавьте больше фото к товарам (+23% к конверсии)'),
        _Tip('Публикуйте рилсы ежедневно (+40% к охвату)'),
        _Tip('Отвечайте на сообщения в течение часа'),
      ]),
    );
  }
}

class _Tip extends StatelessWidget {
  final String text;
  const _Tip(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 6.h),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('• ', style: TextStyle(color: Colors.white.withOpacity(0.70), fontSize: 13.sp)),
      Expanded(child: Text(text, style: TextStyle(color: Colors.white.withOpacity(0.70), fontSize: 12.sp, height: 1.4))),
    ]),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(
    fontSize: 16.sp, fontWeight: FontWeight.w800,
    color: Theme.of(context).textTheme.titleLarge?.color));
}
