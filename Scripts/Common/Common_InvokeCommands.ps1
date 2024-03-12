# Basic Invoke-Command. Review MS Documentation for questions, https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/invoke-command?view=powershell-7.4

# Invoke-Command -ComputerName pcname.domain.local -Credential domain\srvcAcct -ScriptBlock { <#Insert Here #> }

$endpoint = Read-Host "Enter endpoint hostname"
$user = Read-Host "Enter domain\user for runas"
$scriptBlox = Read-Host "Enter script/pwsh command"


Invoke-Command -ComputerName $endpoint -Credential $user -ScriptBlock { $scriptBlox }

# Basic commands you could insert into the ScriptBlock Tags...
    # taskkill /I /MF < process name, ex. notepad.exe >
    # Restart-Service -Name < service name, ex. Spooler >
    # Get-Service -Name < service name, ex. Spooler >
    # Copy-Item "C:\Folder1\Data.txt" -Destination "C:\Folder2"
    # Get-Service | Out-File -FilePath C:\Temp\Services.txt.