<#
.DESCRIPTION
Move CD Rom to end of alphabet for drive letter, initialize raw disks and assign drive letters starting with E
This script is not designed to handle more few disks being attached. The hard limit that this script will work with is 19 - any more and it will error out.

.NOTES
Author: Zach Choate

#>

$timestamp = Get-Date -f yyyyMMddHHmmss

$transcriptPath = "$env:TEMP/$timestamp-initialize-disks.log"

Start-Transcript -Path $transcriptPath -Append

# Get uninitialized disks
$rawDisks = Get-Disk | Where-Object {$_.PartitionStyle -eq 'RAW'}

# Move any CD drives to the end of the alphabet
$cdDrive = Get-CimInstance -ClassName Win32_Volume | Where-Object {$_.DriveType -eq 5}
if($cdDrive) {
    $cdDrive[0] | Set-CimInstance -Property @{DriveLetter="Z:"}
    Write-Output "Moved CD Drive to Z."
}

# Set counter to 0
$i = 0

# For each raw disk, add 1 to the counter, then initialize the disk, then add a new volume with drive letter starting at E
foreach($rawDisk in $rawDisks) {
    $i++

    # Validate the drive letter isn't already taken, if it is increment $i by 1 until we hit a letter that isn't taken
    while (Get-CimInstance -ClassName Win32_Volume | Where-Object {$_.DriveLetter -eq "$([char](69 + $i)):"}) {
        $i++
    }

    # Let's make sure the drive letter is still a letter in the valid range of letters, excluding Z since there's a chance the CD drive moved to Z. 
    if($i -ge 20) {
        Write-Output "There's more disks than drive letters. Exiting..."
        Exit 1
    }

    Try {
        Initialize-Disk -Number $rawDisk.Number -PassThru | 
            New-Volume -FileSystem NTFS -DriveLetter $([char](69 + $i)) -FriendlyName $('data' + $i)
    } Catch {
        Write-Output "Something went wrong. Here's the error: $_"
        Exit 1
    }
}

Exit 0