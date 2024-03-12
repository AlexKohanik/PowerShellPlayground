# Query on-prem AD. Audit users by last login date, export list to .csv .txt or any specificed file path. 

# Recommend adding Force Run as Admin here. 

# Import the Active Directory module
Import-Module ActiveDirectory

# Prompt user to input file path. 
$filepath = Read-Host "Enter file path to export report to"

# Search AD for Inactive Accounts, export to CSV
Search-ADAccount -AccountInactive -UsersOnly > $filepath

