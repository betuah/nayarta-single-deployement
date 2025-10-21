#!/bin/bash
set -e

DB_USER="${DB_USER:-admin}"

echo "=== Starting database restoration ==="

# Restore global objects (roles, tablespaces, etc.)
if [ -f /dumps/globals.sql ]; then
    echo "Restoring globals..."
    psql -U "$DB_USER" -f /dumps/globals.sql || echo "Warning: Some globals may already exist"
fi

# Create databases if they don't exist
psql -U "$DB_USER" <<-EOSQL
    SELECT 'CREATE DATABASE analytics_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'analytics_db')\gexec
    SELECT 'CREATE DATABASE schedulerdb' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'schedulerdb')\gexec
    SELECT 'CREATE DATABASE vms_development' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'vms_development')\gexec
EOSQL

# Restore database dumps
if [ -f /dumps/analytics_db.dump ]; then
    echo "Restoring analytics_db..."
    pg_restore -U "$DB_USER" -d analytics_db --no-owner --no-acl --if-exists -c /dumps/analytics_db.dump 2>/dev/null || echo "Restore completed with some warnings (normal)"
fi

if [ -f /dumps/schedulerdb.dump ]; then
    echo "Restoring schedulerdb..."
    pg_restore -U "$DB_USER" -d schedulerdb --no-owner --no-acl --if-exists -c /dumps/schedulerdb.dump 2>/dev/null || echo "Restore completed with some warnings (normal)"
fi

if [ -f /dumps/vms_development.dump ]; then
    echo "Restoring vms_development..."
    pg_restore -U "$DB_USER" -d vms_development --no-owner --no-acl --if-exists -c /dumps/vms_development.dump 2>/dev/null || echo "Restore completed with some warnings (normal)"
fi

echo "=== Database restoration completed! ==="