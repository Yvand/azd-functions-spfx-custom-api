# Azure flex function

This project uses Azure Developer command-line (azd) tools to automatically deploy the resources needed on Azure, so support the scenario.

## Overview

At a high-level, the following resources are deployed:

- A simple Azure function app, using the [Flex Consumption plan](https://learn.microsoft.com/en-us/azure/azure-functions/flex-consumption-plan), that provides an HTTP endpoint to return dummy JSON data
- An app registration in Entra ID, to enable the authentication in the Azure function app

## Prerequisites

+ [Node.js 20](https://www.nodejs.org/)
+ [Azure Functions Core Tools](https://learn.microsoft.com/azure/azure-functions/functions-run-local?pivots=programming-language-typescript#install-the-azure-functions-core-tools)
+ [Azure Developer CLI (AZD)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
+ Have the built-in role `Owner`, or `Contributor` + [`Role Based Access Control Administrator`](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/privileged#role-based-access-control-administrator), to successfully assign roles to the managed identity, as part of the provisioning process
+ To use Visual Studio Code to run and debug locally:
  + [Visual Studio Code](https://code.visualstudio.com/)
  + [Azure Functions extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions)

## Known issues

- Azure Functions Flex Consumption plan is currently in preview, be aware about its [current limitations and issues](https://learn.microsoft.com/en-us/azure/azure-functions/flex-consumption-plan#considerations).
- The Graph resource provider for Bicep is currently [in preview](https://learn.microsoft.com/en-us/graph/templates/quickstart-create-bicep-interactive-mode?tabs=CLI)

## Initialize the local project

You can initialize a project from this `azd` template in one of these ways:

+ Use this `azd init` command from an empty local (root) folder:

    ```shell
    azd init --template Yvand/functions-quickstart-spo-azd
    ```

    Supply an environment name, such as `spofuncs-quickstart` when prompted. In `azd`, the environment is used to maintain a unique deployment context for your app.

+ Clone the GitHub template repository, and create an `azd` environment (in this example, `spofuncs-quickstart`):

    ```shell
    git clone https://github.com/Yvand/functions-quickstart-spo-azd.git
    cd functions-quickstart-spo-azd
    azd env new spofuncs-quickstart
    ```

## Prepare your local environment

1. Review the file `infra/main.parameters.json` to customize the parameters used for provisioning the resources in Azure. Review [this article](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/manage-environment-variables) to manage the azd's environment variables.

   Important: Ensure the values for `TenantPrefix` and `SiteRelativePath` are identical between the files `local.settings.json` (used when running the functions locally) and `infra\main.parameters.json` (used to set the environment variables in Azure).

1. Install the dependencies and build the functions app:

   ```shell
   npm install
   npm run build
   ```

1. Provision the resources in Azure and deploy the functions app package by running command `azd up`.

## Cleanup the resources in Azure

You can delete all the resources this project created in Azure, by running the command `azd down`.  
Alternatively, you can delete the resource group, which has the azd environment's name by default.
