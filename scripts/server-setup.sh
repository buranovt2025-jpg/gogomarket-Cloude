#!/bin/bash
set -e
echo "=== GogoMarket Server Bootstrap ==="

# 1. Packages
apt-get update -qq
apt-get install -y -qq curl git ufw nginx

# 2. Docker
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | sh
  systemctl enable docker && systemctl start docker
  echo "Docker installed: $(docker --version)"
fi

# 3. Node.js 20
if ! command -v node &>/dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt-get install -y nodejs
fi
echo "Node: $(node -v)"

# 4. PM2
npm install -g pm2 --silent
pm2 startup systemd -u root --hp /root | grep "sudo" | bash || true

# 5. Repo
if [ ! -d /opt/gogomarket-Cloude ]; then
  git clone https://github.com/buranovt2025-jpg/gogomarket-Cloude.git /opt/gogomarket-Cloude
fi

# 6. .env
mkdir -p /opt/gogomarket
cat > /opt/gogomarket-Cloude/backend/.env << 'ENV'
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://gogomarket:GogoMarket2024!@localhost:5432/gogomarket
REDIS_URL=redis://localhost:6379
JWT_ACCESS_SECRET=gogo_access_jwt_secret_prod_2024_strong!!
JWT_REFRESH_SECRET=gogo_refresh_jwt_secret_prod_2024_strong!
JWT_ACCESS_EXPIRES=15m
JWT_REFRESH_EXPIRES=30d
SMS_PROVIDER=mock
SMS_API_KEY=mock
CORS_ORIGINS=http://206.189.12.56,https://gogomarket.uz
ENV

# 7. Docker Compose: PostgreSQL + Redis
cat > /opt/gogomarket-Cloude/backend/docker-compose.prod.yml << 'DC'
version: '3.9'
services:
  postgres:
    image: postgis/postgis:16-3.4
    container_name: gogo_postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: gogomarket
      POSTGRES_USER: gogomarket
      POSTGRES_PASSWORD: GogoMarket2024!
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "127.0.0.1:5432:5432"
    healthcheck:
      test: ["CMD-SHELL","pg_isready -U gogomarket"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: gogo_redis
    restart: unless-stopped
    command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru
    ports:
      - "127.0.0.1:6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
DC

cd /opt/gogomarket-Cloude/backend
docker compose -f docker-compose.prod.yml up -d
echo "Waiting for PostgreSQL..."
sleep 12

# 8. Build + migrate + start
npm ci --silent
npm run build 2>/dev/null || npx tsc --skipLibCheck 2>/dev/null || true
npx drizzle-kit push 2>/dev/null || true

mkdir -p /var/log/gogomarket
pm2 start /opt/gogomarket-Cloude/scripts/ecosystem.config.js
pm2 save

# 9. Nginx
cat > /etc/nginx/sites-available/gogomarket << 'NGINX'
upstream gogomarket_api {
  server 127.0.0.1:3000;
  keepalive 64;
}
server {
  listen 80;
  server_name 206.189.12.56 _;

  location /health {
    proxy_pass http://gogomarket_api;
    access_log off;
  }

  location /api/ {
    proxy_pass http://gogomarket_api/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_cache_bypass $http_upgrade;
    proxy_read_timeout 120s;
    client_max_body_size 50M;
  }

  location /socket.io/ {
    proxy_pass http://gogomarket_api/socket.io/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
  }
}
NGINX

ln -sf /etc/nginx/sites-available/gogomarket /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

# 10. Firewall
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   GogoMarket Bootstrap Complete ✅       ║"
echo "║   API:    http://206.189.12.56/api       ║"
echo "║   Health: http://206.189.12.56/health    ║"
echo "╚══════════════════════════════════════════╝"
pm2 status
