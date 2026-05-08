#!/bin/bash
# B@tHome — VM Zsasz (10.10.20.118) — AppFlowy — User: docops
set -e
bash <(curl -fsSL https://raw.githubusercontent.com/SphinxXV/bathome-scripts/main/init/init.sh) docops zsasz
echo "==> Installation AppFlowy..."
mkdir -p /home/docops/docker/zsasz && cd /home/docops/docker/zsasz
printf 'services:\n\n  gotrue:\n    container_name: appflowy_gotrue\n    image: appflowyinc/gotrue:latest\n    restart: unless-stopped\n    depends_on:\n      - postgres\n    environment:\n      - GOTRUE_DB_DRIVER=postgres\n      - GOTRUE_DB_DATABASE_URL=postgres://docops:Porte-Violon-Cible@postgres:5432/appflowy?search_path=auth\n      - GOTRUE_SITE_URL=http://10.10.20.118:3000\n      - GOTRUE_URI_ALLOW_LIST=http://10.10.20.118:3000\n      - GOTRUE_DISABLE_SIGNUP=false\n      - GOTRUE_JWT_SECRET=Porte-Violon-Cible\n      - GOTRUE_JWT_EXP=7200\n      - GOTRUE_SMTP_ADMIN_EMAIL=admin@bathome.local\n      - GOTRUE_MAILER_AUTOCONFIRM=true\n      - API_EXTERNAL_URL=http://10.10.20.118:9999\n      - PORT=9999\n    ports:\n      - "9999:9999"\n\n  appflowy_cloud:\n    container_name: appflowy_cloud\n    image: appflowyinc/appflowy_cloud:latest\n    restart: unless-stopped\n    depends_on:\n      - postgres\n      - redis\n      - gotrue\n    environment:\n      - RUST_LOG=info\n      - APPFLOWY_DATABASE_URL=postgres://docops:Porte-Violon-Cible@postgres:5432/appflowy\n      - APPFLOWY_REDIS_URI=redis://redis:6379\n      - APPFLOWY_WEB_URL=http://10.10.20.118:3000\n      - APPFLOWY_GOTRUE_BASE_URL=http://gotrue:9999\n      - APPFLOWY_GOTRUE_JWT_SECRET=Porte-Violon-Cible\n    ports:\n      - "8000:8000"\n\n  appflowy_web:\n    container_name: appflowy_web\n    image: appflowyinc/appflowy_web:latest\n    restart: unless-stopped\n    ports:\n      - "3000:80"\n    depends_on:\n      - appflowy_cloud\n\n  postgres:\n    container_name: appflowy_postgres\n    image: pgvector/pgvector:pg16\n    restart: unless-stopped\n    environment:\n      POSTGRES_USER: docops\n      POSTGRES_PASSWORD: Porte-Violon-Cible\n      POSTGRES_DB: appflowy\n    volumes:\n      - ./postgres-data:/var/lib/postgresql/data\n\n  redis:\n    container_name: appflowy_redis\n    image: redis:7\n    restart: unless-stopped\n    volumes:\n      - ./redis-data:/data\n' > docker-compose.yml
chown -R docops:docops /home/docops/docker
ufw allow 3000/tcp comment 'AppFlowy Web'
ufw allow 8000/tcp comment 'AppFlowy API'
ufw allow 9999/tcp comment 'GoTrue Auth'
ufw reload
docker compose up -d
echo "==> Activation pgvector..."
sleep 15
docker exec appflowy_postgres psql -U docops -d appflowy -c "CREATE EXTENSION IF NOT EXISTS vector;" || true
echo ""
echo "============================================================"
echo " Zsasz installe !"
echo " AppFlowy : http://10.10.20.118:3000"
echo " Node Exporter : http://10.10.20.118:9100/metrics"
echo "============================================================"