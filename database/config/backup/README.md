# Database Backup & Restore

## 📁 Backup Files

Folder ini berisi backup files untuk restore database PostgreSQL.

### Available Backups

- `vms_development.dump` - Main VMS database (4.0MB)
- `analytics_db.dump` - Analytics database (4.0MB)
- `schedulerdb.dump` - Scheduler database (4.0MB)
- `globals.sql` - PostgreSQL roles and users (2.7KB)

## 🔄 Automatic Restore (Recommended)

PostgreSQL container akan otomatis menjalankan restore scripts saat pertama kali dijalankan dengan database kosong.

### How it Works

1. **01-restore-globals.sh** - Restore roles dan users dari `globals.sql`
2. **02-restore-databases.sh** - Restore semua databases dari `.dump` files

### First Time Setup

```bash
# 1. Pastikan folder data kosong
rm -rf data/database/*

# 2. Start database service
docker-compose -f docker-compose.db.yml up -d

# 3. Monitor restore process (sekitar 30-60 detik)
docker-compose -f docker-compose.db.yml logs -f postgres

# Tunggu hingga muncul pesan:
# ✅ All database restorations completed!
# database system is ready to accept connections
```

### Expected Output

Saat restore berhasil, Anda akan melihat:
```
🔧 Restoring global roles and users...
📥 Restoring globals from globals.sql...
✅ Global roles restored
✅ Global restore completed

🔧 Starting database restoration...
📦 Processing database: vms_development
🆕 Creating database: vms_development
📥 Restoring vms_development from dump file...
✅ Database 'vms_development' restored successfully

📦 Processing database: analytics_db
🆕 Creating database: analytics_db
📥 Restoring analytics_db from dump file...
✅ Database 'analytics_db' restored successfully

📦 Processing database: schedulerdb
🆕 Creating database: schedulerdb
📥 Restoring schedulerdb from dump file...
✅ Database 'schedulerdb' restored successfully

✅ All database restorations completed!
```

## 🔧 Manual Restore

Jika automatic restore gagal atau Anda perlu restore ke database yang sudah running:

### Method 1: Using Docker Exec

```bash
# Copy dump file ke container (jika belum mounted)
docker cp backup/vms_development.dump nayarta-postgres:/tmp/

# Restore globals
docker exec -i nayarta-postgres psql -U admin -d postgres < backup/globals.sql

# Create database
docker exec nayarta-postgres psql -U admin -d postgres -c "CREATE DATABASE vms_development;"

# Restore database
docker exec nayarta-postgres pg_restore -U admin -d vms_development /docker-entrypoint-initdb.d/vms_development.dump

# Or if copied to /tmp
docker exec nayarta-postgres pg_restore -U admin -d vms_development /tmp/vms_development.dump
```

### Method 2: Using Scripts

```bash
# Enter container
docker exec -it nayarta-postgres bash

# Run restore scripts manually
cd /docker-entrypoint-initdb.d
bash 01-restore-globals.sh
bash 02-restore-databases.sh
```

### Method 3: From Host Machine

```bash
# Restore globals
psql -h localhost -p 5432 -U admin -d postgres < backup/globals.sql

# Create database
psql -h localhost -p 5432 -U admin -d postgres -c "CREATE DATABASE vms_development;"

# Restore database
pg_restore -h localhost -p 5432 -U admin -d vms_development backup/vms_development.dump
```

## 🗄️ Check Restore Status

### Verify Databases

```bash
# List all databases
docker exec nayarta-postgres psql -U admin -l

# Check specific database
docker exec nayarta-postgres psql -U admin -d vms_development -c "\dt"

# Count tables
docker exec nayarta-postgres psql -U admin -d vms_development -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';"
```

### Check Roles

```bash
# List all roles
docker exec nayarta-postgres psql -U admin -c "\du"
```

### Check Database Size

```bash
docker exec nayarta-postgres psql -U admin -c "SELECT pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) AS size FROM pg_database;"
```

## 📦 Create New Backup

### Backup Database

```bash
# Backup single database
docker exec nayarta-postgres pg_dump -U admin vms_development > backup/vms_development_$(date +%Y%m%d).sql

# Backup in custom format (compressed)
docker exec nayarta-postgres pg_dump -U admin -Fc vms_development > backup/vms_development_$(date +%Y%m%d).dump

# Backup all databases
docker exec nayarta-postgres pg_dumpall -U admin > backup/all_databases_$(date +%Y%m%d).sql
```

