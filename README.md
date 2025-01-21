This repository automates the whole process of creating a SharePoint SPFx WebPart that consumes a custom API secured with Entra ID, as described in [this article](https://learn.microsoft.com/en-us/sharepoint/dev/spfx/use-aadhttpclient-enterpriseapi).  
To achieve this, it contains 2 projects:

- [azure-function-app](azure-function-app): An Azure function app, configured to require Entra ID authentication
- [spfx-solution](spfx-solution): An SPFx solution with a simple WebPart, that requests an access token to connect to the Azure function app
