#!/bin/bash
set -e

echo "🔧 Restoring global roles and users..."

# Check if globals.sql exists
if [ -f /docker-entrypoint-initdb.d/globals.sql ]; then
    echo "📥 Restoring globals from globals.sql..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" -f /docker-entrypoint-initdb.d/globals.sql || echo "⚠️  Warning: Some roles may already exist"
    echo "✅ Global roles restored"
else
    echo "⚠️  No globals.sql found, skipping..."
fi

echo "✅ Global restore completed"

