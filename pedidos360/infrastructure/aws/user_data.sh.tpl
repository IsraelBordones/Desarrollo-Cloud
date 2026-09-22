#!/bin/bash
set -euxo pipefail

# 1. Crear 1GB de memoria Swap para evitar que t2.micro se sature
dd if=/dev/zero of=/swapfile bs=1M count=1024
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# 2. Instalar Docker
dnf update -y
dnf install -y docker
systemctl enable --now docker

# 3. Descargar usando AWS CLI (Aprovecha los permisos del LabInstanceProfile)
mkdir -p /opt/app
cd /opt/app
aws s3 cp s3://artefactos-pedidos360/${service_name}-service-1.0.0.jar app.jar

# 4. Iniciar el contenedor con el SERVER_PORT inyectado
docker run -d --restart unless-stopped \
  --name ${service_name}-service \
  -p ${service_port}:${service_port} \
  -e SERVER_PORT="${service_port}" \
  -e AZURE_TENANT_ID="${azure_tenant_id}" \
  -e AZURE_ISSUER_URI="https://login.microsoftonline.com/${azure_tenant_id}/v2.0" \
  -e AZURE_AUDIENCE="${azure_audience}" \
  -e CORS_ALLOWED_ORIGINS="${cors_origins}" \
  -v /opt/app/app.jar:/app/app.jar \
  eclipse-temurin:17-jre java -jar /app/app.jar