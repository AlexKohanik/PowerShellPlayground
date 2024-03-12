# Install a program silently. 
# Added Read-Host to allow admins to input filepaths/parameters on the fly. 

# Recommend inserting function to force run as administrator. 

# Copy .exe or .msi file to the machine. 

$sourcePath = Read-Host "Enter source file path, example C:\Path\To\Your\File\file.exe"
$destinationPath = Read-Host "Enter destination path, example \\RemoteComputer\C$\Temp\file.exe"
Copy-Item -Path $sourcePath -Destination $destinationPath

# Execute silent installation to the machine. 

$installerPath = $destinationPath
$computerName = Read-Host "Confirm the hostname"
$arguments = Read-Host "Enter command line arguments, example /quiet /norestart"  # Adjust the arguments as per your installer
Invoke-Command -ComputerName $computerName -ScriptBlock{
    Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait
} 
