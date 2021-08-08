$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path


& "$ScriptDir\reminders-job.ps1 'Switch over laundry' -minutes 40 -wait"
