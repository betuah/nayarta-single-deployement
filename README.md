# Nayarta On-Premise Infrastructure

> ✨ **UPDATED**: Docker Compose files telah diperbaiki dan dioptimalkan untuk production!

Infrastructure Docker Compose setup lengkap untuk sistem Nayarta dengan MediaMTX, MQTT, PostgreSQL, MinIO, ClickHouse, dan aplikasi VMS.

## 🎉 What's New

- ✅ **Semua Docker Compose files sudah diperbaiki dan siap digunakan**
- ✅ **Port conflicts resolved** - Tidak ada lagi konflik port antar services
- ✅ **Unified networking** - Semua services menggunakan `nayarta-network`
- ✅ **Health checks** - Semua critical services memiliki health monitoring
- ✅ **Proper dependencies** - Services start dalam urutan yang benar
- ✅ **Helper script** - Script helper untuk memudahkan management

📖 **Lihat [DOCKER-COMPOSE-GUIDE.md](./DOCKER-COMPOSE-GUIDE.md) untuk dokumentasi lengkap!**

## 🏗️ Arsitektur

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Admin Panel   │    │      API        │
│   Port: 80      │    │   Port: 3123    │    │   Port: 8380    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   PostgreSQL    │
                    │   Port: 5432    │
                    └─────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   MediaMTX      │    │   Mosquitto     │    │   MinIO         │
│   (Streaming)   │    │   (MQTT)        │    │   (Storage)     │
│   Port: 8554    │    │   Port: 1883    │    │   Port: 9100    │
│   Port: 8888    │    │   Port: 9001    │    │   Port: 9101    │
└─────────────────┘    └─────────────────┘    └─────────────────┘

                    ┌─────────────────┐
                    │   ClickHouse    │
                    │   (Analytics)   │
                    │   Port: 8124    │
                    │   Port: 9000    │
                    └─────────────────┘
```

## 📁 Struktur Folder

```
onprem-nayarta/
├── docker-compose.yml              # Main compose file (infrastructure)
├── docker-compose.app.yml          # Application services (API, Admin, Frontend)
├── docker-compose.db.yml           # PostgreSQL database
├── docker-compose.stream.yml       # MediaMTX + Mosquitto
├── docker-compose.storage.yml      # MinIO storage
├── docker-compose.oltp.yml         # ClickHouse analytics
├── DOCKER-COMPOSE-GUIDE.md         # 📖 Complete guide (NEW!)
├── config/                         # Konfigurasi services
│   ├── env/                        # Environment variables
│   │   ├── api.env
│   │   ├── admin.env
│   │   └── frontend.env
│   ├── mediamtx/
│   │   └── mediamtx.yml
│   ├── mosquitto/
│   │   ├── mosquitto.conf
│   │   └── passwd
│   ├── postgres/
│   │   ├── postgresql.conf
│   │   └── pg_hba.conf
│   ├── minio/
│   │   ├── config.json
│   │   └── init-minio.sh
│   └── clickhouse/
│       ├── nginx.conf
│       ├── htpasswd
│       └── *.xml
├── data/                           # Data persistent
│   ├── database/                   # PostgreSQL data
│   ├── mediamtx/
│   │   ├── recordings/
│   │   └── hls/
│   └── mosquitto/
│       └── data/
├── backup/                         # Database backups
├── scripts/                        # Utility scripts
│   ├── docker-helper.sh            # 🔧 Docker management helper (NEW!)
│   ├── start.sh                    # Legacy management script
│   └── manage-mqtt-users.sh        # MQTT user management
└── README.md
```

## 🚀 Quick Start

### Prasyarat

1. **Docker & Docker Compose** terinstall
2. **File konfigurasi** sudah disiapkan:
   ```bash
   # Copy example files
   cp config/env/api.example.env config/env/api.env
   cp config/env/admin.example.env config/env/admin.env
   cp config/env/frontend.example.env config/env/frontend.env
   ```

3. **Buat direktori data** (otomatis dengan helper script):
   ```bash
   mkdir -p data/database data/mediamtx/recordings data/mediamtx/hls data/mosquitto/data
   ```

### Method 1: Menggunakan Docker Helper Script (Recommended ✨)

```bash
# Make script executable
chmod +x scripts/docker-helper.sh

# Check requirements
./scripts/docker-helper.sh check

# Initial setup
./scripts/docker-helper.sh setup

# Start all services
./scripts/docker-helper.sh start all

