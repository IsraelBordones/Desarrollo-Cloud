###############################################################################
# Pedidos360 - Azure AD (Microsoft Entra ID) - App Registration (IDaaS)
#
# Creates the Entra ID application used by the Angular SPA (MSAL) and the API
# audience validated by AWS API Gateway and the Spring Boot resource servers.
###############################################################################

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azuread" {
  # Uses az CLI / environment credentials of the signed-in tenant.
  tenant_id = var.tenant_id
}

data "azuread_client_config" "current" {}

# Stable UUIDs for the exposed OAuth2 scopes and app roles.
resource "random_uuid" "scope_read" {}
resource "random_uuid" "scope_write" {}
resource "random_uuid" "role_admin" {}
resource "random_uuid" "role_user" {}

###############################################################################
# Application registration
###############################################################################
resource "azuread_application" "pedidos360" {
  display_name     = var.app_display_name
  sign_in_audience = "AzureADMyOrg"

  # Identifier URI => token audience (api://pedidos360-api)
  identifier_uris = ["api://${var.api_identifier}"]

  # SPA platform (MSAL Angular uses the authorization code flow with PKCE)
  single_page_application {
    redirect_uris = var.redirect_uris
  }

  # Microsoft Graph delegated permissions (User.Read + openid/profile/email)
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e" # openid
      type = "Scope"
    }
    resource_access {
      id   = "14dad69e-099b-42c9-810b-d002981feec1" # profile
      type = "Scope"
    }
    resource_access {
      id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0" # email
      type = "Scope"
    }
  }

  # Exposed API: OAuth2 permission scopes consumed by the SPA
  api {
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Permite leer pedidos en nombre del usuario"
      admin_consent_display_name = "Leer pedidos"
      user_consent_description   = "Permite leer tus pedidos"
      user_consent_display_name  = "Leer pedidos"
      enabled                    = true
      id                         = random_uuid.scope_read.result
      type                       = "User"
      value                      = "Pedidos.Read"
    }

    oauth2_permission_scope {
      admin_consent_description  = "Permite crear y modificar pedidos en nombre del usuario"
      admin_consent_display_name = "Escribir pedidos"
      user_consent_description   = "Permite crear y modificar tus pedidos"
      user_consent_display_name  = "Escribir pedidos"
      enabled                    = true
      id                         = random_uuid.scope_write.result
      type                       = "User"
      value                      = "Pedidos.Write"
    }
  }

  # Application roles surfaced in the "roles" claim of the token
  app_role {
    allowed_member_types = ["User"]
    description          = "Administradores con acceso total"
    display_name         = "Admin"
    enabled              = true
    id                   = random_uuid.role_admin.result
    value                = "Admin"
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Usuarios estándar del sistema"
    display_name         = "User"
    enabled              = true
    id                   = random_uuid.role_user.result
    value                = "User"
  }
}

###############################################################################
# Service principal (enterprise application)
###############################################################################
resource "azuread_service_principal" "pedidos360" {
  client_id                    = azuread_application.pedidos360.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

# Optional client secret (useful for confidential/daemon testing, not for SPA)
resource "azuread_application_password" "pedidos360" {
  count          = var.create_client_secret ? 1 : 0
  application_id = azuread_application.pedidos360.id
  display_name   = "pedidos360-terraform-secret"
  end_date       = var.client_secret_end_date
}
