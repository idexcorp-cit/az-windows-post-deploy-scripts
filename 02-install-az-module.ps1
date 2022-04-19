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

# https://evotec.xyz/powershellgallery-you-are-installing-modules-from-an-untrusted-repository/
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

Install-Module Az -AllowClobber -AcceptLicense -Confirm:$false -Repository PSGallery

Set-PSRepository -Name 'PSGallery' -InstallationPolicy Untrusted