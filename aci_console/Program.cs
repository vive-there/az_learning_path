using Azure.Core;
using Microsoft.Extensions.Configuration;
using Azure.ResourceManager.Models;
using System.Reflection;
using Azure.ResourceManager.ContainerInstance.Models;


namespace aci_console
{
    internal class Program
    {
        private const string ResourceGroupName = "sdktest106_rg";
        private const string ContainerName = "aci-helloworld";
        static IConfigurationRoot _configuration;
        static ArmClient _armClient;
        static ResourceGroupResource _resourceGroup;
        static readonly AzureLocation _location = AzureLocation.EastUS;
        static async Task Main(string[] args)
        {
            _configuration = BuildConfiguration();

            _armClient = new ArmClient(new DefaultAzureCredential(
                new DefaultAzureCredentialOptions
                {
                    TenantId = _configuration.GetValue<string>("Azure:TenantId")
                }
             ));

            var subscription = await _armClient.GetDefaultSubscriptionAsync().ConfigureAwait(false);
            var resourceGroup = await GetOrCreateResourceGroupAsync(subscription, ResourceGroupName).ConfigureAwait(false);
            
            var containerInstanceCollection = resourceGroup.GetContainerGroups();
            var containerGroup = await CreateContainerGroupAsync(containerInstanceCollection, "aci_sdktest").ConfigureAwait(false);

            var logs = await containerGroup.GetContainerLogsAsync(ContainerName).ConfigureAwait(false);
            if (logs != null) 
            {
                Console.WriteLine(logs.Value?.Content);
            }

            var attachResult = await containerGroup.AttachContainerAsync(ContainerName).ConfigureAwait(false);
            Console.WriteLine($"{attachResult.Value.WebSocketUri} {attachResult.Value.Password}");
        }

        private static async Task<ResourceGroupResource> GetOrCreateResourceGroupAsync(SubscriptionResource subscription, string resourceGroupName)
        {
            var resourceGroupCollection = subscription.GetResourceGroups();
            var resourceGroup = await resourceGroupCollection.GetIfExistsAsync(resourceGroupName);
            if (resourceGroup.HasValue)
            {
                Console.WriteLine($"Resource group '{resourceGroupName}' exists");
                return resourceGroup.Value;
            }

            Console.WriteLine($"Resource group '{resourceGroupName}' does not exist.");
            Console.WriteLine($"Creating resource group '{resourceGroupName}'...");
            
            ArmOperation<ResourceGroupResource> armOperation = await resourceGroupCollection
                .CreateOrUpdateAsync(Azure.WaitUntil.Completed, resourceGroupName, new ResourceGroupData(_location)).ConfigureAwait(false);
            if (armOperation.HasValue)
            {
                return armOperation.Value;
            }

            var rawResponse = armOperation.GetRawResponse();
            Console.WriteLine($"Failed creating resource group '{resourceGroupName}' {rawResponse?.Status}.");
            throw new Exception($"Could not create RG {resourceGroupName}");
        }