### Backup Globals Only

```bash
docker exec nayarta-postgres pg_dumpall -U admin --globals-only > backup/globals_$(date +%Y%m%d).sql
```

### Using Helper Script

```bash
# Automatic backup with timestamp
./scripts/docker-helper.sh backup
```

## 🔍 Troubleshooting

### Issue: Restore Scripts Not Running

**Cause**: Database directory already has data

**Solution**: Delete data directory and restart
```bash
docker-compose -f docker-compose.db.yml down -v
rm -rf data/database/*
docker-compose -f docker-compose.db.yml up -d
```

### Issue: Permission Denied

**Cause**: Script files not executable

**Solution**: Make scripts executable
```bash
chmod +x backup/*.sh
```

### Issue: Role Already Exists

**Cause**: Roles were already created

**Solution**: This is normal, ignore the warnings. Script will continue.

### Issue: Database Already Exists

**Cause**: Database was already restored

**Solution**: 
```bash
# Drop and recreate
docker exec nayarta-postgres psql -U admin -d postgres -c "DROP DATABASE IF EXISTS vms_development;"
docker exec nayarta-postgres psql -U admin -d postgres -c "CREATE DATABASE vms_development;"

# Restore again
docker exec nayarta-postgres pg_restore -U admin -d vms_development /docker-entrypoint-initdb.d/vms_development.dump
```

### Issue: pg_restore Error

**Common errors and solutions:**

1. **"role does not exist"**
   ```bash
   # Restore globals first
   docker exec -i nayarta-postgres psql -U admin -d postgres < backup/globals.sql
   ```

2. **"already exists"**
   ```bash
   # Use --clean flag or drop objects first
   docker exec nayarta-postgres pg_restore -U admin -d vms_development --clean /docker-entrypoint-initdb.d/vms_development.dump
   ```

3. **"permission denied"**
   ```bash
   # Use --no-owner --no-acl flags
   docker exec nayarta-postgres pg_restore -U admin -d vms_development --no-owner --no-acl /docker-entrypoint-initdb.d/vms_development.dump
   ```

## 📋 Best Practices

1. **Regular Backups**: Schedule daily backups using cron
   ```bash
   # Add to crontab
   0 2 * * * cd /path/to/onprem-nayarta && ./scripts/docker-helper.sh backup
   ```

2. **Test Restores**: Periodically test restore process to ensure backups are valid

3. **Keep Multiple Versions**: Keep at least 7 days of backups

4. **Secure Storage**: Store backups in secure, off-site location

5. **Monitor Disk Space**: Ensure enough space for backups
   ```bash
   df -h data/
   ```

## 📊 File Formats

### .dump Files (Custom Format)
- Binary format (compressed)
- Supports parallel restore
- More flexible for selective restore
- **Recommended for production**

### .sql Files (Plain SQL)
- Text format (human readable)
- Can be edited
- Easy to inspect
- Larger file size

### Converting Between Formats

```bash
# Custom to SQL
pg_restore backup/vms_development.dump > backup/vms_development.sql

# SQL to Custom (need to import first)
pg_dump -U admin -Fc vms_development > backup/vms_development.dump
```

## 🚨 Emergency Recovery

If all else fails:

```bash
# 1. Stop everything
docker-compose -f docker-compose.db.yml down

# 2. Remove all data
rm -rf data/database/*

# 3. Start fresh
docker-compose -f docker-compose.db.yml up -d

# 4. Wait for automatic restore (check logs)
docker-compose -f docker-compose.db.yml logs -f postgres

# 5. If automatic restore doesn't work, do manual restore
docker exec -i nayarta-postgres psql -U admin -d postgres < backup/globals.sql
docker exec nayarta-postgres psql -U admin -d postgres -c "CREATE DATABASE vms_development;"
docker exec nayarta-postgres pg_restore -U admin -d vms_development --no-owner --no-acl /docker-entrypoint-initdb.d/vms_development.dump
```

---

**Last Updated**: 2025-10-17  
**Maintainer**: Nayarta Development Team

