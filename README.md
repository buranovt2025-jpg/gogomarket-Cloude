# GogoMarket — Social E-Commerce for Uzbekistan

> TikTok + Instagram + Marketplace. Покупатели покупают через контент (рилсы, витрины продавцов).

## Репозиторий

```
gogomarket-Cloude/
├── seller-buyer-app/   — Flutter: покупатели + продавцы
├── courier-admin-app/  — Flutter: курьеры + администраторы  
└── backend/            — Node.js/TypeScript REST API + WebSocket
```

## Стек

| Слой | Технология |
|------|-----------|
| Mobile | Flutter 3.x, BLoC, go_router |
| Backend | Node.js 20 + TypeScript, Express |
| Database | PostgreSQL 16 + PostGIS, Drizzle ORM |
| Cache | Redis 7 |
| Real-time | Socket.io 4 |
| Queue | BullMQ |
| Delivery | Docker + GitHub Actions |
| Maps | flutter_map (OpenStreetMap) |

## Пользователи

| Роль | Описание |
|------|----------|
| 🛍️ Покупатель | Бесплатно. Лента, рилсы, чат, заказы |
| 🏪 Продавец Базовый | Бесплатно. Верификация паспорт+ИНН. До 20 товаров |
| ⭐ Продавец Pro | 50K/150K/400K сум/мес. Без лимитов + аналитика |
| 🛵 Курьер | Отдельное приложение. GPS трекинг |
| 🔧 Администратор | Модерация, финансы, аналитика |

## Быстрый старт

### Backend
```bash
cd backend
cp .env.example .env
docker compose up -d
npm run migrate
npm run seed
npm run dev
```

### Flutter Apps
```bash
cd seller-buyer-app  # или courier-admin-app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Дорожная карта

- **M0-M2** MVP: авторизация, каталог, заказы, чат, рилсы
- **M2-M3** Платежи: Click, Payme
- **M3-M5** Логистика: Express24, Yandex Delivery интеграция
- **M5-M8** Рост: аналитика, AI рекомендации, стримы
- **M8-M12** Масштаб: собственная доставка, регионы
