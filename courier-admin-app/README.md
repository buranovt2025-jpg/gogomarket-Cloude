# GogoMarket — courier-admin-app

> Flutter app for GogoMarket Couriers and Administrators.

## Stack

| Layer        | Technology            |
|--------------|-----------------------|
| Framework    | Flutter 3.x           |
| State        | flutter_bloc + HydratedBloc |
| Navigation   | go_router 13          |
| Network      | dio + retrofit        |
| Maps & GPS   | flutter_map + geolocator |
| Charts       | fl_chart              |
| Real-time    | socket_io_client      |
| DI           | get_it + injectable   |
| Push         | firebase_messaging    |

## Architecture

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/      — Colors (green/purple accent), AppConstants
│   ├── theme/          — AppTheme (dark, courier green, admin purple)
│   ├── router/         — go_router with role-based routing
│   ├── di/             — get_it + injectable
│   ├── network/        — dio + retrofit ApiClient
│   └── utils/          — FormatUtils, SocketService, FirebaseOptions
├── data/models/
│   ├── user_model.dart
│   ├── courier_order_model.dart
│   └── admin/          — SellerPendingModel, FlaggedContentModel, AdminOrderModel
└── presentation/
    ├── blocs/
    │   ├── auth/        — AuthBloc (shared)
    │   ├── courier/     — CourierBloc (GPS, orders, steps)
    │   └── admin/       — AdminBloc (dashboard, moderation, finance)
    ├── screens/
    │   ├── auth/        — PhoneScreen, OtpScreen
    │   ├── courier/     — MapScreen, OrdersScreen, ActiveDelivery, Earnings, Profile
    │   └── admin/       — Dashboard, Moderation, Orders, Users, Finance
    └── widgets/         — StatCard
```

## Screens

### Courier App
| Screen | Description |
|--------|-------------|
| 🗺️ Map | Live map with GPS, online/offline toggle, new order banner |
| 📦 Orders | Available orders list with accept button |
| 🚀 Active Delivery | Step-by-step: pickup → transit → delivered + live map |
| 💰 Earnings | Today/week/month stats, bar chart, transaction history |
| 👤 Profile | Courier profile, vehicle info, logout |

### Admin App
| Screen | Description |
|--------|-------------|
| 📊 Dashboard | KPI cards, revenue chart, quick actions |
| 🛡️ Moderation | Seller verification (approve/reject) + flagged content |
| 📋 Orders | Filtered orders list, dispute management |
| 👥 Users | User stats, recent registrations |
| 💳 Finance | GMV, commissions, withdrawal approvals |

## Auth flow (role-based routing)

```
Phone → OTP → getMe()
  ├── role: 'courier' → /courier/map
  └── role: 'admin'   → /admin/dashboard
```

## Quick Start

```bash
git clone https://github.com/buranovt2025-jpg/gogomarket-courier-admin-app
cd courier-admin-app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutterfire configure
flutter run
```

## GitHub

`buranovt2025-jpg/gogomarket-courier-admin-app`
