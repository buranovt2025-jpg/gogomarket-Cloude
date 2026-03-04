import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/blocs/auth/auth_bloc.dart';

// Courier screens
import '../../presentation/screens/auth/phone_screen.dart';
import '../../presentation/screens/auth/otp_screen.dart';
import '../../presentation/screens/courier/courier_shell.dart';
import '../../presentation/screens/courier/map_screen.dart';
import '../../presentation/screens/courier/orders_screen.dart';
import '../../presentation/screens/courier/active_delivery_screen.dart';
import '../../presentation/screens/courier/earnings_screen.dart';
import '../../presentation/screens/courier/courier_profile_screen.dart';

// Admin screens
import '../../presentation/screens/admin/admin_shell.dart';
import '../../presentation/screens/admin/dashboard_screen.dart';
import '../../presentation/screens/admin/moderation_screen.dart';
import '../../presentation/screens/admin/admin_orders_screen.dart';
import '../../presentation/screens/admin/users_screen.dart';
import '../../presentation/screens/admin/finance_screen.dart';

class Routes {
  // Auth
  static const String phone  = '/auth/phone';
  static const String otp    = '/auth/otp';

  // Courier
  static const String courierMap      = '/courier/map';
  static const String courierOrders   = '/courier/orders';
  static const String activeDelivery  = '/courier/active/:orderId';
  static const String courierEarnings = '/courier/earnings';
  static const String courierProfile  = '/courier/profile';

  // Admin
  static const String adminDashboard  = '/admin/dashboard';
  static const String moderation      = '/admin/moderation';
  static const String adminOrders     = '/admin/orders';
  static const String users           = '/admin/users';
  static const String finance         = '/admin/finance';
}

class AppRouter {
  static final _rootKey    = GlobalKey<NavigatorState>();
  static final _courierKey = GlobalKey<NavigatorState>();
  static final _adminKey   = GlobalKey<NavigatorState>();

  static GoRouter get router => GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.phone,
    redirect: _guard,
    routes: [
      // Auth
      GoRoute(path: Routes.phone, builder: (_, __) => const PhoneScreen()),
      GoRoute(
        path: Routes.otp,
        builder: (_, s) => OtpScreen(phone: s.uri.queryParameters['phone'] ?? ''),
      ),

      // Courier shell
      ShellRoute(
        navigatorKey: _courierKey,
        builder: (_, __, child) => CourierShell(child: child),
        routes: [
          GoRoute(path: Routes.courierMap,      builder: (_, __) => const MapScreen()),
          GoRoute(path: Routes.courierOrders,   builder: (_, __) => const CourierOrdersScreen()),
          GoRoute(path: Routes.courierEarnings, builder: (_, __) => const EarningsScreen()),
          GoRoute(path: Routes.courierProfile,  builder: (_, __) => const CourierProfileScreen()),
        ],
      ),
      GoRoute(
        path: Routes.activeDelivery,
        builder: (_, s) => ActiveDeliveryScreen(orderId: s.pathParameters['orderId']!),
      ),

      // Admin shell
      ShellRoute(
        navigatorKey: _adminKey,
        builder: (_, __, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: Routes.adminDashboard, builder: (_, __) => const DashboardScreen()),
          GoRoute(path: Routes.moderation,     builder: (_, __) => const ModerationScreen()),
          GoRoute(path: Routes.adminOrders,    builder: (_, __) => const AdminOrdersScreen()),
          GoRoute(path: Routes.users,          builder: (_, __) => const UsersScreen()),
          GoRoute(path: Routes.finance,        builder: (_, __) => const FinanceScreen()),
        ],
      ),
    ],
  );

  static String? _guard(BuildContext ctx, GoRouterState state) {
    final auth   = ctx.read<AuthBloc>().state;
    final isAuth = auth is AuthAuthenticated;
    final loc    = state.matchedLocation;

    if (loc.startsWith('/auth')) return null;
    if (!isAuth) return Routes.phone;

    if (auth is AuthAuthenticated) {
      final role = auth.user.role;
      if (role == 'courier' && loc.startsWith('/admin')) return Routes.courierMap;
      if ((role == 'admin' || role == 'superadmin') && loc.startsWith('/courier')) return Routes.adminDashboard;
      if (role == 'courier' && loc == Routes.phone) return Routes.courierMap;
      if ((role == 'admin' || role == 'superadmin') && loc == Routes.phone) return Routes.adminDashboard;
    }
    return null;
  }
}
