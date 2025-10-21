#!/bin/bash
set -e

# Password environment
export PGPASSWORD="${POSTGRES_PASSWORD}"

# Timestamp folder
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/dumps/$TIMESTAMP"
mkdir -p "$BACKUP_DIR"

echo "📦 Dumping globals (roles, permissions)..."
pg_dumpall -h postgres -U "${DB_USER}" --globals-only > "$BACKUP_DIR/globals.sql"

echo "📦 Dumping databases..."
IFS=',' read -ra DBS <<< "${DB_BACKUP_NAME}"
for db in "${DBS[@]}"; do
    echo "Dumping database: $db"
    pg_dump -h postgres -U "${DB_USER}" -Fc -f "$BACKUP_DIR/$db.dump" "$db"
done

echo "✅ Backup completed: $BACKUP_DIR"
ls -lh "$BACKUP_DIR"
