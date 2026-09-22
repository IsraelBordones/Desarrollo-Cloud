# Pedidos360 🛒☁️

Sistema **Cloud Native** de gestión de pedidos desarrollado para la asignatura
**DSY1107 – Desarrollo Cloud Native I**.

Integra un **frontend Angular 17** autenticado con **Azure AD (Microsoft Entra ID)**
mediante **MSAL**, un backend de **5 microservicios Spring Boot** protegidos con
**JWT (OAuth 2.0 / OpenID Connect)**, y un **AWS API Gateway (HTTP API)** que actúa
como *API Manager*, validando los tokens y enrutando el tráfico hacia los
microservicios desplegados en **EC2**. Toda la infraestructura se provisiona con
**Terraform** (AWS + Azure AD).

---

## 📐 Arquitectura

```
                          ┌──────────────────────────────────────────┐
                          │        Azure AD / Microsoft Entra ID       │
                          │              (IDaaS - Tenant)              │
                          │  • App Registration "Pedidos360"           │
                          │  • Scopes: Pedidos.Read / Pedidos.Write    │
                          │  • Roles: Admin / User                     │
                          │  • Emite JWT (OAuth2 / OIDC)               │
                          └───────────────▲───────────┬───────────────┘
                                          │           │
                        1. Login (MSAL)   │           │ 2. JWT (access_token)
                                          │           ▼
   ┌───────────────────────┐     ┌────────┴───────────────────────┐
   │   Angular 17 + MSAL    │     │   El navegador obtiene el JWT   │
   │  (S3 + CloudFront)     │     │   y lo adjunta en cada request  │
   │  Login / Dashboard /   │     │   (MsalInterceptor -> Bearer)   │
   │  Pedidos/Productos/    │     └────────┬───────────────────────┘
   │  Clientes (CRUD)       │              │
   └───────────┬───────────┘              │ 3. HTTPS + Authorization: Bearer <JWT>
               │                          ▼
               │           ┌──────────────────────────────────────────┐
               └──────────►│      AWS API Gateway (HTTP API)            │
                           │      === API MANAGER ===                   │
                           │  • JWT Authorizer -> issuer Azure AD       │
                           │    (valida firma, issuer, audience, exp)   │
                           │  • CORS (origins, methods, headers)        │
                           │  • Stages: dev / qa                        │
                           │  • Rutas: /pedidos /productos /clientes    │
                           │           /notificaciones /gateway/health  │
                           └───┬───────┬───────┬───────┬───────┬────────┘
                               │       │       │       │       │
              HTTP_PROXY  ┌────▼─┐ ┌───▼──┐ ┌──▼───┐ ┌─▼────┐ ┌▼──────────┐
              (EC2:puerto)│gateway│ │pedid.│ │produ.│ │clien.│ │notificac. │
                          │ 8080  │ │ 8081 │ │ 8082 │ │ 8083 │ │   8084    │
                          │  BFF  │ │ CRUD │ │ CRUD │ │ CRUD │ │  notify   │
                          └───┬───┘ └───┬──┘ └──┬───┘ └──┬───┘ └────┬──────┘
                              │         │       │        │          │
                              └─────────┴───────┴────────┴──────────┘
                                      Cada microservicio Spring Boot
                                   valida el JWT (resource-server) y
                                   persiste en H2 (dev) / PostgreSQL (prod)
```

### Doble validación del JWT (defensa en profundidad)
1. **AWS API Gateway** (JWT Authorizer) valida el token *antes* de enrutar.
2. **Cada microservicio Spring Boot** (`spring-boot-starter-oauth2-resource-server`)
   valida nuevamente firma, `issuer`, `audience` y expiración, y extrae los
   claims (`oid`, `name`, `email`, `roles`, `scp`).

---

## 🧩 Componentes

| Componente              | Tecnología                | Puerto | Descripción                                        |
|-------------------------|---------------------------|--------|----------------------------------------------------|
| frontend                | Angular 17 + MSAL 3       | 4200   | SPA con login Azure AD y CRUD                       |
| gateway-service         | Spring Boot 3.2 (BFF)     | 8080   | Valida JWT y enruta a microservicios               |
| pedidos-service         | Spring Boot 3.2 + JPA     | 8081   | CRUD de pedidos                                     |
| productos-service       | Spring Boot 3.2 + JPA     | 8082   | CRUD de productos                                   |
| clientes-service        | Spring Boot 3.2 + JPA     | 8083   | CRUD de clientes                                    |
| notificaciones-service  | Spring Boot 3.2 + JPA     | 8084   | Notificaciones de pedidos (`/notify`, `/history`)  |
| PostgreSQL              | postgres:16               | 5432   | Base de datos (prod/local con docker-compose)      |

