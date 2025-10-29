#!/bin/bash

# -e: immediately exit if any command has a non-zero exit status
# -u: immediately exit if using a variable not previously declared
# -o: prevents errors in a pipeline from being masked
set -euo pipefail

# https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/azd-extensibility#use-environment-variables-with-hooks
# Use the `get-values` azd command to retrieve environment variables from the `.env` file
while IFS='=' read -r key value; do
    value=$(echo "$value" | sed 's/^"//' | sed 's/"$//')
    export "$key=$value"
done <<EOF
$(azd env get-values) 
EOF

if [ -z "$APP_REGISTRATION_CLIENT_ID" ]; then
   echo "Could not get the app registration client ID from azd environment file"
   exit 1
fi

if [ -z "$AZURE_TENANT_ID" ]; then
   echo "Could not get the Entra ID tenant ID from azd environment file"
   exit 1
fi

echo "Deleting app registration $APP_REGISTRATION_CLIENT_ID from Entra ID tenant ${AZURE_TENANT_ID}..."
az account set --subscription $AZURE_TENANT_ID
az ad app delete --id $APP_REGISTRATION_CLIENT_ID
echo "App registration $APP_REGISTRATION_CLIENT_ID deleted successfully."
