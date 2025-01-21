# Azure function app

This project uses Azure Developer command-line (azd) tools to deploy an Azure function app, configured to require Entra ID authentication.  
It deploys a simple HTTP function, uses the [Flex Consumption plan](https://learn.microsoft.com/en-us/azure/azure-functions/flex-consumption-plan) and is written in TypeScript.

## Prerequisites

+ [Node.js 20](https://www.nodejs.org/)
+ [Azure Functions Core Tools](https://learn.microsoft.com/azure/azure-functions/functions-run-local?pivots=programming-language-typescript#install-the-azure-functions-core-tools)
+ [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)

## Permissions required to provision the resources in Azure

The account running `azd` must have at least the following roles to successfully provision the resources:

+ Azure role [`Contributor`](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles/privileged#contributor): To create all the resources needed
+ Azure role [`Role Based Access Control Administrator`](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles/privileged#role-based-access-control-administrator): To assign roles (to access the storage account and Application Insights) to the managed identity of the Azure function app
+ Entra role [`Application Developer`](https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference#application-developer): To create the app registration used to configure the Entra ID authentication in the Azure function app

## Initialize the project

1. Clone the GitHub repository, and create an `azd` environment (in this example, `azd-function-custom-api`):

    ```shell
    git clone https://github.com/Yvand/azd-function-spfx-custom-api.git
    cd azd-function-spfx-custom-api/azure-function-app
    azd env new azd-function-custom-api
    ```

1. Review the file `infra/main.parameters.json` to customize the parameters used for provisioning the resources in Azure. Review [this article](https://learn.microsoft.com/azure/developer/azure-developer-cli/manage-environment-variables) to manage the azd's environment variables.

1. Provision the resources in Azure and deploy the function app package by running command `azd up`.

1. Due to a known issue, follow the steps in ["Entra ID authentication not enabled"](#Entra-ID-authentication-not-enabled) to actually enable the Entra ID authentication in the function app.

## Known issues

### Entra ID authentication not enabled

After the provisioning completed, the Entra ID authentication appears to be enabled, but it is not. To actually enable it, go to function app > Authentication > Edit the Identity provider > Select `Allow requests from any application (Not recommended)` and Save.

### Update the Azure resources

With `azd up` or `azd provision`, you can update the existing function app in Azure, with the changes you made to the Bicep template.

> [!IMPORTANT]
> Before doing this, you have to fully delete the app registration. Then, you can perform the update, and complete the additional steps to update the SPFx configuration.

1. Fully delete the app registration:

   1. Go to the [app registrations](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade/quickStartType~/null/sourceType/Microsoft_AAD_IAM) and delete the application `azd-function-spfx-custom-api`
   1. Then, click on the tab "Deleted applications", and permanently delete the application `azd-function-spfx-custom-api`

1. You can now run `azd up` or `azd provision` to update the existing function app in Azure. It will configure it with a new app registration.  

1. Once the function app was updated, you need to:
   1. Follow the steps in ["Entra ID authentication not enabled"](#Entra-ID-authentication-not-enabled) to actually enable the Entra ID authentication in the function app.
   1. Re-upload the SPFx package (as-is, no change is needed) to the app catalog, and then re-validate the trust in the API access page.
   1. Edit the WebPart properties to update the client ID and the function app key.

### Some features are in preview

- Azure Functions Flex Consumption plan is currently in preview, be aware about its [current limitations and issues](https://learn.microsoft.com/azure/azure-functions/flex-consumption-plan#considerations).
- The Graph resource provider for Bicep is currently [in preview](https://learn.microsoft.com/graph/templates/quickstart-create-bicep-interactive-mode?tabs=CLI).

## Cleanup the resources in Azure

To delete the resources this project created in Azure and Entra ID:

- Either run the command `azd down`, or delete the resource group (which has the azd environment's name by default).
- Manually delete the app registration as explained in ["Update the Azure resources"](#Update-the-Azure-resources).