### Estructura del repositorio
```
pedidos360/
├── frontend/                 # Angular 17 + MSAL
├── services/
│   ├── gateway-service/      # BFF (JWT + routing)
│   ├── pedidos-service/
│   ├── productos-service/
│   ├── clientes-service/
│   └── notificaciones-service/
├── infrastructure/
│   ├── aws/                  # Terraform: VPC, EC2, API Gateway, S3, CloudFront
│   └── azure/                # Terraform: App Registration (Entra ID)
├── postman/                  # Colección de pruebas
├── docker-compose.yml        # Stack local (5 servicios + Postgres)
└── README.md
```

---

## ✅ Prerrequisitos

- **Java 17** (`java -version`)
- **Maven 3.9+** (`mvn -version`) — o usar el Dockerfile multi-stage incluido
- **Node.js 18+** y **Angular CLI 17** (`npm i -g @angular/cli`)
- **Docker** y **Docker Compose** (para el stack local)
- **Terraform 1.5+**
- Una cuenta **Azure** con permiso para crear un *App Registration* en Entra ID
- Una cuenta **AWS Academy** (o AWS) con acceso a EC2, API Gateway, S3, CloudFront

---

## 🚀 Despliegue

### Paso 1 — Crear la aplicación en Azure AD (IDaaS)

```bash
cd infrastructure/azure
cp terraform.tfvars.example terraform.tfvars
# Edita terraform.tfvars con tu tenant_id
az login                      # autentica el proveedor azuread
terraform init
terraform plan
terraform apply
```

Anota los **outputs**: `tenant_id`, `client_id`, `issuer_uri`, `api_audience`,
`api_scopes`. Los necesitarás para AWS y para el frontend.

> El App Registration crea: redirect URIs (localhost + CloudFront), los scopes
> `Pedidos.Read` / `Pedidos.Write` y los roles `Admin` / `User`.

### Paso 2 — Compilar los microservicios (jars)

```bash
cd services
for s in gateway pedidos productos clientes notificaciones; do
  (cd $s-service && mvn clean package -DskipTests)
done
```

Publica los jars en un bucket S3 o en un servidor HTTP accesible por EC2 y
coloca esa URL en `artifacts_base_url` (Terraform AWS). El `user_data` de cada
EC2 los descarga y los ejecuta en un contenedor Docker.

### Paso 3 — Provisionar AWS con Terraform

```bash
cd infrastructure/aws
cp terraform.tfvars.example terraform.tfvars
# Edita: azure_tenant_id, azure_client_id, azure_api_audience, artifacts_base_url
terraform init
terraform plan
terraform apply
```

Crea: VPC + subnets + IGW, Security Groups, 5 EC2 (una por microservicio),
**API Gateway HTTP** con **JWT Authorizer** (issuer = Azure AD), rutas, CORS,
stages **dev** y **qa**, y **S3 + CloudFront** para el frontend.

Outputs clave: `api_gateway_dev_url`, `api_gateway_qa_url`, `cloudfront_url`,
`frontend_bucket`, `ec2_public_ips`.

### Paso 4 — Configurar y compilar el frontend

Edita `frontend/src/environments/environment.prod.ts` con:
- `azure.tenantId`, `azure.clientId` (output de Azure)
- `azure.redirectUri` = `https://<cloudfront_url>`
- `apiGatewayUrl` = `https://<api_gateway_dev_url>` (o `qa`)

```bash
cd frontend
npm install
npm run build:prod
# Sube el contenido de dist/pedidos360-frontend/browser al bucket S3
aws s3 sync dist/pedidos360-frontend/browser s3://<frontend_bucket> --delete
# Invalida la caché de CloudFront
aws cloudfront create-invalidation --distribution-id <ID> --paths "/*"
```

> Recuerda añadir la URL de CloudFront a los `redirect_uris` del App Registration
> de Azure (variable `redirect_uris` en `infrastructure/azure`) y re-aplicar.

---

