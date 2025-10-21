#!/bin/bash
set -e

DB_USER="${DB_USER:-admin}"

echo "=== Enabling pgvector extension ==="

# Enable pgvector on all existing databases
for db in analytics_db "${DB_NAME:-vms_development}"; do
    if psql -U "$DB_USER" -lqt | cut -d \| -f 1 | grep -qw "$db"; then
        echo "Enabling pgvector on $db..."
        psql -U "$DB_USER" -d "$db" -c "CREATE EXTENSION IF NOT EXISTS vector;" || echo "Extension may already exist"
    fi
done

echo "=== pgvector extension enabled! ==="