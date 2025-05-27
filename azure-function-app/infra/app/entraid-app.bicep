// targetScope = 'subscription'

extension microsoftGraphV1

// https://github.com/microsoftgraph/msgraph-bicep-types
// az deployment sub create --location francecentral --template-file main.bicep
// https://learn.microsoft.com/en-us/graph/templates/quickstart-create-bicep-interactive-mode?tabs=CLI

param resourceAppName string
param functionAppServiceName string
param UserAssignedManagedIdentityId string = ''

var identifierUri = 'api://${functionAppServiceName}.azurewebsites.net'
var redirectUri = 'https://${functionAppServiceName}.azurewebsites.net/.auth/login/aad/callback'

// https://learn.microsoft.com/en-us/graph/templates/reference/applications?view=graph-bicep-1.0
resource resourceApp 'Microsoft.Graph/applications@v1.0' = {
  displayName: resourceAppName
  uniqueName: resourceAppName
  identifierUris: [identifierUri]

  // Enable user authentication
  signInAudience: 'AzureADMyOrg'
  web: {
    redirectUris: [redirectUri]
    implicitGrantSettings: { enableIdTokenIssuance: true }
  }

  // Expose user_impersonation
  api: {
    oauth2PermissionScopes: [
      {
        adminConsentDescription: 'Allows the app to access ${resourceAppName} on behalf of the signed-in user.'
        adminConsentDisplayName: 'Access ${resourceAppName}'
        id: 'c15bfc6e-9c52-4e6f-97ff-f595ff93b4a5'
        isEnabled: true
        type: 'User'
        userConsentDescription: 'Allow the application to access ${resourceAppName} on your behalf.'
        userConsentDisplayName: 'Access ${resourceAppName}'
        value: 'user_impersonation'
      }
    ]
  }

  // Requires permission to read user profile
  requiredResourceAccess: [
    {
      resourceAppId: '00000003-0000-0000-c000-000000000000'
      resourceAccess: [
        // https://graph.microsoft.com/User.Read
        {
          id: 'e1fe6dd8-ba31-4d61-89e7-88639da4683d'
          type: 'Scope'
        }
      ]
    }
  ]

  resource myMsiFic 'federatedIdentityCredentials@v1.0' = if (!empty(UserAssignedManagedIdentityId)) {
    name: '${resourceApp.uniqueName}/msiAsFic'
    description: 'Trust the workloads UAMI to impersonate the App'
    audiences: [
      'api://AzureADTokenExchange'
    ]
    issuer: '${environment().authentication.loginEndpoint}${tenant().tenantId}/v2.0'
    subject: UserAssignedManagedIdentityId
  }

  // Should not create a secret: https://github.com/microsoftgraph/msgraph-bicep-types/issues/38
  // // Create a client secret
  // passwordCredentials: [
  //   {
  //     displayName: 'generated during Bicep template deployment'
  //   }
  // ]
}

// Create tyhe service principal
resource clientSp 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: resourceApp.appId
}

output resourceAppClientId string = resourceApp.appId
// output resourceAppSecret string = resourceApp.passwordCredentials[0].secretText
output resourceAppIdentifierUri string = resourceApp.identifierUris[0]