        private static async Task<ResourceGroupResource> GetResourceGroupAsync(SubscriptionResource subscription, string resourceGroupName)
        {
            var resourceGroupCollection = subscription.GetResourceGroups();
            var sdkTestGroup = resourceGroupCollection.GetIfExistsAsync(resourceGroupName);
            if (sdkTestGroup.Result.HasValue)
            {
                Console.WriteLine($"Resource group '{resourceGroupName}' exists");

                var resourceGroup = sdkTestGroup.Result.Value;
                Console.WriteLine($"ID {resourceGroup.Data.Id}");
                Console.WriteLine($"NAME {resourceGroup.Data.Name}");
                Console.WriteLine($"LOCATION {resourceGroup.Data.Location}");
                Console.WriteLine($"PROVISIONING STATE {resourceGroup.Data.ResourceGroupProvisioningState}");
                Console.WriteLine($"TAGS");
                var tagResource = resourceGroup
                    .GetTagResource();
                var tagResourceResponse = await tagResource.GetAsync();
                foreach (var tag in tagResourceResponse.Value.Data.TagValues)
                {
                    Console.WriteLine($"\t{tag.Key}=\"{tag.Value}\"");
                }
                return resourceGroup;
            }

            Console.WriteLine($"Resource group '{resourceGroupName}' does not exist.");
            Console.WriteLine($"Creating resource grorup '{resourceGroupName}'...");


            var data = new ResourceGroupData(_location);

            ArmOperation<ResourceGroupResource> armOperation = await resourceGroupCollection.CreateOrUpdateAsync(Azure.WaitUntil.Completed, resourceGroupName, data).ConfigureAwait(false);
            if (armOperation.HasValue)
            {
                var resourceGroup = armOperation.Value;
                await resourceGroup.SetTagsAsync(new Dictionary<string, string> {
                    { "env","learning"},
                    { "from","azure sdk"}
                }).ConfigureAwait(false);

                Console.WriteLine($"Created resource group '{resourceGroupName}'.");
                Console.WriteLine($"ID {resourceGroup.Data.Id}");
                Console.WriteLine($"NAME {resourceGroup.Data.Name}");
                Console.WriteLine($"LOCATION {resourceGroup.Data.Location}");
                Console.WriteLine($"PROVISIONING STATE {resourceGroup.Data.ResourceGroupProvisioningState}");
                Console.WriteLine($"TAGS");
                var tagResource = resourceGroup
                    .GetTagResource();
                var tagResourceResponse = await tagResource.GetAsync();
                foreach (var tag in tagResourceResponse.Value.Data.TagValues)
                {
                    Console.WriteLine($"\t{tag.Key}=\"{tag.Value}\"");
                }

                return resourceGroup;
            }

            var rawResponse = armOperation.GetRawResponse();
            Console.WriteLine($"Failed creating resource group '{resourceGroupName}' {rawResponse?.Status}.");
            throw new Exception($"Could not create RG {resourceGroupName}");
        }

        private static IConfigurationRoot BuildConfiguration()
        {
            var configBuilder = new ConfigurationBuilder();
            configBuilder.SetBasePath(Directory.GetCurrentDirectory());
            configBuilder
                .AddJsonFile("appsettings.json", true)
                .AddUserSecrets(Assembly.GetExecutingAssembly(), true)
                .AddEnvironmentVariables();
            return configBuilder.Build();
        }

        private static async Task<ContainerGroupResource> CreateContainerGroupAsync(ContainerGroupCollection containerInstanceCollection, string containerGroupName)
        {
            Console.WriteLine($"Creating container {containerGroupName} ...");
            ContainerGroupData data = new ContainerGroupData(
                _location,
                new ContainerInstanceContainer[] { 
                    //Container #1
                    new ContainerInstanceContainer(
                        ContainerName
                        ,
                        "mcr.microsoft.com/azuredocs/aci-helloworld",
                        new ContainerResourceRequirements(new ContainerResourceRequestsContent(memoryInGB: 1.5, cpu: 1))
                    )
                    {
                        Ports =
                        {
                            new ContainerPort(80){ Protocol = ContainerNetworkProtocol.Tcp }
                        }
                    }
                },
                ContainerInstanceOperatingSystemType.Linux)
            { 
                IPAddress = new ContainerGroupIPAddress(new[] { new ContainerGroupPort(80) }, ContainerGroupIPAddressType.Public)
                {
                    DnsNameLabel = "vt100helloworld100",
                    AutoGeneratedDomainNameLabelScope = DnsNameLabelReusePolicy.Unsecure,
                },
            };

            var operationResponse = await containerInstanceCollection.CreateOrUpdateAsync(Azure.WaitUntil.Completed, containerGroupName, data).ConfigureAwait(false);

            Console.WriteLine($"Container {containerGroupName} state {operationResponse.Value.Data.ProvisioningState}");
            Console.WriteLine($"FQDN {operationResponse.Value.Data.IPAddress.Fqdn}");

            return operationResponse.Value;
        }
    }
}
