# SPFx solution

A minimal SPFx solution, with a simple webpart that requests an access token to connect to the Azure function.

![SPFx version](https://img.shields.io/badge/version-1.20.0-green.svg)

## Prerequisites

+ [Node.js 18](https://www.nodejs.org/)

## Things to know

+ The only hardcoded setting is the Entra ID app registration name, in [`config/package-solution.json`](config/package-solution.json#L38). It is set to `Yvand/azd-function-spfx-custom-api` and it must match the unique name of the app registration in Entra ID. This setting is also reflected in the [`main.parameters.json`](../azure-function/infra/main.parameters.json#L19) of the azd project.

## Minimal Path to Awesome

- Clone this repository
- Ensure that you are at the solution folder
- in the command-line run:
  - **npm install**
  - **gulp serve**

> Include any additional steps as needed.

## Features

Description of the extension that expands upon high-level summary above.

This extension illustrates the following concepts:

- topic 1
- topic 2
- topic 3

> Notice that better pictures and documentation will increase the sample usage and the value you are providing for others. Thanks for your submissions advance.

> Share your web part with others through Microsoft 365 Patterns and Practices program to get visibility and exposure. More details on the community, open-source projects and other activities from http://aka.ms/m365pnp.

## References

- [Getting started with SharePoint Framework](https://docs.microsoft.com/en-us/sharepoint/dev/spfx/set-up-your-developer-tenant)
- [Use Microsoft Graph in your solution](https://docs.microsoft.com/en-us/sharepoint/dev/spfx/web-parts/get-started/using-microsoft-graph-apis)
