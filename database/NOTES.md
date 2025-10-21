###  Manual Restore Database
```sh
# 1️⃣ Restore global roles & permissions
psql -U admin -d postgres -f /docker-entrypoint-initdb.d/globals.sql

# 2️⃣ Create Database
psql -U admin -d postgres -c "CREATE DATABASE vms_development;"
psql -U admin -d postgres -c "CREATE DATABASE analytics_db;"
psql -U admin -d postgres -c "CREATE DATABASE schedulerdb;"

# 3️⃣ Restore all databases
pg_restore -U admin -d vms_development /docker-entrypoint-initdb.d/vms_development.dump
pg_restore -U admin -d analytics_db /docker-entrypoint-initdb.d/analytics_db.dump
pg_restore -U admin -d schedulerdb /docker-entrypoint-initdb.d/schedulerdb.dump

```

### Running backup
docker compose --profile dbbackup up