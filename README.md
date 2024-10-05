# My Azure Learning Path
``export AZURE_TENANT_ID=${echo $(az account show --query tenantId -o tsv) | tr -d '\n\t\r'}``

## References
1. [HackTricks](https://cloud.hacktricks.xyz/pentesting-cloud/azure-security/az-azuread)
2. https://github.com/Azure/azure-sdk-for-net/tree/main/sdk/resourcemanager/Azure.ResourceManager/samples
3. https://github.com/Azure/azure-sdk-for-net/blob/main/sdk/core/Azure.Core/samples/LongRunningOperations.md
4. https://github.com/Azure/azure-sdk-for-net/blob/main/sdk/containerinstance/Azure.ResourceManager.ContainerInstance/samples/Generated/Samples/Sample_ContainerGroupResource.cs
5. [Steps to resolve “DefaultAzureCredential failed to retrieve a token” error](https://dotnetdevlife.wordpress.com/2022/02/07/steps-to-resolve-defaultazurecredential-failed-to-retrieve-a-token-error/)
