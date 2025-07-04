#!/bin/bash

subscription_id="<<INSERT YOUR SUBSCRIPTION ID HERE>>"
az account set --subscription "$subscription_id"

apps=$(az resource list --subscription "$subscription_id" --resource-type "Microsoft.Web/sites" --query "[].{name:name, resourceGroup:resourceGroup}" -o json)

echo "$apps" | jq -c '.[]' | while read app; do
    name=$(echo "$app" | jq -r .name)
    rg=$(echo "$app" | jq -r .resourceGroup)
    
    echo "🔍 App: $name (Resource Group: $rg)"
    
    settings=$(az webapp config appsettings list --name "$name" --resource-group "$rg" --output json)

    echo "$settings" | jq -r '
        .[] 
        | select(
            (.name | ascii_downcase | test("service\\s*bus|queue|topic")) or 
            (.value | ascii_downcase | test("service\\s*bus|queue|topic"))
        ) 
        | "🔹 \(.name): \(.value)"
    '
    
    echo "------------------------------------------------------------"
done
