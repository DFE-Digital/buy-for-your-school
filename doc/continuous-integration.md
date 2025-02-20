# Continuous Integration

## Github Actions

Automated deployments are handled by [github actions](https://github.com/DFE-Digital/buy-for-your-school/actions).

### Deployment Secrets

Select secrets are stored in github "Environments". We store as little secrets as possible within github and prefer to rely on permissions within Azure.

|Secret|Description|
|-|-|
|`AZURE_SP_CREDENTIALS`|Service principle credentials stored in JSON form|
|`CONTAINER_APP_NAME`|Name of the container-app|
|`RESOURCE_GROUP_NAME`|Name of the resource group|

For more on service principal credentials, see [here](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Clinux#create-a-service-principal) and [here](https://github.com/marketplace/actions/azure-login#configure-a-service-principal-with-a-secret).
