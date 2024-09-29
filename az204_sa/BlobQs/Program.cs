using System;
using System.IO;
using System.Text;

using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;

const string BLOB_CLINET_ENDPOINT = "https://[storage account name].blob.core.windows.net/";

var blobServiceClient = new BlobServiceClient(
    new Uri(BLOB_CLINET_ENDPOINT),
    new DefaultAzureCredential()
);

GetAllContainers(blobServiceClient);

//Create a unique name for the container
string containerName = "quickstartblobs" + Guid.NewGuid().ToString("n");

try
{
    var containerClient = await blobServiceClient.CreateBlobContainerAsync(containerName).ConfigureAwait(false);

    var blobName = $"blob{Guid.NewGuid().ToString("n")}";
    var blobClient = containerClient.Value.GetBlobClient(blobName);

    var data = $"{Guid.NewGuid().ToString("n")}";
    var bytes = Encoding.UTF8.GetBytes(data) ;
    using Stream stream = new MemoryStream(bytes) ;
    await blobClient.UploadAsync(stream);


    await foreach(var blob in containerClient.Value.GetBlobsAsync())
    {
        Console.WriteLine($"{blob.Name} {blob.VersionId}");
        Console.WriteLine($"{nameof(blob.VersionId)} {blob.VersionId}");
        Console.WriteLine($"{nameof(blob.Properties.AccessTier)} {blob.Properties.AccessTier}");
        Console.WriteLine($"{nameof(blob.Properties.TagCount)} {blob.Properties.TagCount}");
        Console.WriteLine($"{nameof(blob.Properties.ETag)} {blob.Properties.ETag}");
        Console.WriteLine($"{nameof(blob.Properties.BlobType)} {blob.Properties.BlobType}");
        Console.WriteLine($"{nameof(blob.Properties.ContentLength)} {blob.Properties.ContentLength}");
        Console.WriteLine($"{nameof(blob.Properties.ContentType)} {blob.Properties.ContentType}");
        Console.WriteLine($"{nameof(blob.Properties.LeaseStatus)} {blob.Properties.LeaseStatus}");
    }

}
catch(Azure.RequestFailedException rfe)
{
    Console.WriteLine($"Creating {containerName} container failed. {rfe.Message}");
    return;
}

//containerClient.Value?.

GetAllContainers(blobServiceClient);



static void GetAllContainers(BlobServiceClient blobServiceClient)
{
    Console.WriteLine("Get list of containers ...");
    var containers = blobServiceClient.GetBlobContainers();
    foreach (var container in containers)
    {
        Console.WriteLine($"Container name ----> {container.Name}");
    }
    Console.WriteLine("End list of containers");
}

