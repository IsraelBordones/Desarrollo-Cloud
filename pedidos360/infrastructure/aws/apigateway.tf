###############################################################################
# AWS API Gateway (HTTP API) - the "API Manager"
#
# - JWT authorizer validating Azure AD tokens (issuer + audience)
# - HTTP_PROXY integrations to each microservice EC2 instance
# - Routes for pedidos / productos / clientes / notificaciones
# - CORS configuration for the Angular frontend
# - Two stages: dev and qa (auto-deploy)
###############################################################################

resource "aws_apigatewayv2_api" "http" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
  description   = "Pedidos360 API Manager - routes to microservices with Azure AD JWT validation"

  cors_configuration {
  allow_origins     = ["http://localhost:4200"]
  allow_methods     = ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"]
  allow_headers     = ["Authorization", "Content-Type", "Accept", "Origin", "X-Requested-With"]
  allow_credentials = true
  max_age           = 3600
}

  tags = local.tags
}

###############################################################################
# JWT Authorizer -> Azure AD (Microsoft Entra ID)
###############################################################################
resource "aws_apigatewayv2_authorizer" "azure_jwt" {
  api_id           = aws_apigatewayv2_api.http.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${var.project_name}-azure-jwt"

  jwt_configuration {
    # Both the API identifier URI and the client id are accepted as audience.
    audience = [var.azure_api_audience, var.azure_client_id]
    issuer   = "https://login.microsoftonline.com/${var.azure_tenant_id}/v2.0"
  }
}

###############################################################################
# Integrations (HTTP_PROXY to each EC2 public IP:port)
###############################################################################
locals {
  # Backend microservices
  api_services = {
    pedidos        = { port = 8081 }
    productos      = { port = 8082 }
    clientes       = { port = 8083 }
    notificaciones = { port = 8084 }
  }

  # Generar rutas explícitas para evitar usar "ANY" y liberar OPTIONS para CORS
  allowed_methods = ["GET", "POST", "PUT", "DELETE", "PATCH"]
  
  route_combinations = {
    for pair in setproduct(local.allowed_methods, keys(local.api_services)) : 
    "${pair[0]}_${pair[1]}" => {
      method  = pair[0]
      service = pair[1]
    }
  }
}

# 1. Puente para las rutas base (ejemplo: /pedidos) sin la variable proxy
resource "aws_apigatewayv2_integration" "service_base" {
  for_each               = local.api_services
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = "http://${aws_instance.service[each.key].public_ip}:${each.value.port}/${each.key}"
  payload_format_version = "1.0"
}

# 2. Puente para las sub-rutas (ejemplo: /pedidos/123) con la variable proxy
resource "aws_apigatewayv2_integration" "service_proxy" {
  for_each               = local.api_services
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = "http://${aws_instance.service[each.key].public_ip}:${each.value.port}/${each.key}/{proxy}"
  payload_format_version = "1.0"
}

# 3. Ruta principal que usa el puente base (Métodos explícitos)
resource "aws_apigatewayv2_route" "service_base" {
  for_each           = local.route_combinations
  api_id             = aws_apigatewayv2_api.http.id
  route_key          = "${each.value.method} /${each.value.service}"
  target             = "integrations/${aws_apigatewayv2_integration.service_base[each.value.service].id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.azure_jwt.id
}

# 4. Sub-rutas que usan el puente proxy (Métodos explícitos)
resource "aws_apigatewayv2_route" "service_proxy" {
  for_each           = local.route_combinations
  api_id             = aws_apigatewayv2_api.http.id
  route_key          = "${each.value.method} /${each.value.service}/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.service_proxy[each.value.service].id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.azure_jwt.id
}

# Public health route (no JWT) pointing at the gateway BFF instance
resource "aws_apigatewayv2_integration" "gateway_health" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "GET"
  integration_uri        = "http://${aws_instance.service["gateway"].public_ip}:8080/gateway/health"
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "gateway_health" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "GET /gateway/health"
  target    = "integrations/${aws_apigatewayv2_integration.gateway_health.id}"
}

###############################################################################
# Stages: dev and qa
###############################################################################
resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "dev"
  auto_deploy = true  # <- ESTA LÍNEA ES LA CLAVE
}
resource "aws_apigatewayv2_stage" "qa" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "qa"
  auto_deploy = true
  tags        = merge(local.tags, { Environment = "qa" })
}