import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/phone_screen.dart';
import '../../presentation/screens/auth/otp_screen.dart';
import '../../presentation/screens/auth/role_select_screen.dart';
import '../../presentation/screens/auth/seller_verify_screen.dart';
import '../../presentation/screens/home/main_shell.dart';
import '../../presentation/screens/home/feed_screen.dart';
import '../../presentation/screens/home/reels_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/product/product_detail_screen.dart';
import '../../presentation/screens/cart/cart_screen.dart';
import '../../presentation/screens/orders/orders_screen.dart';
import '../../presentation/screens/orders/order_detail_screen.dart';
import '../../presentation/screens/orders/tracking_screen.dart';
import '../../presentation/screens/chat/chats_list_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import '../../presentation/screens/storefront/storefront_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/settings_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/seller/seller_dashboard_screen.dart';
import '../../presentation/screens/seller/add_product_screen.dart';
import '../../presentation/screens/seller/create_reel_screen.dart';
import '../../presentation/screens/seller/seller_orders_screen.dart';
import '../../presentation/screens/seller/seller_analytics_screen.dart';
import '../../presentation/screens/pro/pro_screen.dart';

class Routes {
  Routes._();

  static const String splash        = '/';
  static const String onboarding    = '/onboarding';
  static const String phone         = '/auth/phone';
  static const String otp           = '/auth/otp';
  static const String roleSelect    = '/auth/role';
  static const String sellerVerify  = '/auth/seller-verify';

  static const String feed          = '/home/feed';
  static const String reels         = '/home/reels';

  static const String search        = '/search';

  static String productDetail(String id) => '/product/$id';
  static const String _productDetail     = '/product/:id';

  static const String cart          = '/cart';

  static const String orders        = '/orders';
  static String orderDetail(String id)  => '/orders/$id';
  static const String _orderDetail      = '/orders/:id';
  static String tracking(String id)     => '/orders/$id/tracking';
  static const String _tracking         = '/orders/:id/tracking';

  static const String chats         = '/chats';
  static String chat(String id)         => '/chats/$id';
  static const String _chat             = '/chats/:id';

  static String storefront(String id)   => '/seller/$id';
  static const String _storefront       = '/seller/:id';

  static const String profile       = '/profile';
  static const String settings      = '/settings';
  static const String notifications = '/notifications';

  static const String dashboard     = '/seller/dashboard';
  static const String addProduct    = '/seller/product/add';
  static const String createReel    = '/seller/reel/create';
  static const String sellerOrders  = '/seller/orders';
  static const String analytics     = '/seller/analytics';

  static const String pro           = '/pro';
}

class AppRouter {
  static final _rootKey   = GlobalKey<NavigatorState>();
  static final _shellKey  = GlobalKey<NavigatorState>();

  static GoRouter get router => GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    redirect: _guard,
    routes: [
      GoRoute(path: Routes.splash,       builder: (_, __) => const SplashScreen()),
      GoRoute(path: Routes.onboarding,   builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: Routes.phone,        builder: (_, __) => const PhoneScreen()),
      GoRoute(path: Routes.otp,          builder: (_, s)  => OtpScreen(phone: s.uri.queryParameters['phone'] ?? '')),
      GoRoute(path: Routes.roleSelect,   builder: (_, __) => const RoleSelectScreen()),
      GoRoute(path: Routes.sellerVerify, builder: (_, __) => const SellerVerifyScreen()),

      // Bottom-nav shell
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: Routes.feed,   builder: (_, __) => const FeedScreen()),
          GoRoute(path: Routes.reels,  builder: (_, __) => const ReelsScreen()),
          GoRoute(path: Routes.chats,  builder: (_, __) => const ChatsListScreen()),
          GoRoute(path: Routes.profile, builder: (_, __) => const ProfileScreen()),
        ],
      ),

      GoRoute(path: Routes.search,          builder: (_, __) => const SearchScreen()),
      GoRoute(path: Routes._productDetail,  builder: (_, s)  => ProductDetailScreen(productId: s.pathParameters['id']!)),
      GoRoute(path: Routes.cart,            builder: (_, __) => const CartScreen()),
      GoRoute(path: Routes.orders,          builder: (_, __) => const OrdersScreen()),
      GoRoute(path: Routes._orderDetail,    builder: (_, s)  => OrderDetailScreen(orderId: s.pathParameters['id']!)),
      GoRoute(path: Routes._tracking,       builder: (_, s)  => TrackingScreen(orderId: s.pathParameters['id']!)),
      GoRoute(path: Routes._chat,           builder: (_, s)  => ChatScreen(chatId: s.pathParameters['id']!)),
      GoRoute(path: Routes._storefront,     builder: (_, s)  => StorefrontScreen(sellerId: s.pathParameters['id']!)),
      GoRoute(path: Routes.settings,        builder: (_, __) => const SettingsScreen()),
      GoRoute(path: Routes.notifications,   builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: Routes.dashboard,       builder: (_, __) => const SellerDashboardScreen()),
      GoRoute(path: Routes.addProduct,      builder: (_, __) => const AddProductScreen()),
      GoRoute(path: Routes.createReel,      builder: (_, __) => const CreateReelScreen()),
      GoRoute(path: Routes.sellerOrders,    builder: (_, __) => const SellerOrdersScreen()),
      GoRoute(path: Routes.analytics,       builder: (_, __) => const SellerAnalyticsScreen()),
      GoRoute(path: Routes.pro,             builder: (_, __) => const ProScreen()),
    ],
  );

  static String? _guard(BuildContext ctx, GoRouterState state) {
    final auth   = ctx.read<AuthBloc>().state;
    final isAuth = auth is AuthAuthenticated;
    final loc    = state.matchedLocation;

    // Public routes
    if (loc == Routes.splash || loc == Routes.onboarding ||
        loc.startsWith('/auth')) return null;

    // Not authenticated
    if (!isAuth) return Routes.phone;

    // Seller-only routes
    final sellerOnly = [Routes.dashboard, Routes.addProduct, Routes.createReel, Routes.sellerOrders, Routes.analytics];
    if (sellerOnly.contains(loc) && (auth as AuthAuthenticated).user.role != 'seller') {
      return Routes.pro;
    }

    return null;
  }
}
