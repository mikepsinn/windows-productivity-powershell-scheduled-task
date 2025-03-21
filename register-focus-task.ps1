# Check if running as administrator and self-elevate if not
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Relaunch as administrator
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Get the current directory where both scripts are located
$scriptPath = $PSScriptRoot
$focusScriptPath = Join-Path $scriptPath "focus.ps1"

# Create the scheduled task action
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Normal -File `"$focusScriptPath`""

# Create multiple triggers
$triggers = @(
    # At user logon
    $(New-ScheduledTaskTrigger -AtLogOn),
    # Every 4 hours if the task is not running
    $(New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 4))
)

# Set the principal (run as current user)
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

# Create the settings (allow running on battery, stop if runs too long)
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Hours 8) `
    -RestartInterval (New-TimeSpan -Minutes 30) `  # Try to restart if it stops
    -RestartCount 3  # Number of restart attempts

# Register the scheduled task
$taskName = "FocusMode"
$description = "Runs the focus mode script at login and periodically to help maintain productivity"

Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $triggers `
    -Principal $principal `
    -Settings $settings `
    -Description $description `
    -Force

Write-Host "`nFocus Mode task has been registered successfully!" -ForegroundColor Green
Write-Host "The script will run:" -ForegroundColor Yellow
Write-Host "- When you log in to Windows" -ForegroundColor Yellow
Write-Host "- Every 4 hours if not running" -ForegroundColor Yellow
Write-Host "- Will try to restart up to 3 times if it stops unexpectedly" -ForegroundColor Yellow
Write-Host "`nTo remove this task later, run: Unregister-ScheduledTask -TaskName 'FocusMode' -Confirm:`$false" -ForegroundColor Gray

# Pause at the end to see the output
Write-Host "`nPress any key to continue..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') 