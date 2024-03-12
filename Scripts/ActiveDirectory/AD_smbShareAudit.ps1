# Audit SMB Share access.

# Define the path to the SMB share via user input
$sharePathInput = Read-Host "Enter network drive path"
$sharePath = $sharePathInput

# Get ACLs for files and folders on the SMB share
$acls = Get-ChildItem -Path $sharePath -Recurse | ForEach-Object {
    $item = $_
    $acl = Get-Acl -Path $item.FullName
    [PSCustomObject]@{
        Path = $item.FullName
        Owner = $acl.Owner
        Access = $acl.AccessToString
    }
}

# Parse and analyze ACLs
$accessReport = $acls | ForEach-Object {
    $path = $_.Path
    $owner = $_.Owner
    $access = $_.Access

    # Extract user/group and access level information
    $accessData = $access -split '; ' | ForEach-Object {
        $accessInfo = $_ -split ', '
        [PSCustomObject]@{
            Identity = $accessInfo[0]
            AccessLevel = $accessInfo[1]
        }
    }

    # Output formatted report data
    [PSCustomObject]@{
        Path = $path
        Owner = $owner
        AccessData = $accessData
    }
}

# Output the access report
$accessReport | Format-Table -AutoSize
