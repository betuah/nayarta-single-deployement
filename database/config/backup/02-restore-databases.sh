#!/bin/bash
set -e

echo "🔧 Starting database restoration..."

# Function to check if database exists
db_exists() {
    psql -U "$POSTGRES_USER" -lqt | cut -d \| -f 1 | grep -qw "$1"
}

# Function to check if database has tables
db_has_tables() {
    local db_name=$1
    local table_count=$(psql -U "$POSTGRES_USER" -d "$db_name" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';")
    [ "$table_count" -gt 0 ]
}

# Function to restore database from dump
restore_database() {
    local db_name=$1
    local dump_file="/docker-entrypoint-initdb.d/${db_name}.dump"
    
    echo "📦 Processing database: $db_name"
    
    # Check if dump file exists
    if [ ! -f "$dump_file" ]; then
        echo "⚠️  Dump file not found: $dump_file - Skipping"
        return 0
    fi
    
    # Check if database exists
    if db_exists "$db_name"; then
        echo "✓ Database '$db_name' already exists"
        
        # Check if database has tables
        if db_has_tables "$db_name"; then
            echo "ℹ️  Database '$db_name' already has data, skipping restore"
            return 0
        else
            echo "📥 Database exists but empty, restoring data..."
        fi
    else
        # Create database if it doesn't exist
        echo "🆕 Creating database: $db_name"
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
            CREATE DATABASE $db_name;
            GRANT ALL PRIVILEGES ON DATABASE $db_name TO $POSTGRES_USER;
EOSQL
    fi
    
    # Restore database
    echo "📥 Restoring $db_name from dump file..."
    if pg_restore -U "$POSTGRES_USER" -d "$db_name" --no-owner --no-acl -v "$dump_file" 2>&1 | grep -v "already exists" || true; then
        echo "✅ Database '$db_name' restored successfully"
    else
        echo "⚠️  Warning: Some errors occurred during restore of '$db_name'"
    fi
}

# List of databases to restore
DATABASES=("vms_development" "analytics_db" "schedulerdb")

# Restore each database
for db in "${DATABASES[@]}"; do
    restore_database "$db"
    echo ""
done

echo "✅ All database restorations completed!"
echo ""
echo "📊 Database Summary:"
psql -U "$POSTGRES_USER" -c "\l" | grep -E "vms_development|analytics_db|schedulerdb" || echo "No matching databases found"

