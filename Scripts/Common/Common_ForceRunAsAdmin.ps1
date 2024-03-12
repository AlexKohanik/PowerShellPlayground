# Function to check if the script is running as an administrator
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# If script is not running as administrator, restart with elevated privileges
if (-not (Test-Admin)) {
    $processArgs = "-File `"$PSCommandPath`""
    Start-Process -FilePath PowerShell.exe -Verb RunAs -ArgumentList $processArgs
    Exit
}