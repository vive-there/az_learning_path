#!/bin/bash
dotnet build ${HOME}/azure/repos/az_learning_path/aci_console/aci_console.csproj -c Release -r linux-x64 --self-contained true
chmod u+x ${HOME}/azure/repos/az_learning_path/aci_console/bin/Release/net8.0/linux-x64/aci_console
${HOME}/azure/repos/az_learning_path/aci_console/bin/Release/net8.0/linux-x64/aci_console
