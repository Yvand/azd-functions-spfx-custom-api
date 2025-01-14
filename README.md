# azd-function-spfx-custom-api

This repository allows developers to easily consume an API secured with Entra ID, as docummented in [this article](https://learn.microsoft.com/en-us/sharepoint/dev/spfx/use-aadhttpclient-enterpriseapi), by deploying:
- A [simple Azure function](azure-function), configured to require Entra ID authentication
- A [simple spfx webpart](spfx-custom-api), that requests a delegated access token to connect to the Azure function
