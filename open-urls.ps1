$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module $ScriptDir\functions.ps1

MinimizeWindows
OpenUrlsFromFile 'C:\Development\qm-api\repos\mikepsinn\windows-productivity-powershell-schduled-task\urls.txt'
ShowWarning 'Are you working on your MOST IMPORTANT TASK?'

