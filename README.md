This repository is a simple, reusable template, to deploy all the resources needed to create a SharePoint SPFx WebPart that consumes an API secured with Entra ID.  
In other words, it automates the steps docummented in [this article](https://learn.microsoft.com/en-us/sharepoint/dev/spfx/use-aadhttpclient-enterpriseapi), by providing 2 projects:
- A simple, yet highly secure, [Azure function](azure-function), configured to require Entra ID authentication
- A [spfx project](spfx-custom-api), that deploys a simple WebPart, that requests an access token to connect to the Azure function
