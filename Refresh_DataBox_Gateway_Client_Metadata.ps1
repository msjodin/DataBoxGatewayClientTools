#Initialize the following with your resource group, storage account, container, and blob names
$rgName = "Insert Resource Group Name Here"
$srcContainerName = "Insert Storage Account Archive Container Name Here"
$destContainerName = "Insert Storage Account Cold/Hot Tier Container Name Here"

$subscriptionId = "Insert Subscription ID Here"

$StorageAccountName = "Insert Storage Account Name Here"

####################################conn block

$ServicePrincipalName = "Insert Service Principal Name Here"

$user = 'Insert App Id of Service Principal Here'

$TenantID = 'Insert Tenant ID of Tenant of Service Principal and Subscription Here'

$secpassword = Read-Host -Prompt "Enter the service principal password: "

$DataBoxGateWayName = "Insert DataBox Gateway Name Here"

$ShareFolderToUpdate = "Insert Share to Update Here"

function getBearer([string]$TenantID)
{
  $TokenEndpoint = {https://login.windows.net/{0}/oauth2/token} -f $TenantID 
  $ARMResource = "https://management.core.windows.net/";

  $body = @{
  grant_type = "client_credentials"
  client_id = $user
  client_secret = $secpassword
  resource = "https://management.azure.com/"
    
  }

  $params = @{
      ContentType = 'application/x-www-form-urlencoded'
      Headers = @{'accept'='application/json'}
      Body = $Body
      Method = 'Post'
      URI = $TokenEndpoint
  }

  $token = Invoke-RestMethod @params

  Return "Bearer " + ($token.access_token).ToString()
}


$Bearertoken = getBearer($TenantID)

$h = @{
    authorization = $bearertoken
}

$uri = "https://management.azure.com/subscriptions/" + $subscriptionId + `
"/resourceGroups/" + $rgName + `
"/providers/Microsoft.DataBoxEdge/dataBoxEdgeDevices/" + $DataBoxGateWayName + `
"/shares/" + $ShareFolderToUpdate + `
 "/refresh?api-version=2019-08-01"


$Post = Invoke-WebRequest -Method Post -Uri $uri -Headers $h
