
using Azure.Identity;
using Azure.Security.KeyVault.Keys;
using Azure.Security.KeyVault.Keys.Cryptography;
using Azure.Storage;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Specialized;

using System.Runtime.CompilerServices;

try
{
    WriteLineToConsole("Start ...", ConsoleColor.Yellow);

    _ = Environment.GetEnvironmentVariable("AZURE_TENANT_ID") ?? throw new NullReferenceException("Provide Azure Tenant Id");
    var storageAccountName = Environment.GetEnvironmentVariable("SA_NAME") ?? throw new NullReferenceException("Provide Azure Storage Account Name"); ;
    var keyVaultName = Environment.GetEnvironmentVariable("KEYVAULT_NAME") ?? throw new NullReferenceException("Provide Azure KeyVault Name");

    var keyName = "sakey";
    var containerName = "test";

    var credentialToken = new DefaultAzureCredential();

    var keyClient = new KeyClient(new Uri($"https://{keyVaultName}.vault.azure.net"), credentialToken);
    var key = await keyClient.GetKeyAsync(keyName);

    var keyResolver = new KeyResolver(credentialToken);
    var cryprographyClient = keyClient.GetCryptographyClient(key.Value.Name, key.Value.Properties.Version);

    var clientSideEncryptionOptions = new ClientSideEncryptionOptions(ClientSideEncryptionVersion.V2_0)
    {
        KeyResolver = keyResolver,
        KeyEncryptionKey = cryprographyClient,
        // Optimal asymmetric encryption padding
        KeyWrapAlgorithm = "RSA-OAEP",
    };

    var blobClientOptions = new SpecializedBlobClientOptions
    {
        ClientSideEncryption = clientSideEncryptionOptions,
    };


    var blobServiceClient = new BlobServiceClient(new Uri($"https://{storageAccountName}.blob.core.windows.net"), credentialToken, blobClientOptions);
    var blobContainerClient = blobServiceClient.GetBlobContainerClient(containerName);
    var blobClient = blobContainerClient.GetBlobClient($"{Guid.NewGuid().ToString("n")}");

    await blobClient.UploadAsync(BinaryData.FromString("test blob"));

    var result = await blobClient.DownloadStreamingAsync();

    WriteLineToConsole("Decoded blob:", ConsoleColor.Yellow);
    WriteLineToConsole(BinaryData.FromStream(result.Value.Content).ToString(), ConsoleColor.Yellow);

    WriteLineToConsole("The end", ConsoleColor.Yellow);
}
catch(Exception e)
{
    WriteLineToConsole(e.Message, ConsoleColor.Red);
}



static void WriteLineToConsole(string text, ConsoleColor foregroundColor)
{
    var defaultForegroundcolor = Console.ForegroundColor;
    Console.ForegroundColor = foregroundColor;
    Console.WriteLine(text);
    Console.ForegroundColor = defaultForegroundcolor;
}

static void WriteToConsole(string text, ConsoleColor foregroundColor)
{
    var defaultForegroundcolor = Console.ForegroundColor;
    Console.ForegroundColor = foregroundColor;
    Console.Write(text);
    Console.ForegroundColor = defaultForegroundcolor;
}