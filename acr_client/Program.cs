using System.Linq;
using Azure.Core;
using Azure.Core.Pipeline;
using Azure.Containers.ContainerRegistry;
using Azure.Identity;

var environmentRegistryEndpoint=Environment.GetEnvironmentVariable("REGISTRY_ENDPOINT");
Console.WriteLine($"env={environmentRegistryEndpoint}");
if(string.IsNullOrWhiteSpace(environmentRegistryEndpoint))
{
    environmentRegistryEndpoint=args[0];
    Console.WriteLine($"env={environmentRegistryEndpoint}");
}

// Get the service endpoint from the environment
Uri endpoint = new Uri(environmentRegistryEndpoint);

// Create a new ContainerRegistryClient
ContainerRegistryClient client = new ContainerRegistryClient(endpoint, new DefaultAzureCredential(),
    new ContainerRegistryClientOptions()
    {
        Audience = ContainerRegistryAudience.AzureResourceManagerPublicCloud
    });

// Iterate through repositories
Azure.AsyncPageable<string> repositoryNames = client.GetRepositoryNamesAsync();
await foreach (string repositoryName in repositoryNames)
{
    var repository = client.GetRepository(repositoryName);

    // Obtain the images ordered from newest to oldest
    Azure.AsyncPageable<ArtifactManifestProperties> imageManifests =
        repository.GetAllManifestPropertiesAsync(manifestOrder: ArtifactManifestOrder.LastUpdatedOnDescending);

    // Delete all images
    await foreach (ArtifactManifestProperties imageManifest in imageManifests)
    {
        RegistryArtifact image = repository.GetArtifact(imageManifest.Digest);
        Console.WriteLine($"Deleting image with digest {imageManifest.Digest}.");
        Console.WriteLine($"   Deleting the following tags from the image: ");
        foreach (var tagName in imageManifest.Tags)
        {
            Console.WriteLine($"        {imageManifest.RepositoryName}:{tagName}");
            await image.DeleteTagAsync(tagName);
        }
        await image.DeleteAsync();
    }
}
