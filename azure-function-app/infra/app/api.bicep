param name string
@description('Primary location for all resources & Flex Consumption Function App')
param location string = resourceGroup().location
param tags object = {}
param applicationInsightsName string = ''
param appServicePlanId string
param appSettings object = {}
param runtimeName string
param runtimeVersion string
param serviceName string = 'api'
param storageAccountName string
param deploymentStorageContainerName string
param virtualNetworkSubnetId string = ''
param instanceMemoryMB int = 2048
param maximumInstanceCount int = 100
param UserAssignedManagedIdentityId string = ''
param UserAssignedManagedIdentityClientId string = ''
param enableBlob bool = true
param enableQueue bool = false
param enableTable bool = false
param enableFile bool = false

// authsettings
param corsAllowedOrigins array = []
param authAppClientId string
param authAllowedAudiences string

@allowed(['SystemAssigned', 'UserAssigned'])
param identityType string

// Starting 2025-03, SPFx gets access tokens as the enterprise app "SharePoint Online Web Client Extensibility"
// https://devblogs.microsoft.com/microsoft365dev/changes-on-sharepoint-framework-spfx-permission-grants-in-microsoft-entra-id/
var sharePointSpfxClientExtensibilityClientId = '08e18876-6177-487e-b8b5-cf950c1e598c'

var applicationInsightsIdentity = identityType == 'UserAssigned'
  ? 'ClientId=${UserAssignedManagedIdentityClientId};Authorization=AAD'
  : 'Authorization=AAD'
var kind = 'functionapp,linux'

// Create base application settings
var baseAppSettings = {
  // Application Insights settings are always included
  APPLICATIONINSIGHTS_AUTHENTICATION_STRING: applicationInsightsIdentity
  //APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.properties.ConnectionString
}

var functionAuthenticationSettings = empty(UserAssignedManagedIdentityId)
  ? {
      MICROSOFT_PROVIDER_AUTHENTICATION_SECRET: 'REPLACE_WITH_RESOURCE_APP_SECRET'
      WEBSITE_AUTH_AAD_ALLOWED_TENANTS: tenant().tenantId
    }
  : {
      OVERRIDE_USE_MI_FIC_ASSERTION_CLIENTID: UserAssignedManagedIdentityClientId
      WEBSITE_AUTH_AAD_ALLOWED_TENANTS: tenant().tenantId
    }

var userManagedIdentityStorageAccountSettings = identityType == 'UserAssigned'
  ? {
      AzureWebJobsStorage__credential: 'managedidentity'
      AzureWebJobsStorage__clientId: UserAssignedManagedIdentityClientId
    }
  : {}

// Dynamically build storage endpoint settings based on feature flags
var blobSettings = enableBlob ? { AzureWebJobsStorage__blobServiceUri: stg.properties.primaryEndpoints.blob } : {}
var queueSettings = enableQueue ? { AzureWebJobsStorage__queueServiceUri: stg.properties.primaryEndpoints.queue } : {}
var tableSettings = enableTable ? { AzureWebJobsStorage__tableServiceUri: stg.properties.primaryEndpoints.table } : {}
var fileSettings = enableFile ? { AzureWebJobsStorage__fileServiceUri: stg.properties.primaryEndpoints.file } : {}

// Merge all app settings
var allAppSettings = union(
  appSettings,
  blobSettings,
  queueSettings,
  tableSettings,
  fileSettings,
  baseAppSettings,
  userManagedIdentityStorageAccountSettings,
  functionAuthenticationSettings
)

var authClientSecretSettingName = empty(UserAssignedManagedIdentityId)
  ? 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
  : 'OVERRIDE_USE_MI_FIC_ASSERTION_CLIENTID'

resource stg 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = if (!empty(applicationInsightsName)) {
  name: applicationInsightsName
}

// Create a Flex Consumption Function App to host the API
module api 'br/public:avm/res/web/site:0.16.0' = {
  name: '${serviceName}-flex-consumption'
  params: {
    kind: kind
    name: name
    location: location
    tags: union(tags, { 'azd-service-name': serviceName })
    serverFarmResourceId: appServicePlanId
    managedIdentities: {
      systemAssigned: identityType == 'SystemAssigned'
      userAssignedResourceIds: identityType == 'SystemAssigned'
        ? null
        : [
            '${UserAssignedManagedIdentityId}'
          ]
    }
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobContainer'
          value: '${stg.properties.primaryEndpoints.blob}${deploymentStorageContainerName}'
          authentication: {
            type: identityType == 'SystemAssigned' ? 'SystemAssignedIdentity' : 'UserAssignedIdentity'
            userAssignedIdentityResourceId: identityType == 'UserAssigned' ? UserAssignedManagedIdentityId : ''
          }
        }
      }
      scaleAndConcurrency: {
        instanceMemoryMB: instanceMemoryMB
        maximumInstanceCount: maximumInstanceCount
      }
      runtime: {
        name: runtimeName
        version: runtimeVersion
      }
    }
    siteConfig: {
      alwaysOn: false
      cors: {
        allowedOrigins: corsAllowedOrigins
        supportCredentials: true
      }
    }
    virtualNetworkSubnetId: !empty(virtualNetworkSubnetId) ? virtualNetworkSubnetId : null

    configs: [
      {
        name: 'appsettings'
        applicationInsightResourceId: applicationInsights.id
        // storageAccountResourceId: stg.id
        // storageAccountUseIdentityAuthentication: true
        properties: allAppSettings
      }
      {
        name: 'authsettingsV2'
        properties: {
          globalValidation: {
            requireAuthentication: true
            unauthenticatedClientAction: 'Return401'
            redirectToProvider: 'azureActiveDirectory'
          }
          platform: {
            enabled: true
            runtimeVersion: '~1'
          }
          httpSettings: {
            requireHttps: true
            routes: {
              apiPrefix: '/.auth'
            }
            forwardProxy: {
              convention: 'NoProxy'
            }
          }
          identityProviders: {
            azureActiveDirectory: {
              enabled: true
              validation: {
                allowedAudiences: [authAllowedAudiences]
                defaultAuthorizationPolicy: {
                  allowedApplications: [sharePointSpfxClientExtensibilityClientId]
                  allowedPrincipals: {
                    identities: null
                  }
                }
                jwtClaimChecks: {}
              }
              login: {
                disableWWWAuthenticate: false
              }
              registration: {
                clientId: authAppClientId
                clientSecretSettingName: authClientSecretSettingName
                openIdIssuer: 'https://sts.windows.net/${tenant().tenantId}/v2.0'
              }
            }
          }
        }
      }
    ]
  }
}

output SERVICE_API_NAME string = api.outputs.name
// Ensure output is always string, handle potential null from module output if SystemAssigned is not used
output SERVICE_API_IDENTITY_PRINCIPAL_ID string = identityType == 'SystemAssigned'
  ? api.outputs.?systemAssignedMIPrincipalId ?? ''
  : ''
