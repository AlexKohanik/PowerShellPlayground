# Back up users C: Drive to a UNC Path/SMB Share. 

# Recommend inserting force run as admin. 

$sourcePath = Read-Host "Enter users profile folder, example \\hostnameOfPC\C$\Users\john.smith"  # Specify the user's profile folder
$destinationPath = Read-Host "Enter UNC path for backup, example \\Server\Share\Backup\testuser"  # Specify the UNC path where you want to store the backup

# Create the destination directory if it doesn't exist
if (-not (Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath -Force
}

# Copy user profile folders recursively
$foldersToBackup = @("Documents", "Pictures", "Desktop", "Downloads", "Favorites", "Music", "Videos")
foreach ($folder in $foldersToBackup) {
    $sourceFolderPath = Join-Path -Path $sourcePath -ChildPath $folder
    $destinationFolderPath = Join-Path -Path $destinationPath -ChildPath $folder
    Copy-Item -Path $sourceFolderPath -Destination $destinationFolderPath -Recurse -Force
}
