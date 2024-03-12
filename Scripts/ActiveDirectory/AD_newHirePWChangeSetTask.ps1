# Testing GUI capabilities with this script for ease of use. 

# This script's purpose is to allow an Admin to input a new hire's start date, username, and specify a domain controller.
# From there a .ps1 script generates in a specified SMB share that forces the user account to change their password at next logon. 
# Lastly creates a task on the specified domain controller to run this generated script midnight on the new hire's start date. 
# Therefore IT Admin's can setup the new hire's machine with the password they have set and not have to worry about circling back to AD to check the box to force user to change pw at next logon. 


# Function to create the GUI for user input
function Show-InputForm {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    $form = New-Object Windows.Forms.Form
    $form.Text = "New Hire Password Policy"
    $form.Size = New-Object Drawing.Size(450,350)
    $form.StartPosition = "CenterScreen"
    
    $labelUsername = New-Object Windows.Forms.Label
    $labelUsername.Text = "Enter New Hire's Username:"
    $labelUsername.Location = New-Object Drawing.Point(10,20)
    $labelUsername.Size = New-Object Drawing.Size(370,20)
    
    $textboxUsername = New-Object Windows.Forms.TextBox
    $textboxUsername.Location = New-Object Drawing.Point(10,40)
    $textboxUsername.Size = New-Object Drawing.Size(370,20)
    
    $labelDomainController = New-Object Windows.Forms.Label
    $labelDomainController.Text = "Enter Domain Controller:"
    $labelDomainController.Location = New-Object Drawing.Point(10,80)
    $labelDomainController.Size = New-Object Drawing.Size(370,20)
    
    $textboxDomainController = New-Object Windows.Forms.TextBox
    $textboxDomainController.Location = New-Object Drawing.Point(10,100)
    $textboxDomainController.Size = New-Object Drawing.Size(370,20)
    
    $labelStartDate = New-Object Windows.Forms.Label
    $labelStartDate.Text = "Enter New Hire's Start Date:"
    $labelStartDate.Location = New-Object Drawing.Point(10,140)
    $labelStartDate.Size = New-Object Drawing.Size(370,20)
    
    $datepickerStartDate = New-Object Windows.Forms.DateTimePicker
    $datepickerStartDate.Location = New-Object Drawing.Point(10,160)
    $datepickerStartDate.Size = New-Object Drawing.Size(370,20)
    
    $buttonOK = New-Object Windows.Forms.Button
    $buttonOK.Text = "OK"
    $buttonOK.Location = New-Object Drawing.Point(170,220)
    $buttonOK.Size = New-Object Drawing.Size(60,30)
    $buttonOK.DialogResult = [Windows.Forms.DialogResult]::OK
    
    $form.Controls.Add($labelUsername)
    $form.Controls.Add($textboxUsername)
    $form.Controls.Add($labelDomainController)
    $form.Controls.Add($textboxDomainController)
    $form.Controls.Add($labelStartDate)
    $form.Controls.Add($datepickerStartDate)
    $form.Controls.Add($buttonOK)
    
    $form.AcceptButton = $buttonOK
    
    $result = $form.ShowDialog()
    
    if ($result -eq [Windows.Forms.DialogResult]::OK) {
        $username = $textboxUsername.Text
        $domainController = $textboxDomainController.Text
        $startDate = $datepickerStartDate.Value.ToShortDateString()
        return $username, $domainController, $startDate
    }
}

# Get user input
$username, $domainController, $startDate = Show-InputForm

# Generate script file for new hire
$scriptContent = @"

# Set execution policy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Import Active Directory module if not already imported
if (-not (Get-Module -Name ActiveDirectory)) {
    Import-Module ActiveDirectory
}

# Disable Password Never Expires, because it can cause issue setting "Change PW at next logon" 
Set-ADUser -Identity '$username' -PasswordNeverExpires `$false -Server '$domainController'

# Set the "User must change password at next logon" attribute
Set-ADUser -Identity '$username' -ChangePasswordAtLogon `$true -Server '$domainController'

"@

# Make sure to specify SMB share path where the script will be generated to. Please ensure the DC has access, as well as the machine running this script. 
$scriptPath = "\\servername\shared\folder\pwChangeScript1_$username.ps1"
$scriptContent | Out-File -FilePath $scriptPath -Encoding ASCII

# Testing signing the file due to issues running on DC with remotesigned script enforced. 
<#
# Sign the script
try {
    $cert = Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert -ErrorAction Stop
    Set-AuthenticodeSignature -FilePath $scriptPath -Certificate $cert -ErrorAction Stop
}
catch {
    Write-Error "Failed to sign the script. Error: $_"
    Exit 1  # Exit script with an error code
}
#>

# Create scheduled task to execute the script
$actionPath = "Powershell.exe -ExecutionPolicy Bypass -File '$scriptPath'"
$taskName = "Set_Password_Change_At_Next_Logon_$username"

# Register the scheduled task on the domain controller
$registerTaskScript = {
    param (
        [string]$ActionPath,
        [string]$ActionArguments,
        [string]$TaskName,
        [string]$StartDate
    )
    
    $trigger = New-ScheduledTaskTrigger -Once -At $StartDate
    $action = New-ScheduledTaskAction -Execute $ActionPath
    Register-ScheduledTask -TaskName $TaskName -Trigger $trigger -Action $action -RunLevel Highest
}

Invoke-Command -ComputerName $domainController -ScriptBlock $registerTaskScript -ArgumentList $actionPath, $actionArguments, $taskName, $startDate
