#!/bin/bash
# Run DB migrations
set -e
echo "Running Drizzle migrations..."
npx drizzle-kit migrate
echo "Migrations complete."
