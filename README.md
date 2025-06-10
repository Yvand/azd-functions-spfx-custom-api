This repository automates the whole process of creating a SharePoint SPFx WebPart that consumes a custom API secured with Entra ID, as described in [this article](https://learn.microsoft.com/en-us/sharepoint/dev/spfx/use-aadhttpclient-enterpriseapi). It contains 2 projects:

- [azure-function-app](azure-function-app): An Azure function app that requires Entra ID authentication, and provides a (very simple) API
- [spfx-solution](spfx-solution): An SPFx solution, with a WebPart that requests an access token for the Azure function app, to consume its API
