# Learning Azure Storage Account

## My commands
- az storage account create --name [SA Name] -g [Resource Group Name] --location eastus --kind StorageV2 --sku Standard_LRS
- az storage account show --name [SA Name] -g [Resource Group Name]
- az storage account show --name [SA Name] -g [Resource Group Name] -o tsv --query id
- az storage account show --name [SA Name] -g [Resource Group Name] -o tsv --query primaryEndpoints.blob
- az storage container create --name test --account-name [SA Name] --resource-group [Resource Group Name]
- az storage container show --name test --account-name [SA Name]
- az storage container list --account-name [SA Name] -o table
- az storage blob list --container-name test --account-name [SA Name]
- az storage account keys list --account-name [SA Name] -g [Resource Group Name] 
- az storage account keys list --account-name [SA Name] -g [Resource Group Name] --query "[?keyName=='key1'].value" -o tsv
- az storage account show-connection-string --name [SA Name] -g [Resource Group Name]
- az storage container metadata show --name [container name] --account-name [sa name] --auth-mode login
- az storage container metadata update --metadata key1=value1 key2=value2  --name [container name] --account-name [sa name] --auth-mode login
- az storage blob tag set --tags key1=val1 key2=value2 key3=val3 --container-name [container name]  --account-name [sa name] --name 'doc/status/README.md'
- az storage account management-policy show --account-name [sa name] -g [rg name]
- az storage account management-policy create --account-name [sa name] -g [rg name] --policy ./test_lifecycle.json
#### Uploading
1. Upload from file. There are no credentials provided in your command and environment, we will query for account key for your storage account.
   az storage blob upload --account-name [SA Name] --container-name test --file ./readme.MD
2. Uploading with connection string


## References
- [Azure CLI Storage Account](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest)