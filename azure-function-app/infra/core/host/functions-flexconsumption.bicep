param name string
param location string = resourceGroup().location
param tags object = {}

// Reference Properties
param applicationInsightsName string = ''
param appServicePlanId string
param storageAccountName string
param virtualNetworkSubnetId string = ''
@allowed(['SystemAssigned', 'UserAssigned'])
param identityType string
@description('User assigned identity name')
param identityId string
param httpsOnly bool = true

@allowed(['node'])
param runtimeName string
@allowed(['20'])
param runtimeVersion string
param kind string = 'functionapp,linux'

// Microsoft.Web/sites/config
param appSettings object = {}
param instanceMemoryMB int = 2048
param maximumInstanceCount int = 100

// authsettings
param corsAllowedOrigin string
param authAppClientId string
param authAllowedAudiences string
param sharePointSpfxAppClientId string
// @secure()
// param authClientSecretValue string
var authClientSecretSettingName = 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'

var userAssignedIdentities = identityType == 'UserAssigned'
  ? {
      type: identityType
      userAssignedIdentities: {
        '${identityId}': {}
      }
    }
  : {
      type: identityType
    }

resource stg 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource functions 'Microsoft.Web/sites@2024-04-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  identity: userAssignedIdentities
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: httpsOnly
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobContainer'
          value: '${stg.properties.primaryEndpoints.blob}deploymentpackage'
          authentication: {
            type: identityType == 'SystemAssigned' ? 'SystemAssignedIdentity' : 'UserAssignedIdentity'
            userAssignedIdentityResourceId: identityType == 'UserAssigned' ? identityId : ''
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
    virtualNetworkSubnetId: !empty(virtualNetworkSubnetId) ? virtualNetworkSubnetId : null
    keyVaultReferenceIdentity: identityType == 'UserAssigned' ? identityId : 'SystemAssigned'

    // Base on both links below, properties vnetRouteAllEnabled anbd vnetContentShareEnabled are not needed for flex functions:
    // https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings#flex-consumption-plan-deprecations and https://learn.microsoft.com/en-us/azure/azure-functions/functions-networking-options?tabs=azure-portal#outbound-ip-restrictions
    // But still required for other functions as a workaround to access network-restricted vaults: https://learn.microsoft.com/en-us/azure/app-service/app-service-key-vault-references?tabs=azure-cli#access-network-restricted-vaults
    vnetRouteAllEnabled: true
    vnetContentShareEnabled: true

    siteConfig: {
      keyVaultReferenceIdentity: identityType == 'UserAssigned' ? identityId : 'SystemAssigned'
      linuxFxVersion: null
      vnetRouteAllEnabled: true // see above
      cors: {
        allowedOrigins: [corsAllowedOrigin]
        supportCredentials: true
      }
    }
  }

  resource configAppSettings 'config' = {
    name: 'appsettings'
    properties: union(appSettings, {
      AzureWebJobsStorage__accountName: stg.name
      AzureWebJobsStorage__credential: 'managedidentity'
      APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.properties.ConnectionString
      MICROSOFT_PROVIDER_AUTHENTICATION_SECRET: 'REPLACE_WITH_RESOURCE_APP_SECRET'
      WEBSITE_AUTH_AAD_ALLOWED_TENANTS: tenant().tenantId
    })
  }

  resource authconfig 'config' = {
    name: 'authsettingsV2'
    properties: {
      // platform must be enabled for the authentication to be actually enabled
      // But if enabled, all the identity providers must be enabled, otherwise it causes errors in the Azure portal (cannot retrieve app keys)
      // Yes, there still remains an error in the function app homepage, but it is not blocking
      platform: {
        enabled: true
        runtimeVersion: '~1'
      }
      globalValidation: {
        unauthenticatedClientAction: 'RedirectToLoginPage'
        requireAuthentication: true
        redirectToProvider: 'azureActiveDirectory'
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
              allowedApplications: empty(sharePointSpfxAppClientId)
                ? null
                : [
                    sharePointSpfxAppClientId
                  ]
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

        // Replicate the settings applied by Azure portal when saving changes in the Entra identity provider
        facebook: {
          enabled: true
        }
        gitHub: {
          enabled: true
        }
        google: {
          enabled: true
        }
        legacyMicrosoftAccount: {
          enabled: true
        }
        twitter: {
          enabled: true
        }
      }
      // Replicate the settings applied by Azure portal when saving changes in the Entra identity provider
      login: {
        cookieExpiration: {
          convention: 'FixedTime'
          timeToExpiration: '08:00:00'
        }
        nonce: {
          validateNonce: true
          nonceExpirationInterval: '00:05:00'
        }
        tokenStore: {
          enabled: false
          tokenRefreshExtensionHours: 72
        }
      }
    }
  }

  // resource symbolicname 'functions@2024-04-01' = {
  //   name: 'functions'

  //   resource appkeys 'keys@2024-04-01' = {
  //     name: 'newkey'
  //   }
  // }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = if (!empty(applicationInsightsName)) {
  name: applicationInsightsName
}

output name string = functions.name
output uri string = 'https://${functions.properties.defaultHostName}'
output identityPrincipalId string = identityType == 'SystemAssigned' ? functions.identity.principalId : ''
// output defaultKey string = listkeys(concat(resourceId('Microsoft.Web/sites', functions.name), '/host/default/'), '2024-04-01').functionKeys.default
