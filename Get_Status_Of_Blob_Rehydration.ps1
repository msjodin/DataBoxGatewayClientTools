#Initialize the following with your resource group, storage account, container, and blob names
$rgName = "Insert Resource Group Name Here"
$srcContainerName = "Insert Storage Account Archive Container Name Here"
$destContainerName = "Insert Storage Account Cold/Hot Tier Container Name Here"

$subscriptionId = "Insert Subscription ID Here"

$StorageAccountName = "Insert Storage Account Name Here"

####################################conn block

$ServicePrincipalName = "Insert Service Principal Name Here"

$user = 'Insert Service Principal App Id Here'

$TenantID = 'Tenant Of Applicable Resource and Service Principal Here'

$secpassword = Read-Host -Prompt "Enter the service principal password: " -AsSecureString

# Convert the password to a secure string
#$secPassword = $password | ConvertTo-SecureString -AsPlainText -Force

$credential = [PSCredential]::New($user,$secPassword)

# Connect to Azure
Connect-AzAccount -Credential $credential -Tenant $TenantID -ServicePrincipal | Out-Null

####################################

$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -UseConnectedAccount

$ImportedData = Import-Csv -LiteralPath "$pwd\CopyAndHydrateExport.csv"

Foreach($line in $ImportedData)
    {
    $mything = Get-AzStorageBlob -Blob $line.Blob -Container $line.Container -Context $ctx

    Write-Host ""

    Write-Host "FileName: " $mything.Name

    Write-Host "CopyStatus: " $mything.BlobProperties.CopyStatus

    Write-Host "AccessTier: " $mything.BlobProperties.AccessTier

    }
