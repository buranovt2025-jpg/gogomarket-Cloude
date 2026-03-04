import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  static const _tabs = [
    Routes.adminDashboard, Routes.moderation, Routes.adminOrders,
    Routes.users, Routes.finance,
  ];

  int _idx(BuildContext ctx) {
    final loc = GoRouterState.of(ctx).matchedLocation;
    final i = _tabs.indexWhere((t) => loc == t);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
        child: BottomNavigationBar(
          currentIndex: _idx(context),
          onTap: (i) => context.go(_tabs[i]),
          backgroundColor: AppColors.bgCard,
          selectedItemColor: AppColors.purple,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Дашборд'),
            BottomNavigationBarItem(icon: Icon(Icons.shield_outlined),    activeIcon: Icon(Icons.shield),    label: 'Модерация'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_outlined),   activeIcon: Icon(Icons.receipt),   label: 'Заказы'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline),     activeIcon: Icon(Icons.people),    label: 'Пользователи'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_outlined), activeIcon: Icon(Icons.account_balance), label: 'Финансы'),
          ],
        ),
      ),
    );
  }
}
