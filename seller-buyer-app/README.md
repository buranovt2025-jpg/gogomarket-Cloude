# GogoMarket — seller-buyer-app

> Flutter mobile app for GogoMarket social e-commerce platform.
> Covers: Buyers and Sellers. Separate repo: `courier-admin-app`.

## Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Dart) |
| State | flutter_bloc + HydratedBloc |
| Navigation | go_router 13 |
| Network | dio + retrofit |
| Local storage | hive_flutter |
| DI | get_it + injectable |
| Video | video_player + chewie |
| Maps | flutter_map |
| Auth | local_auth + pin_code_fields |
| Push | firebase_messaging |
| UI | cached_network_image, shimmer, flutter_svg, lottie |
| Screen size | flutter_screenutil (390×844 base) |

## Architecture

```
lib/
├── main.dart              — Entry point, Firebase init, DI setup
├── app.dart               — MaterialApp.router, BlocProviders
├── core/
│   ├── constants/         — Colors, TextStyles, AppConstants
│   ├── theme/             — Dark/Light AppTheme
│   ├── router/            — go_router with guards
│   ├── di/                — get_it + injectable config
│   ├── network/           — dio + retrofit ApiClient, AuthInterceptor
│   └── utils/             — FormatUtils, SocketService, FirebaseOptions
├── data/
│   ├── models/            — JSON-serializable models (UserModel, ProductModel, ...)
│   └── repositories/      — Abstract repos + implementations
├── domain/
│   ├── entities/          — Pure domain entities
│   ├── repositories/      — Abstract interfaces
│   └── usecases/          — Business logic use cases
└── presentation/
    ├── blocs/             — AuthBloc, CartBloc, FeedBloc, ThemeCubit, ...
    ├── screens/           — 26 screens (all routes covered)
    └── widgets/           — GogoButton, ProductCard, GogoBadge, ...
```

## Quick Start

```bash
# 1. Clone
git clone https://github.com/buranovt2025-jpg/gogomarket-seller-buyer-app
cd seller-buyer-app

# 2. Install deps
flutter pub get

# 3. Generate code (retrofit, json, injectable)
dart run build_runner build --delete-conflicting-outputs

# 4. Configure Firebase
flutterfire configure

# 5. Run
flutter run
```

## Code Generation

Run after changing models, API, or DI:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Files generated:
- `*.g.dart` — JSON serialization (json_serializable)
- `api_client.g.dart` — Retrofit HTTP client
- `injection.config.dart` — Injectable DI

## Environment

Backend URL is configured in `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'https://api.gogomarket.uz/v1';
```

For local dev, change to `http://10.0.2.2:3000/v1` (Android emulator).

## Design System

- **Colors**: `AppColors` — accent `#FF3B5C`, dark bg `#0D0D15`
- **Fonts**: Playfair Display (headings) + DM Sans (body)
- **Screen base**: 390×844 (iPhone 14), scaled with `flutter_screenutil`
- **Design files**: `/outputs/gogomarket*.jsx` — React prototypes

## Key Screens (26 total)

| Screen | Route |
|--------|-------|
| Splash + Onboarding | `/`, `/onboarding` |
| Auth: Phone → OTP → Role → Verify | `/auth/*` |
| Feed (subscriptions/discover) | `/home/feed` |
| Reels (TikTok-style) | `/home/reels` |
| Search + Results | `/search` |
| Product Detail | `/product/:id` |
| Cart + Checkout | `/cart` |
| Orders + Tracking | `/orders`, `/orders/:id/tracking` |
| Chat (list + dialog) | `/chats`, `/chats/:id` |
| Storefront | `/seller/:id` |
| Seller Dashboard | `/seller/dashboard` |
| Add Product | `/seller/product/add` |
| Create Reel | `/seller/reel/create` |
| Analytics | `/seller/analytics` |
| Pro Subscription | `/pro` |
| Notifications | `/notifications` |
| Settings | `/settings` |

## GitHub

`buranovt2025-jpg/gogomarket-seller-buyer-app`
