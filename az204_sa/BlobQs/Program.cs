using System;
using System.IO;
using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;

const string BLOB_CLINET_ENDPOINT = "https://vivethere18944.blob.core.windows.net/";

var blobServiceClient = new BlobServiceClient(
    new Uri(BLOB_CLINET_ENDPOINT),
    new DefaultAzureCredential()
);



