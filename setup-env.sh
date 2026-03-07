#!/bin/bash
# Запусти этот скрипт на сервере: bash setup-env.sh
# Добавляет нужные переменные в .env бэкенда

ENV_FILE="/opt/gogomarket-Cloude/backend/.env"

add_env() {
  local key=$1
  local value=$2
  if grep -q "^${key}=" "$ENV_FILE" 2>/dev/null; then
    echo "  ⏭️  ${key} уже есть"
  else
    echo "${key}=${value}" >> "$ENV_FILE"
    echo "  ✅ ${key} добавлен"
  fi
}

echo "=== Добавляю переменные в $ENV_FILE ==="

# Eskiz SMS — ЗАМЕНИ на реальные данные!
add_env "ESKIZ_EMAIL"    "your@email.com"
add_env "ESKIZ_PASSWORD" "your_eskiz_password"
add_env "ESKIZ_FROM"     "4546"

# Click UZ — получить на merchant.click.uz
add_env "CLICK_SERVICE_ID"  "YOUR_SERVICE_ID"
add_env "CLICK_MERCHANT_ID" "YOUR_MERCHANT_ID"
add_env "CLICK_SECRET_KEY"  "YOUR_SECRET_KEY"

# Payme — получить на merchant.paycom.uz
add_env "PAYME_MERCHANT_ID"  "YOUR_MERCHANT_ID"
add_env "PAYME_SECRET_KEY"   "YOUR_SECRET_KEY"
add_env "PAYME_TEST_SECRET"  "YOUR_TEST_SECRET"

echo ""
echo "=== Перезапускаю бэкенд ==="
cd /opt/gogomarket-Cloude/backend
pm2 restart gogomarket-backend || pm2 start dist/index.js --name gogomarket-backend

echo "✅ Готово! Проверь: pm2 logs gogomarket-backend"
