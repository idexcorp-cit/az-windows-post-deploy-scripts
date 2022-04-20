<#
.DESCRIPTION
Download SHIR, access key vault secret using VM system identity, and install SHIR.

.NOTES
Author: Zach Choate

#>

$appName = "Integration Runtime"
$appUrl = 'http://go.microsoft.com/fwlink/?LinkID=839822'
$installerType = "msi"
$shirInstallScript = "https://raw.githubusercontent.com/Azure/Azure-DataFactory/main/SamplesV2/SelfHostedIntegrationRuntime/AutomationScripts/InstallGatewayOnLocalMachine.ps1"
$shirScriptName = "InstallGatewayOnLocalMachine.ps1"
$shirScriptPath = $env:TEMP + "\" + $shirScriptName

$timestamp = Get-Date -f yyyyMMddHHmmss

$installerFileName = $appName + "." + $installerType
$installerPath = $env:TEMP + "\" + $installerFileName
$transcriptPath = "$env:TEMP\$timestamp-install-$appName.log"

Start-Transcript -Path $transcriptPath -Append

# Get the resource group of the VM, the key vault should be located in the same resource group
$metadata = (Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01").compute
$resourceGroup = $metadata.resourceGroupName
$subscriptionId = $metadata.subscriptionId

# Connect to Az to get KV secret
Connect-AzAccount -Identity

# Get vault name
$vaultName = (Get-AzKeyVault -ResourceGroupName $resourceGroup -SubscriptionId $subscriptionId).vaultName

# Get Key Vault Secret
$shirKey = Get-AzKeyVaultSecret -VaultName $vaultName -AsPlainText -Name "shir-auth-key"

# Download the installer
Invoke-RestMethod -Method GET -Uri $appUrl -OutFile "$installerPath"

# Download SHIR installer script
Invoke-RestMethod -Method GET -Uri $shirInstallScript -OutFile $shirScriptPath

# Make sure the installer downloaded successfully
if((Test-Path $installerPath) -and (Test-Path $shirScriptPath)) {
    Try {
        Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File $shirScriptPath -path $installerPath -authKey $shirKey" -Wait
    } Catch {
        Write-Error $_
    }
} else {
    Write-Output "The installer doesn't look like it downloaded successfully."
    Exit 1
}