# GogoMarket Backend API

> Social e-commerce platform for Uzbekistan — Node.js + TypeScript + PostgreSQL

## Stack

| Layer | Technology |
|-------|-----------|
| Runtime | Node.js 20 LTS + TypeScript 5 |
| Framework | Express.js 5 |
| Database | PostgreSQL 16 + PostGIS |
| ORM | Drizzle ORM |
| Cache | Redis 7 |
| Queue | BullMQ |
| Real-time | Socket.io 4 |
| Auth | JWT (access 15m + refresh 30d) |
| Validation | Zod |
| Logging | Pino |
| CI/CD | GitHub Actions |
| Container | Docker + Compose |
| Proxy | Nginx |

## Quick Start

```bash
# 1. Clone & install
git clone https://github.com/buranovt2025-jpg/gogomarket-backend
cd gogomarket-backend
npm install

# 2. Configure environment
cp .env.example .env
# Edit .env with your values

# 3. Start infrastructure
docker compose up postgres redis -d

# 4. Run migrations
npm run db:migrate

# 5. Seed dev data
npx tsx scripts/seed.ts

# 6. Start dev server
npm run dev
```

## API Base URL

```
https://api.gogomarket.uz/v1
Local: http://localhost:3000/v1
```

## Key Endpoints

### Auth
```
POST /v1/auth/send-otp      — Send OTP to phone
POST /v1/auth/verify-otp    — Verify OTP, get tokens
POST /v1/auth/refresh       — Refresh access token
GET  /v1/auth/me            — Current user profile
```

### Products
```
GET    /v1/products          — List with filters
POST   /v1/products          — Create (seller)
GET    /v1/products/:id      — Product detail
PATCH  /v1/products/:id      — Update (owner)
DELETE /v1/products/:id      — Soft delete
```

### Orders
```
POST  /v1/orders             — Create order
GET   /v1/orders             — My orders
GET   /v1/orders/:id         — Order detail
PATCH /v1/orders/:id/status  — Update status
POST  /v1/orders/:id/dispute — Open dispute
POST  /v1/orders/:id/review  — Leave review
```

### Real-time (WebSocket)
```javascript
// Connect
const socket = io("https://api.gogomarket.uz", {
  auth: { token: "your-jwt-token" }
});

// Chat
socket.emit("chat:join",    chatId);
socket.emit("chat:message", { chatId, type: "text", content: "Привет!" });
socket.on("chat:message",   (msg) => console.log(msg));

// Courier GPS (courier app)
socket.emit("courier:location", { orderId, lat: 41.31, lng: 69.27, bearing: 90 });

// Track courier (buyer app)
socket.emit("order:subscribe", orderId);
socket.on("courier:location", ({ lat, lng, bearing }) => updateMap(lat, lng));
```

## Database

```bash
npm run db:generate  # Generate migration from schema changes
npm run db:migrate   # Apply migrations
npm run db:studio    # Open Drizzle Studio GUI
```

## Deployment

```bash
# Build image
docker build -t gogomarket-api .

# Production
docker compose up -d

# View logs
docker compose logs -f api
```

## Project Structure

```
src/
├── index.ts           — Entry point
├── db/
│   ├── index.ts       — Drizzle client
│   └── schema.ts      — All table definitions + relations
├── routes/
│   ├── auth.ts        — Authentication
│   ├── products.ts    — Product CRUD
│   ├── orders.ts      — Order lifecycle
│   ├── chats.ts       — Messaging
│   ├── sellers.ts     — Seller profiles
│   ├── delivery.ts    — Delivery services
│   ├── notifications.ts
│   └── admin.ts       — Admin panel API
├── middleware/
│   ├── auth.ts        — JWT authentication
│   ├── errorHandler.ts
│   ├── rateLimiter.ts
│   └── validate.ts
├── socket/
│   └── index.ts       — Socket.io events
├── services/
│   └── push.ts        — Firebase FCM
├── jobs/
│   └── index.ts       — BullMQ workers
├── utils/
│   ├── logger.ts      — Pino logger
│   ├── redis.ts       — Redis client
│   ├── jwt.ts         — Token helpers
│   └── sms.ts         — OTP via Eskiz
└── types/
    └── index.ts       — Shared TypeScript types
```

## Environment Variables

See `.env.example` for all required variables.

## GitHub Repository

`buranovt2025-jpg/gogomarket-backend`
