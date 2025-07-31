# Azure function app

This project uses Azure Developer command-line (azd) tools to deploy an Azure function app, configured to require Entra ID authentication.  
It deploys a simple HTTP function, uses the [Flex Consumption plan](https://learn.microsoft.com/en-us/azure/azure-functions/flex-consumption-plan) and is written in TypeScript.

## Prerequisites

+ [Node.js 22](https://www.nodejs.org/)
+ [Azure Functions Core Tools](https://learn.microsoft.com/azure/azure-functions/functions-run-local?pivots=programming-language-typescript#install-the-azure-functions-core-tools)
+ [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)

## Permissions required to provision the resources in Azure and Entra ID

The account running `azd` must have at least the following roles to successfully provision the resources:

+ Azure role [`Contributor`](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles/privileged#contributor): To create all the resources needed
+ Azure role [`Role Based Access Control Administrator`](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles/privileged#role-based-access-control-administrator): To assign roles (to access the storage account and Application Insights) to the managed identity of the Azure function app
+ Entra role [`Application Developer`](https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference#application-developer): To create the app registration used to configure the Entra ID authentication in the Azure function app

## How-to use this project

1. Clone the GitHub repository, and create an `azd` environment (in this example, `azd-function-custom-api`):

    ```shell
    git clone --depth 1 https://github.com/Yvand/azd-functions-spfx-custom-api.git
    cd azd-functions-spfx-custom-api/azure-function-app
    azd env new azd-function-custom-api
    ```

1. Review the file `infra/main.parameters.json` to customize the parameters used for provisioning the resources in Azure. Review [this article](https://learn.microsoft.com/azure/developer/azure-developer-cli/manage-environment-variables) to manage the azd's environment variables.

1. Provision the resources in Azure and deploy the function app package by running command `azd up`.

> [!WARNING]
> Deploying the package to Azure might fail with this error:
> `ERROR: error executing step command 'deploy --all': failed deploying service 'api': publishing zip file: deployment failed`
> If so, it may be deployed using func cli instead:
> `func azure functionapp publish <func-api-YOUR_FUNC_APP_NAME>`

## Known issues

### Deleting the Azure resources

Running the command `azd down`, or deleting the resource group, deletes all the resources in Azure, but it does not delete the app registration in Entra ID.  
Follow the steps below to fully delete it:

1. Go to the [app registrations](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade/quickStartType~/null/sourceType/Microsoft_AAD_IAM) and delete the application `azd-functions-spfx-custom-api`.
1. Then, click on the tab "Deleted applications", and permanently delete the application `azd-functions-spfx-custom-api`.

> [!WARNING]
> You won't be able to successfully re-provision the resources in Azure until you permanently deleted the app registration as explained above.

### Features in preview

- Azure Functions Flex Consumption plan is currently in preview, be aware about its [current limitations and issues](https://learn.microsoft.com/azure/azure-functions/flex-consumption-plan#considerations).
- The Graph resource provider for Bicep is currently [in preview](https://learn.microsoft.com/graph/templates/quickstart-create-bicep-interactive-mode?tabs=CLI).