# Or start specific profiles
./scripts/docker-helper.sh start minimal    # DB + App only
./scripts/docker-helper.sh start infra      # Infrastructure only
./scripts/docker-helper.sh start app        # Applications only

# Check status
./scripts/docker-helper.sh status

# View logs
./scripts/docker-helper.sh logs

# Show access URLs
./scripts/docker-helper.sh urls

# Stop services
./scripts/docker-helper.sh stop

# Show help
./scripts/docker-helper.sh help
```

### Method 2: Menggunakan Docker Compose Langsung

```bash
# Start infrastructure (DB, Streaming, Storage)
docker-compose up -d

# Start applications
docker-compose -f docker-compose.app.yml up -d

# Start analytics
docker-compose -f docker-compose.oltp.yml up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### Method 3: Step-by-Step (Untuk First Time Setup)

```bash
# 1. Start database first
docker-compose -f docker-compose.db.yml up -d

# 2. Wait for database to be healthy (check with)
docker-compose -f docker-compose.db.yml logs -f postgres
# Wait until you see: "database system is ready to accept connections"

# 3. Start application services
docker-compose -f docker-compose.app.yml up -d

# 4. Start other infrastructure (optional)
docker-compose -f docker-compose.stream.yml up -d
docker-compose -f docker-compose.storage.yml up -d
docker-compose -f docker-compose.oltp.yml up -d
```

### Akses Aplikasi

Setelah semua services berjalan:

| Service | URL | Credentials |
|---------|-----|-------------|
| **Frontend** | http://localhost:80 | - |
| **Admin** | http://localhost:3123 | - |
| **API** | http://localhost:8380 | - |
| **MinIO Console** | http://localhost:9101 | admin: `nayarta_admin`<br>pass: `nayarta_minio_password` |

📖 **Lihat [DOCKER-COMPOSE-GUIDE.md](./DOCKER-COMPOSE-GUIDE.md) untuk semua URLs dan credentials!**

## 🔧 Konfigurasi Services

### 🌐 Application Services

#### Frontend (Next.js)
- **Port**: 80
- **Access**: http://localhost:80
- **Container**: `vms-frontend`

#### Admin Panel (Next.js)
- **Port**: 3123 (⚠️ Changed from 8123)
- **Access**: http://localhost:3123
- **Container**: `vms-admin`

#### API (Backend)
- **Port**: 8380
- **Access**: http://localhost:8380
- **Container**: `vms-api`

### 🗄️ Database Services

#### PostgreSQL
- **Host**: `localhost:5432`
- **Database**: `vms_development`
- **User**: `admin`
- **Password**: `admin122`
- **Container**: `nayarta-postgres`

#### ClickHouse (Analytics)
- **HTTP Port**: 8124 (⚠️ Changed from 8123)
- **Native Port**: 9000
- **User**: `default`
- **Password**: `beEs4rP@ssW0rD!`
- **Container**: `ch-server`
- **UI Proxy**: http://localhost:8081

### 📡 Streaming Services

#### MediaMTX (Streaming Server)
- **RTSP**: `rtsp://localhost:8554`
- **HLS**: `http://localhost:8888`
- **API**: `http://localhost:9997`
- **Metrics**: `http://localhost:9998`
- **Container**: `nayarta-mediamtx`

#### Mosquitto (MQTT Broker)
- **MQTT**: `mqtt://localhost:1883`
- **WebSocket**: `ws://localhost:9001`
- **Container**: `nayarta-mosquitto`

**Customize MQTT Users:**
```bash
# Add new user
./scripts/manage-mqtt-users.sh add myuser mypassword

# Change password
./scripts/manage-mqtt-users.sh change user newpassword

# List all users
./scripts/manage-mqtt-users.sh list
```

### 💾 Storage Service

#### MinIO
- **API**: `http://localhost:9100` (⚠️ Changed from 9000)
- **Console**: `http://localhost:9101` (⚠️ Changed from 9001)
- **User**: `nayarta_admin`
- **Password**: `nayarta_minio_password`
- **Container**: `nayarta-minio`

**Default Buckets:**
- `recordings` - Video recordings
- `uploads` - User uploads
- `exports` - Exported data

## ⚠️ Important Port Changes

Berikut port yang diubah untuk menghindari konflik:

| Service | Port Lama | Port Baru | Alasan |
|---------|-----------|-----------|---------|
| MinIO API | 9000 | 9100 | Konflik dengan ClickHouse |
| MinIO Console | 9001 | 9101 | Konflik dengan Mosquitto WebSocket |
| ClickHouse HTTP | 8123 | 8124 | Konflik dengan Admin service |
| Admin Panel | 8123 | 3123 | Konflik dengan ClickHouse |

## 📊 Database Import

Script `init-db.sh` akan otomatis:

1. **Cek apakah database sudah ada data**
2. **Jika kosong**, import file dari `data/database/`
3. **Jika sudah ada data**, skip import
4. **Jika tidak ada file export**, buat struktur dasar

### Format File Database yang Didukung

- `.sql` files - SQL scripts
- `.dump` files - PostgreSQL custom format dumps

### Contoh Import Database

```bash
# Letakkan file backup di folder backup/
cp your-database-backup.sql backup/
cp your-backup.dump backup/
cp your-backup.sql.gz backup/

# Restart database service untuk trigger import
./scripts/start.sh restart db
```

## 🛠️ Management Commands

### 🔧 Docker Helper Script (Recommended)

Script helper yang powerful dengan banyak fitur:

```bash
# Management
./scripts/docker-helper.sh start [all|infra|app|db|stream|storage|analytics|minimal]
./scripts/docker-helper.sh stop [volumes]
./scripts/docker-helper.sh restart [service]

# Monitoring
./scripts/docker-helper.sh status          # Show all services status + health
./scripts/docker-helper.sh logs [service]  # Show logs (all or specific)
./scripts/docker-helper.sh urls            # Show all access URLs

# Maintenance
./scripts/docker-helper.sh backup          # Backup databases
./scripts/docker-helper.sh cleanup         # Clean up unused resources
./scripts/docker-helper.sh check           # Check requirements
./scripts/docker-helper.sh setup           # Initial setup

# Help
./scripts/docker-helper.sh help            # Show all commands
```

**Examples:**
```bash
# Start minimal setup (DB + Apps only)
./scripts/docker-helper.sh start minimal

# Start full infrastructure
./scripts/docker-helper.sh start infra

# Start everything
./scripts/docker-helper.sh start all

# Restart specific service
./scripts/docker-helper.sh restart api

# View API logs
./scripts/docker-helper.sh logs api

# Backup databases
./scripts/docker-helper.sh backup

# Stop everything and remove data
./scripts/docker-helper.sh stop volumes
```

### 🐳 Docker Compose Commands

Manual docker-compose commands:

```bash
# Infrastructure (DB, Streaming, Storage)
docker-compose up -d
docker-compose down
docker-compose ps
docker-compose logs -f

# Applications
docker-compose -f docker-compose.app.yml up -d
docker-compose -f docker-compose.app.yml down
docker-compose -f docker-compose.app.yml logs -f

# Specific services
docker-compose -f docker-compose.db.yml up -d
docker-compose -f docker-compose.stream.yml up -d
docker-compose -f docker-compose.storage.yml up -d
docker-compose -f docker-compose.oltp.yml up -d

# Restart specific service
docker-compose restart postgres
docker-compose -f docker-compose.app.yml restart api

# View logs
docker-compose logs -f postgres
docker-compose -f docker-compose.app.yml logs -f api
```

### 📊 Health Checks

Check service health:

```bash
# Using helper script
./scripts/docker-helper.sh status

# Manual check
docker inspect --format='{{.State.Health.Status}}' nayarta-postgres
docker inspect --format='{{.State.Health.Status}}' nayarta-minio
docker inspect --format='{{.State.Health.Status}}' ch-server
```

## 🔒 Security Notes

### Default Credentials

**⚠️ IMPORTANT: Ganti semua password default sebelum production!**

| Service | Username | Password |
|---------|----------|----------|
| PostgreSQL | `admin` | `admin122` |
| MinIO | `nayarta_admin` | `nayarta_minio_password` |
| ClickHouse | `default` | `beEs4rP@ssW0rD!` |
| MQTT | (configured in passwd file) | (configured in passwd file) |

### Update Credentials

#### PostgreSQL
Edit di `docker-compose.db.yml` atau `docker-compose.app.yml`:
```yaml
environment:
  POSTGRES_USER: your_user
  POSTGRES_PASSWORD: your_password
```

#### MinIO
Edit di `docker-compose.storage.yml`:
```yaml
environment:
  MINIO_ROOT_USER: your_user
  MINIO_ROOT_PASSWORD: your_password
```

#### ClickHouse
Edit di `docker-compose.oltp.yml`:
```yaml
environment:
  CLICKHOUSE_PASSWORD: 'your_password'
```

