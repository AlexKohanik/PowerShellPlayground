# Utilize Invoke-Command to run a single command on multiple computers.


$parameters = @{
  ComputerName      = 'Server1', 'PC1', 'Server7'
  ScriptBlock       = { Get-Service Spooler }
}
Invoke-Command @parameters

