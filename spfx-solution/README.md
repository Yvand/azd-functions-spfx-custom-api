# SPFx solution

A minimal SPFx solution with a simple webpart, that requests an access token to connect to the Azure function app.  
It may be uploaded as-is to the SharePoint app catalog with no modification, since the values that must be edited are exposed as WebPart properties.

![SPFx version](https://img.shields.io/badge/version-1.20.0-green.svg)

## Prerequisites

+ [Node.js 18](https://www.nodejs.org/)

## Things to know

+ The only hardcoded setting is the Entra ID app registration name, in [`config/package-solution.json`](config/package-solution.json#L38). It is set to `azd-function-spfx-custom-api` and it must match the app registration's name in Entra ID. This setting is also reflected in the [`main.parameters.json`](../azure-function-app/infra/main.parameters.json#L19) of the [function app project](../azure-function-app).

## Minimal Path to Awesome

- Clone this repository
- Ensure that you are at the solution folder
- in the command-line run:
  - **npm install**
  - **gulp serve**

> Include any additional steps as needed.

## References

- [Getting started with SharePoint Framework](https://docs.microsoft.com/en-us/sharepoint/dev/spfx/set-up-your-developer-tenant)
- [Consume enterprise APIs secured with Azure AD](https://learn.microsoft.com/en-us/sharepoint/dev/spfx/use-aadhttpclient-enterpriseapi)
