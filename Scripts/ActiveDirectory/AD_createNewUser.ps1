# Needs update to determine secure method of inputting password values. 

# Create new AD User. 
# Import the Active Directory module
Import-Module ActiveDirectory

# Recommend adding Force Run as Admin here. 

# Define parameters for the new user
# Utilizing Read-Host to allow Admin to enter specific parameters
$SamAccountName = Read-Host "Enter SAM Account name, example: john.smith"
$UserPrincipalName = Read-Host "Enter UPN, newuser@domain.com"
$FirstName = Read-Host "Enter first name"
$LastName = Read-Host "Enter last name"
<# $Password = Read-Host "Enter password" ConvertTo-SecureString -AsPlainText -Force #> # Note: Need to determine secure means of inputting password. 
$OU = Read-Host "Enter OU, example: OU=Users,DC=domain,DC=com"  # Note: Organizational Unit where you want to create the user
$Description = Read-Host "Enter description"
$EmailAddress = Read-Host "Enter email address"
$DisplayName = Read-Host "Enter full name"

# Create the new user account
New-ADUser `
    -SamAccountName $SamAccountName `
    -UserPrincipalName $UserPrincipalName `
    -Name "$FirstName $LastName" `
    -GivenName $FirstName `
    -Surname $LastName `
<#  -AccountPassword $Password `  #>
    -Enabled $true `
    -Path $OU `
    -Description $Description `
    -EmailAddress $EmailAddress `
    -DisplayName $DisplayName
