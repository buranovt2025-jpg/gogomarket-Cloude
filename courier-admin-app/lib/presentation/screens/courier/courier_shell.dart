import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

class CourierShell extends StatelessWidget {
  final Widget child;
  const CourierShell({super.key, required this.child});

  static const _tabs = [
    Routes.courierMap, Routes.courierOrders, Routes.courierEarnings, Routes.courierProfile,
  ];

  int _idx(BuildContext ctx) {
    final loc = GoRouterState.of(ctx).matchedLocation;
    final i = _tabs.indexWhere((t) => loc.startsWith(t.split('/:').first));
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
          selectedItemColor: AppColors.green,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined),     activeIcon: Icon(Icons.map),          label: 'Карта'),
            BottomNavigationBarItem(icon: Icon(Icons.inbox_outlined),   activeIcon: Icon(Icons.inbox),        label: 'Заказы'),
            BottomNavigationBarItem(icon: Icon(Icons.payments_outlined), activeIcon: Icon(Icons.payments),   label: 'Заработок'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline),   activeIcon: Icon(Icons.person),       label: 'Профиль'),
          ],
        ),
      ),
    );
  }
}
