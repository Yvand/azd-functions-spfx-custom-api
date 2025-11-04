#!/bin/bash

# -e: immediately exit if any command has a non-zero exit status
# -o pipefail: prevents errors in a pipeline from being masked
set -eo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/azd-extensibility#use-environment-variables-with-hooks
# Use the `get-values` azd command to retrieve environment variables from the `.env` file
while IFS='=' read -r key value; do
    value=$(echo "$value" | sed 's/^"//' | sed 's/"$//')
    export "$key=$value"
done <<EOF
$(azd env get-values) 
EOF

if [ -z "$APP_REGISTRATION_CLIENT_ID" ]; then
   echo -e "${RED}Could not get the app registration client ID from azd environment file${NC}"
   exit 1
fi

if [ -z "$AZURE_TENANT_ID" ]; then
   echo -e "${RED}Could not get the Entra ID tenant ID from azd environment file${NC}"
   exit 1
fi

echo -e "\nDeleting app registration $APP_REGISTRATION_CLIENT_ID in subscription ${AZURE_SUBSCRIPTION_ID}..."
az account set --subscription $AZURE_SUBSCRIPTION_ID
az ad app delete --id $APP_REGISTRATION_CLIENT_ID
echo -e "${YELLOW}App registration $APP_REGISTRATION_CLIENT_ID deleted successfully. Make sure to delete it permanently before provisionning this environment again.${NC}"
