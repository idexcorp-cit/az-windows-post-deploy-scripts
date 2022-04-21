<#

.DESCRIPTION
- Install Az modules
- Required for install-adf-shir.ps1

.NOTES
Author: Zachary Choate

#>

$timestamp = Get-Date -f yyyyMMddHHmmss

$transcriptPath = "$env:TEMP/$timestamp-az-module.log"

Start-Transcript -Path $transcriptPath -Append

$moduleInstalled = Get-InstalledModule -Name Az -ErrorAction SilentlyContinue

if( -not $moduleInstalled) {

    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

    # https://evotec.xyz/powershellgallery-you-are-installing-modules-from-an-untrusted-repository/
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

    Install-Module Az -AllowClobber -Confirm:$false -Repository PSGallery

    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Untrusted

}

Exit 0