## 💻 Ejecución local (desarrollo)

### Opción A — Docker Compose (todo el backend + Postgres)

```bash
cp .env.example .env      # coloca AZURE_TENANT_ID y AZURE_AUDIENCE
docker compose up --build
```

Servicios disponibles en `localhost:8080..8084`, Postgres en `5432`.

### Opción B — Servicios individuales (H2 en memoria)

```bash
cd services/pedidos-service
AZURE_TENANT_ID=<tenant> AZURE_AUDIENCE=api://pedidos360-api mvn spring-boot:run
```

### Frontend

```bash
cd frontend
npm install
npm start           # http://localhost:4200
```

Edita `environment.ts` con tu `tenantId` y `clientId` de Azure antes de iniciar.

---

## 🔑 Cómo obtener un JWT de Azure AD para pruebas (Postman)

**Opción 1 — Desde el frontend (recomendada):**
1. Inicia sesión en la app Angular.
2. Abre DevTools → Application → Local Storage y copia el `access_token`
   (o usa `console` para inspeccionar el token emitido por MSAL).

**Opción 2 — Flujo de dispositivo con Azure CLI:**
```bash
az account get-access-token \
  --resource api://pedidos360-api \
  --query accessToken -o tsv
```

**Opción 3 — Postman (Authorization Code / OAuth 2.0):**
- Auth URL: `https://login.microsoftonline.com/<tenant>/oauth2/v2.0/authorize`
- Token URL: `https://login.microsoftonline.com/<tenant>/oauth2/v2.0/token`
- Client ID: `<client_id>`
- Scope: `api://pedidos360-api/Pedidos.Read api://pedidos360-api/Pedidos.Write`
- Redirect URI: `http://localhost:4200`

Luego:
```
Import postman/pedidos360.postman_collection.json
Variables:  baseUrl = <api_gateway_dev_url>   token = <access_token>
```
- `GET /pedidos` **sin** token → **401 Unauthorized** ✅
- `GET /pedidos` **con** token → **200 OK** ✅

---

## 🔐 Variables de configuración

### Backend (microservicios) — variables de entorno
| Variable                | Ejemplo                                                    |
|-------------------------|------------------------------------------------------------|
| `AZURE_TENANT_ID`       | `00000000-0000-0000-0000-000000000000`                     |
| `AZURE_ISSUER_URI`      | `https://login.microsoftonline.com/<tenant>/v2.0`          |
| `AZURE_AUDIENCE`        | `api://pedidos360-api`                                      |
| `CORS_ALLOWED_ORIGINS`  | `http://localhost:4200,https://<cloudfront>`               |
| `DB_URL` / `DB_USERNAME`/ `DB_PASSWORD` / `DB_DRIVER` | conexión JPA (H2 o Postgres)  |

### Frontend — `environment(.prod).ts`
| Campo             | Descripción                                       |
|-------------------|---------------------------------------------------|
| `azure.tenantId`  | Tenant de Entra ID                                |
| `azure.clientId`  | App (client) ID del App Registration              |
| `azure.redirectUri`| `http://localhost:4200` o URL de CloudFront      |
| `azure.apiScopes` | `api://pedidos360-api/Pedidos.Read` (+ `.Write`)  |
| `apiGatewayUrl`   | URL de invocación del API Gateway (stage dev/qa)  |

---

## 🧪 Verificación rápida

| Prueba                                            | Resultado esperado |
|---------------------------------------------------|--------------------|
| `GET /gateway/health`                             | `200 {"status":"UP"}` |
| `GET /pedidos` sin `Authorization`                | `401`              |
| `GET /pedidos` con JWT válido                     | `200` + lista      |
| JWT con audience incorrecto                        | `401`              |
| Login desde Angular                               | Redirección a Microsoft y retorno con sesión |

---

## 📝 Notas de seguridad y buenas prácticas
- Los microservicios son **stateless** (sin sesión) y validan el JWT en cada request.
- Se usan **DTOs** con validaciones (`jakarta.validation`) y manejo centralizado de errores.
- CORS restringido a los orígenes del frontend.
- En un entorno endurecido, restringir el Security Group de EC2 al *prefix list*
  gestionado del API Gateway y usar VPC Link + subredes privadas.
- Los `.tfvars`, `node_modules`, `target/` y `dist/` están excluidos vía `.gitignore`.
