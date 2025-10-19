# Nayarta VMS - Docker Compose

Super clean dan modular Docker Compose setup dengan **include-based architecture**.

---

## 📋 Common Commands

```bash
docker-compose --profile all up -d                      # All services
docker-compose --profile appstack up -d                 # App Stack services
docker-compose --profile analytics up -d                # Analytics services
```

```bash
docker build \
  --build-arg NEXTAUTH_SECRET="5eLdNKVMGGfXR5gvTF70vArhjzuLYAU/2W+ue1mZ/A0=" \
  --build-arg NEXTAUTH_URL="http://localhost:8456" \
  --build-arg DATABASE_URL='postgres://db_manager:bd37f728d7bfb0e6a908b37e86ebfe8a2ee85faa@nayarta-postgres:5432/vms_development' \
  -t beesar/beesar-vms-admin .