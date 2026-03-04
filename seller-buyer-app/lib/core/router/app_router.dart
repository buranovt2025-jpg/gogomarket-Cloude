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

// Route names
class Routes {
  static const String splash        = '/';
  static const String onboarding    = '/onboarding';
  static const String phone         = '/auth/phone';
  static const String otp           = '/auth/otp';
  static const String roleSelect    = '/auth/role';
  static const String sellerVerify  = '/auth/seller-verify';
  static const String home          = '/home';
  static const String feed          = '/home/feed';
  static const String reels         = '/home/reels';
  static const String search        = '/search';
  static const String product       = '/product/:id';
  static const String cart          = '/cart';
  static const String orders        = '/orders';
  static const String orderDetail   = '/orders/:id';
  static const String tracking      = '/orders/:id/tracking';
  static const String chats         = '/chats';
  static const String chat          = '/chats/:id';
  static const String storefront    = '/seller/:id';
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
  static final _rootKey = GlobalKey<NavigatorState>();
  static final _shellKey = GlobalKey<NavigatorState>();

  static GoRouter get router => GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    redirect: _guard,
    routes: [
      // Splash
      GoRoute(
        path: Routes.splash,
        builder: (ctx, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: Routes.onboarding,
        builder: (ctx, state) => const OnboardingScreen(),
      ),

      // Auth flow
      GoRoute(path: Routes.phone,  builder: (ctx, _) => const PhoneScreen()),
      GoRoute(
        path: Routes.otp,
        builder: (ctx, state) => OtpScreen(phone: state.uri.queryParameters['phone'] ?? ''),
      ),
      GoRoute(path: Routes.roleSelect,   builder: (ctx, _) => const RoleSelectScreen()),
      GoRoute(path: Routes.sellerVerify, builder: (ctx, _) => const SellerVerifyScreen()),

      // Main shell with bottom nav
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (ctx, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: Routes.feed,  builder: (ctx, _) => const FeedScreen()),
          GoRoute(path: Routes.reels, builder: (ctx, _) => const ReelsScreen()),
          GoRoute(path: Routes.chats, builder: (ctx, _) => const ChatsListScreen()),
          GoRoute(path: Routes.profile, builder: (ctx, _) => const ProfileScreen()),
        ],
      ),

      // Search
      GoRoute(path: Routes.search, builder: (ctx, state) {
        final q = state.uri.queryParameters['q'];
        return SearchScreen(initialQuery: q);
      }),

      // Product
      GoRoute(
        path: Routes.product,
        builder: (ctx, state) => ProductDetailScreen(id: state.pathParameters['id']!),
      ),

      // Cart
      GoRoute(path: Routes.cart, builder: (ctx, _) => const CartScreen()),

      // Orders
      GoRoute(path: Routes.orders, builder: (ctx, _) => const OrdersScreen()),
      GoRoute(
        path: Routes.orderDetail,
        builder: (ctx, state) => OrderDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.tracking,
        builder: (ctx, state) => TrackingScreen(orderId: state.pathParameters['id']!),
      ),

      // Chat
      GoRoute(
        path: Routes.chat,
        builder: (ctx, state) => ChatScreen(chatId: state.pathParameters['id']!),
      ),

      // Storefront
      GoRoute(
        path: Routes.storefront,
        builder: (ctx, state) => StorefrontScreen(sellerId: state.pathParameters['id']!),
      ),

      // Profile & Settings
      GoRoute(path: Routes.settings,      builder: (ctx, _) => const SettingsScreen()),
      GoRoute(path: Routes.notifications, builder: (ctx, _) => const NotificationsScreen()),

      // Seller
      GoRoute(path: Routes.dashboard,   builder: (ctx, _) => const SellerDashboardScreen()),
      GoRoute(path: Routes.addProduct,  builder: (ctx, _) => const AddProductScreen()),
      GoRoute(path: Routes.createReel,  builder: (ctx, _) => const CreateReelScreen()),
      GoRoute(path: Routes.sellerOrders, builder: (ctx, _) => const SellerOrdersScreen()),
      GoRoute(path: Routes.analytics,   builder: (ctx, _) => const SellerAnalyticsScreen()),

      // Pro subscription
      GoRoute(path: Routes.pro, builder: (ctx, _) => const ProScreen()),
    ],
  );

  static String? _guard(BuildContext ctx, GoRouterState state) {
    final authState = ctx.read<AuthBloc>().state;
    final isAuth   = authState is AuthAuthenticated;
    final isSplash = state.matchedLocation == Routes.splash;
    final isOnboarding = state.matchedLocation == Routes.onboarding;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');

    if (isSplash || isOnboarding) return null;
    if (!isAuth && !isAuthRoute) return Routes.phone;

    return null;
  }
}
