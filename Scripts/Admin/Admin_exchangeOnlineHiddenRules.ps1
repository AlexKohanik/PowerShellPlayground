# Check for Hidden Inbox rules using exchange online module. 

Connect-ExchangeOnline -UserPrincipalName Read-Host "Enter UPN" -ShowProgress $true

Get-InboxRule -Mailbox Read-Host "Enter employee email address" | Where-Object {$_.IsEnabled -eq $true -and $_.Visible -eq $false}

# Run this after to disconnect from online module. 
#Disconnect-ExchangeOnline -Confirm:$false
