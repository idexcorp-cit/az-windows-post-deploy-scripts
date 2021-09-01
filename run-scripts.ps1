<#
.DESCRIPTION
Run all scripts in a directory minus the current script

.NOTES
Author: Zach Choate

#>

$scripts = Get-ChildItem -Filter "*.ps1" | Where-Object {$_.Name -ne "run-scripts.ps1"}

foreach($script in $scripts) {
    $scriptPath = ".\" + $script.Name
    Try {
        Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File $scriptPath" -Wait
    } Catch {
        Write-Error $_
    }
}