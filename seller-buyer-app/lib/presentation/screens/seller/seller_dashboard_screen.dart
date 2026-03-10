import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/format.dart';
import '../../blocs/auth/auth_bloc.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _Header()),
        SliverToBoxAdapter(child: _KpiRow()),
        // Show weekly limits card only for tier 2
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated && state.user.tier == 2) {
              return SliverToBoxAdapter(child: _WeeklyLimitsCard());
            }
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          },
        ),
        SliverToBoxAdapter(child: _RevenueChart()),
        SliverToBoxAdapter(child: _QuickActions()),
        SliverToBoxAdapter(child: _RecentOrders()),
      ])),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.addProduct),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add),
        label: Text('Добавить товар', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Кабинет продавца', style: TextStyle(fontFamily: 'Playfair', fontSize: 22.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text('Добро пожаловать 👋', style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp)),
      ])),
      GestureDetector(
        onTap: () => context.push(Routes.notifications),
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 20),
        ),
      ),
    ]),
  );
}

class _KpiRow extends StatelessWidget {
  static final _kpis = [
    {'icon': '💰', 'label': 'Выручка', 'value': '2.4M', 'delta': '+18%', 'color': AppColors.green},
    {'icon': '📦', 'label': 'Заказов',  'value': '47',   'delta': '+5',   'color': AppColors.blue},
    {'icon': '🛍️', 'label': 'Товаров', 'value': '18',   'delta': '+2',   'color': AppColors.purple},
    {'icon': '⭐', 'label': 'Рейтинг',  'value': '4.8',  'delta': '',     'color': AppColors.gold},
  ];
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 12.w),
    child: Row(children: _kpis.map((k) => Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: (k['color'] as Color).withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: (k['color'] as Color).withOpacity(0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k['icon'] as String, style: TextStyle(fontSize: 18.sp)),
          SizedBox(height: 4.h),
          Text(k['value'] as String, style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w700)),
          Text(k['label'] as String, style: TextStyle(color: AppColors.textMuted, fontSize: 9.sp)),
          if ((k['delta'] as String).isNotEmpty)
            Text(k['delta'] as String, style: TextStyle(color: k['color'] as Color, fontSize: 9.sp, fontWeight: FontWeight.w600)),
        ]),
      ),
    )).toList()),
  );
}

class _RevenueChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(16.w),
    child: Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Выручка (7 дней)', style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 16.h),
        SizedBox(
          height: 130.h,
          child: LineChart(LineChartData(
            gridData: FlGridData(drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1)),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1,
                getTitlesWidget: (v, _) => Text(['Пн','Вт','Ср','Чт','Пт','Сб','Вс'][v.toInt()],
                  style: TextStyle(color: AppColors.textMuted, fontSize: 9.sp)))),
            ),
            lineBarsData: [LineChartBarData(
              spots: [180, 240, 190, 350, 280, 420, 390]
                .asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList(),
              isCurved: true, color: AppColors.accent, barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: AppColors.accent.withOpacity(0.08)),
            )],
          )),
        ),
      ]),
    ),
  );
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Row(children: [
      _ActionBtn('📦', 'Товары',     Routes.addProduct),
      SizedBox(width: 10.w),
      _ActionBtn('🎬', 'Рилс',       Routes.createReel),
      SizedBox(width: 10.w),
      _ActionBtn('📋', 'Заказы',     Routes.sellerOrders),
      SizedBox(width: 10.w),
      _ActionBtn('📈', 'Аналитика',  Routes.analytics),
    ]),
  );
}

class _ActionBtn extends StatelessWidget {
  final String icon, label, route;
  const _ActionBtn(this.icon, this.label, this.route);
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(
    onTap: () => context.push(route),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Text(icon, style: TextStyle(fontSize: 22.sp)),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 9.sp)),
      ]),
    ),
  ));
}

