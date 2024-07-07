# Get all role definitions
 az role definition list --query "[].{Role:roleName, Id:id}" -o table

# Get role definition by roleName
az role definition list --query "[?roleName == 'Key Vault Secrets Officer'].{Id:id, Name:name, Role:roleName}"