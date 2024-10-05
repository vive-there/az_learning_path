using Azure;
using Azure.Core;
using Azure.Identity;
using Azure.Security.KeyVault.Keys;
using Azure.Security.KeyVault.Keys.Cryptography;
using Azure.Storage;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Blobs.Specialized;

using System.Net;
using System.Text;

var keyName = "sakey1";
var keyVaultName = Environment.GetEnvironmentVariable("KEY_VAULT_NAME");
var keyVaultUrl = $"https://{keyVaultName}.vault.azure.net";

TokenCredential tokenCredential = new DefaultAzureCredential();

var keyClient = new KeyClient(new Uri(keyVaultUrl), tokenCredential);

Response<KeyVaultKey> key;

try
{
    key = await keyClient.GetKeyAsync(keyName);
}
catch(RequestFailedException rfe) when (rfe.Status == (int)HttpStatusCode.NotFound)
{
    key = await keyClient.CreateKeyAsync(keyName, KeyType.Rsa);
}
catch
{
    // log
    throw;
}

// Cryptography client and key resolver instances using Azure Key Vault client library
CryptographyClient cryptoClient = keyClient.GetCryptographyClient(key.Value.Name, key.Value.Properties.Version);
KeyResolver keyResolver = new KeyResolver(tokenCredential);

//For existing key in keyvault
//var keyVaultKeyUri = $"https://{keyVaultName}.vault.azure.net/keys/{keyName}";
//CryptographyClient cryptoClient = new CryptographyClient(new Uri(keyVaultKeyUri), tokenCredential);


ClientSideEncryptionOptions clientSideEncryptionOptions = new ClientSideEncryptionOptions(ClientSideEncryptionVersion.V2_0) 
{ 
    KeyEncryptionKey = cryptoClient,
    KeyResolver = keyResolver,
    // String value that the client library will use when calling IKeyEncryptionKey.WrapKey()
    KeyWrapAlgorithm = "RSA-OAEP"
};

var blobClientOptions = new SpecializedBlobClientOptions 
{
    ClientSideEncryption = clientSideEncryptionOptions,
};

var accountName = Environment.GetEnvironmentVariable("SA_NAME");
var blobServiceClient = new BlobServiceClient(new Uri($"https://{accountName}.blob.core.windows.net"), tokenCredential, blobClientOptions);
var blobContainerClient = blobServiceClient.GetBlobContainerClient("test");
var blobClient = blobContainerClient.GetBlobClient($"{Guid.NewGuid().ToString("n")}");

var bytes = Encoding.UTF8.GetBytes("Bla bla bla KeyEncryptionKey = cryptoClient");
using var stream = new MemoryStream(bytes);
await blobClient.UploadAsync(stream);

Console.WriteLine("Uploaded");
Console.WriteLine("Downloading ...");

var downloadedResult = await blobClient.DownloadStreamingAsync();

Console.WriteLine(await BinaryData.FromStreamAsync(downloadedResult.Value.Content));







