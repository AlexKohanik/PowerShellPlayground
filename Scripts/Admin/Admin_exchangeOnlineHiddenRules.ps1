# Check for Hidden Inbox rules using exchange online module. 
# Install-Module -Name ExchangeOnlineManagement -RequiredVersion 3.4.0    <--- Install if necessary

Import-Module ExchangeOnlineManagement

$UPN = Read-Host "Enter UPN"

Connect-ExchangeOnline -UserPrincipalName $UPN -ShowProgress $true

Get-InboxRule -Mailbox Read-Host "Enter employee email address" | Where-Object {$_.IsEnabled -eq $true -and $_.Visible -eq $false}

# Run this after. 
#Disconnect-ExchangeOnline -Confirm:$false
