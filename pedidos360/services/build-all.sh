#!/bin/bash
# Builds all microservice jars.
set -e
for s in gateway pedidos productos clientes notificaciones; do
  echo "==> Building $s-service"
  (cd "$(dirname "$0")/$s-service" && mvn clean package -DskipTests)
done
echo "All jars built under services/*/target/"
