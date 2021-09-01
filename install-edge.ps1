<#
.DESCRIPTION
Install Microsoft Edge using a generic unattended installation script.

.NOTES
Author: Zach Choate

#>

$appName = "Edge"
$appUrl = 'http://go.microsoft.com/fwlink/?LinkID=2093437'
$installerType = "msi"
$installerArgs = $null
$sha256 = $null

$timestamp = Get-Date -f yyyyMMddHHmmss

$installerFileName = $appName + "." + $installerType
$transcriptPath = "$env:TEMP/$timestamp-install-$appName.log"

Start-Transcript -Path $transcriptPath -Append

# Validate the application isn't already installed.
$uninstall_strings = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -match "$appName" } | Select-Object -Property DisplayName, UninstallString, PSChildName

if(!$uninstall_strings) {

    # Download the installer
    Invoke-RestMethod -Method Get -Uri $appUrl -OutFile "$env:TEMP/$installerFileName" -Wait

    # Make sure the installer downloaded successfully
    if(Test-Path $env:TEMP/$installerFileName) {

        # Validate the Sha256 if it is set
        if(($sha256 -eq $(Get-FileHash -Path "$env:TEMP/$installerFileName").Hash) -or !$sha256) {
            Write-Output "Installer for $appName was downloaded to $env:TEMP/$installerFileName."

            if($installerType = "msi") {

                Write-Output "Install type specified was $installerType. Launching msiexec to run the installation."
                Try{
                    Start-Process msiexec -ArgumentList "/i $env:TEMP/$installerFileName /qn" -Wait
                    Write-Output "Installer completed."
                } Catch {
                    Write-Output "Something went wrong. Error message below:"
                    Write-Output $_
                    Exit 1
                }

            } elseif ($installerType = "exe") {
                Write-Output "Install type specified was $installerType. Launching $installerFileName to run the installation."
                Try {
                    Start-Process "$env:TEMP/$installerFileName" -ArgumentList $installerArgs -Wait
                    Write-Output "Installer completed."
                } Catch {
                    Write-Output "Something went wrong. Error message below:"
                    Write-Output $_
                    Exit 1
                }

            }
        } else {
            Write-Output "Sha256 hash of the downloaded installer did not match what was specified. The installation is aborted."
            Exit 1
        }
    } else {
        Write-Output "The installer doesn't look like it downloaded successfully."
        Exit 1
    }

} else {
    Write-Output "$appName looks like it may already be installed. Look at $uninstall_strings"
    Exit 0
}

Exit 0