# azd-function-spfx-custom-api

This repository provides an simple, reusable template, to deploy all the resources needed to create a SharePoint SPFx WebPart that consumes an API secured with Entra ID, as docummented in [this article](https://learn.microsoft.com/en-us/sharepoint/dev/spfx/use-aadhttpclient-enterpriseapi).  
It consists of 2 separate projects:
- A simple, yet highly secure, [Azure function](azure-function), configured to require Entra ID authentication
- A [spfx project](spfx-custom-api), that deploys a simple WebPart, that requests an access token to connect to the Azure function
