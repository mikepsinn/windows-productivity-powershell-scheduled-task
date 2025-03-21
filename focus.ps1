# Requires -Version 5.0

# Add Windows Forms assembly for window manipulation and UI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Speech

# Configuration with default values
$configPath = Join-Path $env:USERPROFILE "focus_config.json"
$defaultConfig = @{
    ReminderIntervalMinutes = 5
    SaveAnswerPath = Join-Path $env:USERPROFILE "focus_answer.txt"
}

# Load or create config
$config = $defaultConfig.Clone()
if (Test-Path $configPath) {
    $savedConfig = Get-Content $configPath | ConvertFrom-Json
    $config.ReminderIntervalMinutes = $savedConfig.ReminderIntervalMinutes
}

function Show-SettingsForm {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Focus Mode Settings"
    $form.Size = New-Object System.Drawing.Size(400, 200)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    # Interval Label
    $labelInterval = New-Object System.Windows.Forms.Label
    $labelInterval.Location = New-Object System.Drawing.Point(20, 20)
    $labelInterval.Size = New-Object System.Drawing.Size(200, 20)
    $labelInterval.Text = "Reminder Interval (minutes):"
    $form.Controls.Add($labelInterval)

    # Interval TextBox
    $textboxInterval = New-Object System.Windows.Forms.NumericUpDown
    $textboxInterval.Location = New-Object System.Drawing.Point(220, 20)
    $textboxInterval.Size = New-Object System.Drawing.Size(60, 20)
    $textboxInterval.Minimum = 1
    $textboxInterval.Maximum = 120
    $textboxInterval.Value = $config.ReminderIntervalMinutes
    $form.Controls.Add($textboxInterval)

    # Save Button
    $buttonSave = New-Object System.Windows.Forms.Button
    $buttonSave.Location = New-Object System.Drawing.Point(150, 100)
    $buttonSave.Size = New-Object System.Drawing.Size(100, 30)
    $buttonSave.Text = "Save"
    $buttonSave.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($buttonSave)
    $form.AcceptButton = $buttonSave

    # Show form
    if ($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $config.ReminderIntervalMinutes = $textboxInterval.Value
        $config | ConvertTo-Json | Out-File $configPath
        return $true
    }
    return $false
}

function Minimize-AllWindows {
    $shell = New-Object -ComObject Shell.Application
    $shell.MinimizeAll()
}

function Speak-Text {
    param([string]$text)
    $synthesizer = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $synthesizer.Speak($text)
}

# Show settings if Shift key is held down
$shiftPressed = [System.Windows.Forms.Control]::ModifierKeys -band [System.Windows.Forms.Keys]::Shift
if ($shiftPressed) {
    $settingsChanged = Show-SettingsForm
    if (-not $settingsChanged) {
        exit
    }
}

# Minimize all windows
Minimize-AllWindows

# Check if we have a saved answer
$answer = $null
if (Test-Path $config.SaveAnswerPath) {
    $answer = Get-Content $config.SaveAnswerPath
    Write-Host "`nPrevious focus task found: $answer" -ForegroundColor Cyan
    $keepPrevious = Read-Host "Would you like to keep this focus? (y/n)"
    if ($keepPrevious -ne 'y') {
        $answer = $null
    }
}

# If no saved answer or user wants new one, ask the focusing question
if (-not $answer) {
    $mantra = "What can you be doing right now that has the highest leverage for improving your health, finance or reducing suffering?"
    Write-Host "`n$mantra" -ForegroundColor Green
    $answer = Read-Host "Your answer"
    
    # Save the answer for next time
    $answer | Out-File $config.SaveAnswerPath -Force
}

# Clear the screen for focus
Clear-Host

Write-Host "Focus Mode Activated" -ForegroundColor Cyan
Write-Host "Your focus task: $answer" -ForegroundColor Yellow
Write-Host "Reminder interval: Every $($config.ReminderIntervalMinutes) minutes" -ForegroundColor Gray
Write-Host "Hold Shift when starting to change settings" -ForegroundColor Gray
Write-Host "`nPress Ctrl+C to exit" -ForegroundColor Gray

# Continuous reminder loop
try {
    while ($true) {
        Start-Sleep -Seconds ($config.ReminderIntervalMinutes * 60)
        Minimize-AllWindows
        Speak-Text "Remember your focus: $answer"
        Write-Host "`nStaying focused on: $answer" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "`nFocus session ended. Your focus task is saved for next time." -ForegroundColor Cyan
} 