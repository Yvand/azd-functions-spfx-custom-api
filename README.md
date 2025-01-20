This repository is a simple, reusable template, to deploy all the resources needed to create a SharePoint SPFx WebPart that consumes an API secured with Entra ID.  
In other words, it automates the steps docummented in [this article](https://learn.microsoft.com/en-us/sharepoint/dev/spfx/use-aadhttpclient-enterpriseapi), using 2 projects:

- [azure-function-app](azure-function-app): An Azure function app, configured to require Entra ID authentication
- [spfx-solution](spfx-solution): An SPFx solution with a simple WebPart, that requests an access token to connect to the Azure function app
