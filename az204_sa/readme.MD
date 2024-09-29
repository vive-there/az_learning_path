- az storage account create --name vivethere0929 -g az204-sa --location eastus --kind StorageV2 --sku Standard_LRS
- az storage account show --name vivethere0929 -g az204-sa
- az storage account show --name vivethere0929 -g az204-sa -o tsv --query id
- az storage account show --name vivethere0929 -g az204-sa -o tsv --query primaryEndpoints.blob
- az storage container create --name test --account-name vivethere0929 --resource-group az204-sa
- az storage container show --name test --account-name vivethere0929
- az storage container list --account-name vivethere0929 -o table
- az storage blob list --container-name test --account-name vivethere0929
- az storage account keys list --account-name vivethere0929 -g az204-sa 
- az storage account keys list --account-name vivethere0929 -g az204-sa --query "[?keyName=='key1'].value" -o tsv
- az storage account show-connection-string --name vivethere0929 -g az204-sa

#### Uploading
1. Upload from file. There are no credentials provided in your command and environment, we will query for account key for your storage account.
   az storage blob upload --account-name vivethere0929 --container-name test --file ./readme.MD
2. Uploading with connection string
