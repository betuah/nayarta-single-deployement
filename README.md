# Nayarta VMS - Docker Compose

Super clean dan modular Docker Compose setup dengan **include-based architecture**.

---

### Quick Start

Copy the template and update your configuration:
```bash
cp .env.template .env
```

> **Note:**  
> You need to update the `HOST_IP` value every time your IP changes.
> You must update this value every time your IP changes.

```bash
docker compose --profile appstack up -d
docker compose --profile analytics up -d
docker compose --profile app up -d
```

```bash
docker compose --profile all stats                      # All services
```

```bash
docker build \
  --build-arg NEXTAUTH_SECRET="5eLdNKVMGGfXR5gvTF70vArhjzuLYAU/2W+ue1mZ/A0=" \
  --build-arg NEXTAUTH_URL="http://localhost:8456" \
  --build-arg DATABASE_URL='postgres://db_manager:bd37f728d7bfb0e6a908b37e86ebfe8a2ee85faa@nayarta-postgres:5432/vms_development' \
  -t beesar/beesar-vms-admin .
```

## Manual Restore Database
```sh
# 1️⃣ Restore global roles & permissions
psql -U admin -d postgres -f /docker-entrypoint-initdb.d/globals.sql

# 2️⃣ Create Database
psql -U admin -d postgres -c "CREATE DATABASE vms_development;"
psql -U admin -d postgres -c "CREATE DATABASE analytics_db;"
psql -U admin -d postgres -c "CREATE DATABASE schedulerdb;"

# 3️⃣ Restore Database
pg_restore -U admin -d vms_development /docker-entrypoint-initdb.d/vms_development.dump
pg_restore -U admin -d analytics_db /docker-entrypoint-initdb.d/analytics_db.dump
pg_restore -U admin -d schedulerdb /docker-entrypoint-initdb.d/schedulerdb.dump
```

## NVIDIA Container toolkit
### 1. Add NVIDIA package repositories
```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

### 2. Install toolkit
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

### 3. Configure Docker
sudo nvidia-ctk runtime configure --runtime=docker

### 4. Restart Docker
sudo service docker restart
```