class _RecentOrders extends StatelessWidget {
  static const _orders = [
    {'id': 'A4F22', 'product': 'Платье летнее', 'buyer': 'Камола У.',  'status': 'new',    'amount': 185000},
    {'id': 'B9C11', 'product': 'Джинсы Slim',   'buyer': 'Малика Р.',  'status': 'packed', 'amount': 320000},
    {'id': 'C7D03', 'product': 'Топ базовый',   'buyer': 'Дилноза А.', 'status': 'done',   'amount': 95000},
  ];
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Последние заказы', style: TextStyle(color: AppColors.textPrimary, fontSize: 15.sp, fontWeight: FontWeight.w600)),
        const Spacer(),
        TextButton(onPressed: () => context.push(Routes.sellerOrders), child: Text('Все', style: TextStyle(color: AppColors.accent, fontSize: 13.sp))),
      ]),
      ..._orders.map((o) => Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('#${o['id']}', style: TextStyle(color: AppColors.textMuted, fontSize: 10.sp)),
            Text(o['product'] as String, style: TextStyle(color: AppColors.textPrimary, fontSize: 13.sp, fontWeight: FontWeight.w500)),
            Text(o['buyer'] as String, style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
          ]),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _statusBadge(o['status'] as String),
            SizedBox(height: 4.h),
            Text(FormatUtils.priceTiyin(o['amount'] as int), style: TextStyle(color: AppColors.textPrimary, fontSize: 13.sp, fontWeight: FontWeight.w600)),
          ]),
        ]),
      )),
    ]),
  );

  static Widget _statusBadge(String status) {
    final map = {
      'new':    ('Новый',     AppColors.blue),
      'packed': ('Упакован',  AppColors.orange),
      'done':   ('Доставлен', AppColors.green),
    };
    final (label, color) = map[status] ?? ('—', AppColors.textMuted);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Weekly Limits Card ───────────────────────────────────────────────────────
class _WeeklyLimitsCard extends StatefulWidget {
  @override
  State<_WeeklyLimitsCard> createState() => _WeeklyLimitsCardState();
}

class _WeeklyLimitsCardState extends State<_WeeklyLimitsCard> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = getIt<ApiClient>();
      final data = await api.getSellerLimits();
      if (mounted) setState(() { _data = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.accent.withOpacity(0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('🛍️', style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 8.w),
            Text('Лимиты на неделю',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.sp, fontWeight: FontWeight.w700,
              )),
            const Spacer(),
            GestureDetector(
              onTap: () { setState(() { _loading = true; _error = null; }); _load(); },
              child: Icon(Icons.refresh_rounded, size: 16.sp, color: AppColors.textMuted),
            ),
          ]),
          SizedBox(height: 14.h),

          if (_loading)
            Center(child: SizedBox(
              height: 36.h,
              child: const CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
            ))
          else if (_error != null)
            Center(child: Text('Ошибка загрузки', style: TextStyle(color: AppColors.red, fontSize: 12.sp)))
          else if (_data != null) ...[
            _LimitBar(
              emoji: '📦',
              label: 'Товары',
              used:  (_data!['products']['used'] as num).toInt(),
              limit: (_data!['products']['limit'] as num).toInt(),
              color: AppColors.green,
            ),
            SizedBox(height: 10.h),
            _LimitBar(
              emoji: '🎬',
              label: 'Рилсы',
              used:  (_data!['reels']['used'] as num).toInt(),
              limit: (_data!['reels']['limit'] as num).toInt(),
              color: AppColors.blue,
            ),
            SizedBox(height: 10.h),
            _LimitBar(
              emoji: '📸',
              label: 'Истории',
              used:  (_data!['stories']['used'] as num).toInt(),
              limit: (_data!['stories']['limit'] as num).toInt(),
              color: AppColors.purple,
            ),

            // Expiring soon
            if ((_data!['expiringSoon'] as List).isNotEmpty) ...[
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.orange.withOpacity(0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.schedule_rounded, size: 13.sp, color: AppColors.orange),
                      SizedBox(width: 6.w),
                      Text('Скоро удалятся',
                        style: TextStyle(
                          fontSize: 11.sp, fontWeight: FontWeight.w700,
                          color: AppColors.orange,
                        )),
                    ]),
                    SizedBox(height: 6.h),
                    ...(_data!['expiringSoon'] as List).map((e) {
                      final type = e['type'] == 'product' ? 'Товар' : 'Рилс';
                      final days = (e['daysLeft'] as num).toInt();
                      return Padding(
                        padding: EdgeInsets.only(bottom: 3.h),
                        child: Row(children: [
                          Text('• $type — ', style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
                          Text(
                            days == 0 ? 'сегодня' : 'через $days дн.',
                            style: TextStyle(
                              fontSize: 11.sp, fontWeight: FontWeight.w600,
                              color: days == 0 ? AppColors.red : AppColors.orange,
                            ),
                          ),
                        ]),
                      );
                    }),
                  ],
                ),
              ),
            ],

            SizedBox(height: 12.h),
            // Reset hint
            Center(child: Text(
              'Лимиты обнуляются каждый понедельник',
              style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted),
            )),
          ],
        ]),
      ),
    );
  }
}

class _LimitBar extends StatelessWidget {
  final String emoji, label;
  final int used, limit;
  final Color color;
  const _LimitBar({
    required this.emoji, required this.label,
    required this.used, required this.limit, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = (used / limit).clamp(0.0, 1.0);
    final isWarning = fraction >= 0.8;
    final barColor = isWarning ? AppColors.orange : color;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(emoji, style: TextStyle(fontSize: 13.sp)),
        SizedBox(width: 6.w),
        Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
        const Spacer(),
        Text(
          '$used / $limit',
          style: TextStyle(
            fontSize: 12.sp, fontWeight: FontWeight.w700,
            color: isWarning ? AppColors.orange : AppColors.textPrimary,
          ),
        ),
        if (isWarning) ...[
          SizedBox(width: 4.w),
          Icon(Icons.warning_amber_rounded, size: 12.sp, color: AppColors.orange),
        ],
      ]),
      SizedBox(height: 6.h),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: fraction,
          minHeight: 5.h,
          backgroundColor: barColor.withOpacity(0.12),
          valueColor: AlwaysStoppedAnimation<Color>(barColor),
        ),
      ),
    ]);
  }
}
