$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module $ScriptDir\functions.ps1

$tasks = @('Apples','Oranges','Bananas')

MinimizeWindows
OpenUrlsFromFile 'C:\Development\qm-api\repos\mikepsinn\windows-productivity-powershell-schduled-task\urls.txt'
OpenApplicationsFromFile 'C:\Development\qm-api\repos\mikepsinn\windows-productivity-powershell-schduled-task\applications.txt'


# Popup
ShowWarning 'Are you working on your MOST IMPORTANT TASK?'
