# SPFx solution

A minimal SPFx solution with a simple webpart, that requests an access token to connect to the Azure function app.  
It may be used as-is with no modification, since the values that must be edited are exposed as WebPart properties.

![SPFx version](https://img.shields.io/badge/version-1.21.1-green.svg)

## Prerequisites

+ [Node.js 22](https://www.nodejs.org/)

## How-to use the project

> [!IMPORTANT]
> The only hardcoded setting is the Entra ID app registration name, in [`config/package-solution.json`](config/package-solution.json#L38). It is set to `azd-function-spfx-custom-api` and it must match the app registration's name in Entra ID. This setting is also reflected in the [`main.parameters.json`](../azure-function-app/infra/main.parameters.json#L19) of the [function app project](../azure-function-app).

1. Clone the GitHub repository and change to the the SPFx solution folder:

   ```shell
   git clone https://github.com/Yvand/azd-function-spfx-custom-api.git
   cd azd-function-spfx-custom-api/spfx-solution
   ```

1. Build the project and package the solution:

   ```shell
   npm install
   gulp bundle
   gulp package-solution --production
   ```

1. Upload the SPFx solution `azd-function-custom-api.sppkg` to the SharePoint app catalog and enable it.

1. Go to the API access page and approve the request for `azd-function-spfx-custom-api`.

1. Add the webpart `CustomAPI` to a page, edit its properties and publish the page.
