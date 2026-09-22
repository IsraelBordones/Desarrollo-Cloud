/**
 * Production environment.
 * These values are produced by Terraform (Azure App Registration + AWS API
 * Gateway invoke URL) and injected at build/deploy time.
 */
export const environment = {
  production: true,
  azure: {
    tenantId: '97075989-a3d5-43e2-bd08-0b6e5c89e96e',
    clientId: 'd61a9b9d-fed9-4860-9174-0fdcef50b740',
    redirectUri: 'http://localhost:4200', 
    postLogoutRedirectUri: 'http://localhost:4200',
    apiScopes: ['api://pedidos360-api/Pedidos.Read', 'api://pedidos360-api/Pedidos.Write']
  },
  // Tu API Gateway exacto (nota que ya incluye el /dev al final)
  apiGatewayUrl: 'https://aj90cxbv9h.execute-api.us-east-1.amazonaws.com/dev'
};
