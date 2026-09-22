variable "tenant_id" {
  description = "Azure AD (Entra ID) tenant ID"
  type        = string
}

variable "app_display_name" {
  description = "Display name of the App Registration"
  type        = string
  default     = "Pedidos360"
}

variable "api_identifier" {
  description = "API identifier used as token audience (api://<identifier>)"
  type        = string
  default     = "pedidos360-api"
}

variable "redirect_uris" {
  description = "SPA redirect URIs (local + CloudFront)"
  type        = list(string)
  default = [
    "http://localhost:4200",
    "https://REPLACE_WITH_CLOUDFRONT_DOMAIN"
  ]
}

variable "create_client_secret" {
  description = "Whether to create a client secret (not required for SPA)"
  type        = bool
  default     = false
}

variable "client_secret_end_date" {
  description = "Expiry for the optional client secret"
  type        = string
  default     = "2026-12-31T00:00:00Z"
}
