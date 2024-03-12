
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

# Set your Slack webhook URL
$webhookUrl = "https://hooks.slack.com/services/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"

# Function to send message to Slack
function Send-SlackMessage {
    param (
        [string]$WebhookUrl,
        [string]$Message
    )

    $body = @{
        text = $Message
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Method Post -Uri $WebhookUrl -Body $body -ContentType 'application/json' -ErrorAction Stop
    } catch {
        Write-Error "Failed to send Slack message: $_"
    }
}

# Define the query for the event log watcher
$query = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=4720)]]</Select>
  </Query>
</QueryList>
"@

# Create the event log watcher
try {
    $watcher = New-Object System.Diagnostics.Eventing.Reader.EventLogWatcher -ArgumentList (New-Object System.Diagnostics.Eventing.Reader.EventLogQuery "Security", "LogName", $query)
} catch {
    Write-Error "Failed to create event log watcher: $_"
    Exit
}

# Register event handler for the EventRecordWritten event
try {
    Register-ObjectEvent -InputObject $watcher -EventName EventRecordWritten -Action {
        $event = $Event.SourceEventArgs.EventRecord
        $userName = $event.Properties[0].Value
        $message = "New user created in Active Directory: $userName"
        Send-SlackMessage -WebhookUrl $webhookUrl -Message $message
    }
} catch {
    Write-Error "Failed to register event handler: $_"
    Exit
}

# Keep the script running
try {
    Write-Host "Monitoring for new user creation events. Press Ctrl+C to exit."
    while ($true) {
        Start-Sleep -Seconds 5
    }
} finally {
    $watcher.Dispose()
}
