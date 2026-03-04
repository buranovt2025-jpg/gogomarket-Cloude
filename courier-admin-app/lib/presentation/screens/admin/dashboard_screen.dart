import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../blocs/admin/admin_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminBloc>()..add(AdminLoadDashboard()),
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: SafeArea(
          child: BlocBuilder<AdminBloc, AdminState>(
            builder: (ctx, state) {
              final admin = (context.read<AuthBloc>().state as AuthAuthenticated?)?.user;
              final d = state.dashboard;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Привет, ${admin?.name ?? 'Администратор'} 👋',
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                      const Text('Панель управления GogoMarket',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ]),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.purple.withOpacity(0.3)),
                      ),
                      child: const Text('Admin', style: TextStyle(color: AppColors.purple, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // KPI cards
                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10, mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                    children: [
                      StatCard(label: 'Пользователи',   value: '${d['users'] ?? '—'}',   icon: '👤', color: AppColors.blue),
                      StatCard(label: 'Продавцы',       value: '${d['sellers'] ?? '—'}', icon: '🏪', color: AppColors.green),
                      StatCard(label: 'Заказы',         value: '${d['orders'] ?? '—'}',  icon: '📦', color: AppColors.accent),
                      StatCard(label: 'На верификации', value: '${d['pendingVerifications'] ?? '—'}', icon: '⏳', color: AppColors.gold),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Revenue chart
                  const Text('ВЫРУЧКА ЗА НЕДЕЛЮ', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                    child: SizedBox(
                      height: 150,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            drawHorizontalLine: true,
                            getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 1),
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) => Text(
                                ['Пн','Вт','Ср','Чт','Пт','Сб','Вс'][v.toInt()],
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                              ),
                            )),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [3.2, 4.1, 3.8, 5.6, 4.9, 7.2, 6.8].asMap().entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                              isCurved: true,
                              color: AppColors.purple,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.purple.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick actions
                  const Text('БЫСТРЫЕ ДЕЙСТВИЯ', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _ActionBtn('⏳ Верификации', '${d['pendingVerifications'] ?? 0}', AppColors.gold, () {})),
                    const SizedBox(width: 10),
                    Expanded(child: _ActionBtn('🚨 Споры', '${d['disputes'] ?? 0}', AppColors.red, () {})),
                  ]),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label, count; final Color color; final VoidCallback onTap;
  const _ActionBtn(this.label, this.count, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(children: [
        Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        const Spacer(),
        Container(width: 22, height: 22,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)))),
      ]),
    ),
  );
}
