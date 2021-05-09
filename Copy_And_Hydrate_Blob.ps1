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
Connect-AzAccount -Credential $credential -Tenant $TenantID -ServicePrincipal

####################################

$ListToRehydrate = Get-Content "$args"

$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -UseConnectedAccount

$OutputCsvFile = "$pwd\CopyAndHydrateExport.csv"

class Output 
{
    [string]$Blob;
    [string]$Container;
    #Default constructor
    Services()
    {
    }
    #Special constructor will go here

    #Setters
    setBlob([string] $Blob)
    {$this.Blob = $Blob}

    setContainer([string] $Container)
    {$this.Container = $Container}

    [string] setBlob()
    {return $this.Blob}

    [string] setContainer()
    {return $this.Container}
}

#Initialize Variable for output
[Output]$Output = New-Object -TypeName Output


#Clear any old export info
Remove-Item "$OutputCsvFile" -Force

Foreach($entry in $ListToRehydrate)
{
Write-Host $entry
$entry = $entry.Replace('/','\')
#Individual files
IF($entry.Split('\')[-1].contains('.'))
    {
    Write-Host "Condition 1"
    $srcBlobName = $entry
    $destBlobName = $entry
    $CopyJob = Start-AzStorageBlobCopy -SrcContainer $srcContainerName -SrcBlob $srcBlobName -DestContainer $destContainerName -DestBlob $destBlobName -StandardBlobTier Cool -RehydratePriority Standard -Context $ctx -Force

    $Output.setBlob($CopyJob.Name) ; $Output.setContainer($destContainerName)
    $Output | Select-Object -Property Blob, Container | Export-Csv -LiteralPath "$OutputCsvFile" -Append
    }
#Directory handling
ElseIF(($entry -notcontains '.') -and ($entry -ne ""))
    {
    Write-Host "Condition 2"
    $srcBlobName = $entry
    $destBlobName = $entry
    $entry = $entry.Replace('\','/')
    $ArrayOfFiles = Get-AzStorageBlob -Container $srcContainerName -Context $ctx | ?{$_.Name -match $entry}
    foreach($file in $ArrayOfFiles)
        {
         $file = $file.name.replace('/','\')
         $CopyJob = Start-AzStorageBlobCopy -SrcContainer $srcContainerName -SrcBlob $file -DestContainer $destContainerName -DestBlob $file -StandardBlobTier Cool -RehydratePriority Standard -Context $ctx -Force
    
         $Output.setBlob($CopyJob.Name) ; $Output.setContainer($destContainerName)
         $Output | Select-Object -Property Blob, Container | Export-Csv -LiteralPath "$OutputCsvFile" -Append
        }
    }
Else
    {
    Write-Host "Something Weird Happened, possibly an empty line. Entry: $entry"
        }
}
    