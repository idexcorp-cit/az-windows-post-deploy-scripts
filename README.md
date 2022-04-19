# az-windows-post-deploy-scripts
Post deployment scripts for Azure VMs

Use this in combination with the Azure Custom Script extension.
1. Specify the URIs of the raw script files you want to execute along with the run-scripts.ps1 raw URI.
2. Set the `commandToExecute` value to `powershell.exe -ExecutionPolicy Bypass -File run-scripts.ps1`.
3. Each script should be set to log to the $env:TEMP directory with the time executed and script or application name.

Scripts are sorted and run based on name. If a script should run prior to another script, prepend the appropriate number. Example: installing an application on a data disk should happen after disks are initialized.
*NOTE*: Retaining `initialize-disks.ps1` as well as a copy `00-initialize-disks.ps1` to prevent breakage. Use `00-initialize-disks.ps1` going forward.