output "tenant_id" {
  description = "Azure AD tenant ID"
  value       = var.tenant_id
}

output "client_id" {
  description = "Application (client) ID for the Angular SPA and API audience"
  value       = azuread_application.pedidos360.client_id
}

output "authority" {
  description = "OIDC authority URL"
  value       = "https://login.microsoftonline.com/${var.tenant_id}"
}

output "issuer_uri" {
  description = "JWT issuer (v2.0) validated by API Gateway and Spring Boot"
  value       = "https://login.microsoftonline.com/${var.tenant_id}/v2.0"
}

output "api_audience" {
  description = "Expected audience (aud) claim"
  value       = "api://${var.api_identifier}"
}

output "api_scopes" {
  description = "OAuth2 scopes exposed by the API"
  value = [
    "api://${var.api_identifier}/Pedidos.Read",
    "api://${var.api_identifier}/Pedidos.Write"
  ]
}

output "jwks_uri" {
  description = "JWKS endpoint used to validate token signatures"
  value       = "https://login.microsoftonline.com/${var.tenant_id}/discovery/v2.0/keys"
}