### Generate MQTT Passwords

```bash
# Install mosquitto client tools
sudo apt-get install mosquitto-clients

# Generate password hash
mosquitto_passwd -c config/mosquitto/passwd new_username
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Port Already in Use
```bash
# Check which process is using the port
lsof -i :5432  # or any port number
netstat -an | grep LISTEN

# Kill the process or change port in docker-compose file
```

#### 2. Permission Issues
```bash
# Fix data directory permissions
sudo chown -R $USER:$USER data/

# Make scripts executable
chmod +x scripts/*.sh
```

#### 3. Network Issues
Network dibuat otomatis sekarang, tapi jika ada masalah:
```bash
# Remove all networks
docker network prune

# Restart services
./scripts/docker-helper.sh start all
```

#### 4. Container Not Healthy
```bash
# Check health status
docker inspect nayarta-postgres | jq '.[0].State.Health'

# View detailed logs
./scripts/docker-helper.sh logs postgres

# Restart service
./scripts/docker-helper.sh restart postgres
```

#### 5. Database Connection Failed
```bash
# Wait for database to be ready (30-40 seconds)
docker-compose -f docker-compose.db.yml logs -f postgres

# Check if postgres is accepting connections
docker exec nayarta-postgres pg_isready -U admin -d vms_development
```

### Reset Everything

```bash
# Using helper script
./scripts/docker-helper.sh stop volumes

# Manual cleanup
docker-compose down -v
docker-compose -f docker-compose.app.yml down -v
docker-compose -f docker-compose.oltp.yml down -v
docker system prune -a

# Start fresh
./scripts/docker-helper.sh start all
```

### Check Logs

```bash
# Using helper script (recommended)
./scripts/docker-helper.sh logs              # All services
./scripts/docker-helper.sh logs postgres     # Specific service

# Direct docker commands
docker logs nayarta-postgres -f
docker logs vms-api -f
docker logs nayarta-minio -f
docker logs ch-server -f

# Check logs for errors
docker logs nayarta-postgres 2>&1 | grep -i error
```

### Debug Mode

```bash
# Start services in foreground to see logs
docker-compose up  # Without -d flag

# Or for specific service
docker-compose -f docker-compose.db.yml up
```

## 📝 Development

### Environment Variables

All app configurations menggunakan `.env` files di `config/env/`:

```bash
# API configuration
config/env/api.env

# Admin panel configuration
config/env/admin.env

# Frontend configuration
config/env/frontend.env
```

### Adding New Services

1. Buat file `docker-compose.newservice.yml`
2. Tambahkan service ke `docker-compose.yml` dengan `extends` (optional)
3. Update script `docker-helper.sh` untuk handle service baru (optional)
4. Pastikan menggunakan network `nayarta-network`

### Custom Configuration

Edit file konfigurasi di folder `config/` sesuai kebutuhan:

- `config/env/*.env` - Environment variables untuk apps
- `config/mediamtx/mediamtx.yml` - MediaMTX settings
- `config/mosquitto/mosquitto.conf` - MQTT settings
- `config/postgres/postgresql.conf` - PostgreSQL settings
- `config/clickhouse/*.xml` - ClickHouse settings

### Best Practices

1. **Development**: Gunakan profile `minimal` atau `infra` untuk development
2. **Production**: 
   - Ganti semua default passwords
   - Setup SSL/TLS certificates
   - Configure firewall rules
   - Setup regular backups
3. **Backup**: 
   - Use `./scripts/docker-helper.sh backup` untuk backup otomatis
   - Schedule cron job untuk backup berkala
4. **Monitoring**: 
   - Check `./scripts/docker-helper.sh status` secara berkala
   - Setup alerting untuk services yang down

## 📚 Documentation

- **[DOCKER-COMPOSE-GUIDE.md](./DOCKER-COMPOSE-GUIDE.md)** - Complete guide for docker-compose
- **[README.md](./README.md)** - This file (overview)
- Configuration files have inline comments

## 📄 License

MIT License - Lihat file LICENSE untuk detail.

## 🤝 Support

Untuk pertanyaan atau issues:
1. Baca [DOCKER-COMPOSE-GUIDE.md](./DOCKER-COMPOSE-GUIDE.md) untuk troubleshooting
2. Check logs dengan `./scripts/docker-helper.sh logs`
3. Buat issue di repository ini dengan detail error

---

**Made with ❤️ by Nayarta Team**
