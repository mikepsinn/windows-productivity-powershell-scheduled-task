#requires -version 3.0

<#
.Synopsis
Create a reminder background job.
.Description
This command uses the MSG.EXE command line tool to send a reminder message to currently logged on user. You can specify how many minutes to wait before displaying the message or you can set the alert to run at a specific date and time.

This command creates a background job in the current PowerShell session. If you close the session, the job will also be removed. This command is intended to set ad-hoc reminders for the current user. The message will automatically dismiss after 1 minute unless you use -Wait.

Even though Start-Job doesn't support -WhatIf, this command does. This script will also add some custom properties to the job object so that you can track that status of your reminders. See the examples.

NOTE: Be aware that each running reminder will start a new PowerShell process.
.Parameter Message
The text to display in the popup.
.Parameter Time
The date and time to display the popup. If you enter just a time, it will default to the current day. See examples. 
This parameter has aliases of date and dt. 
.Parameter Minutes
The number of minutes to wait before displaying the popup message.
.Parameter Wait
Force the user to acknowledge the popup message.
.Example
PS C:\> c:\scripts\new-reminderjob.ps1 "Switch over laundry" -minutes 40 -wait

This command creates a new job that will display a message in 40 minutes and wait for the user to acknowledge.
.Example
PS C:\> c:\scripts\new-reminderjob.ps1 "Go home" -time "5:00PM" -passthru

Id   Name         PSJobTypeName   State      HasMoreData     Location     Command         
--   ----         -------------   -----      -----------     --------     -------         
49   Reminder7    BackgroundJob   Running    True            localhost    ...      

Create a reminder to be displayed at 5:00PM today. The job object is written to the pipeline because of -Passthru
.Example
PS C:\> get-job remind* | Sort Time | Select ID,Name,State,Message,Time,Wait | format-table -auto

Id Name      State   Message             Time                 Wait
-- ----      -----   -------             ----                 ----
67 Reminder1 Running switch over laundry 5/27/2014 2:34:33 PM True
69 Reminder2 Running Budget meeting      5/27/2014 3:00:00 PM False
71 Reminder3 Running reboot WSUS         5/27/2014 3:21:33 PM False

In this example, PowerShell is getting all reminder jobs sorted by the time they will "kick off" and displays the necessary properties.
.Notes
Last Updated: 5/27/2014
Version     : 0.9
Author      : Jeff Hicks (@JeffHicks)
              http://jdhitsolutions.com/blog

Learn more:
 PowerShell in Depth: An Administrator's Guide (http://www.manning.com/jones2/)
 PowerShell Deep Dives (http://manning.com/hicks/)
 Learn PowerShell 3 in a Month of Lunches (http://manning.com/jones3/)
 Learn PowerShell Toolmaking in a Month of Lunches (http://manning.com/jones4/)
   
  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************

.Link
http://jdhitsolutions.com/blog/2014/05/powershell-reminder-jobs
.Link
msg.exe
Start-Sleep
Start-Job
.Inputs
None
.Outputs
custom System.Management.Automation.PSRemotingJob
#>

[cmdletbinding(DefaultParameterSetName="Minutes",SupportsShouldProcess)]
Param(
[Parameter(Position=0,Mandatory,HelpMessage="Enter the alert message text")]
[string]$Message,
[Parameter(ParameterSetName="Time")]
[ValidateNotNullorEmpty()]
[Alias("date","dt")]
[datetime]$Time,
[Parameter(ParameterSetName="Minutes")]
[ValidateNotNullorEmpty()]
[int]$Minutes=1,
[switch]$Wait,
[switch]$Passthru
)

Begin {
    Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"  
    Write-Verbose -Message "Using parameter set $($PSCmdlet.ParameterSetName)"
    Switch ($PSCmdlet.ParameterSetName) {
    "Time" { [int]$sleep = ($Time - (Get-Date)).TotalSeconds  }
    "Minutes" { [int]$sleep = $minutes*60}
    }

    #get last job ID
    $lastjob = Get-Job -Name "Reminder*" | sort ID | select -last 1
    
    if ($lastjob) {
        #define a regular expression
        [regex]$rx ="\d+$"
        [string]$counter = ([int]$rx.Match($lastJob.name).Value +1)
    }
    else {
        [string]$counter = 1
    }
} #begin

Process {
    Write-Verbose -message "Sleeping for $sleep seconds"
    $sb = {
    Param($sleep,$cmd)
    Start-Sleep -seconds $sleep ; Invoke-Expression $cmd
    }
    
    [string]$cmd = "msg.exe $env:username"
    if ($Wait) {
        Write-Verbose "Reminder will wait for user"
        $cmd+=" /W"
    }

    $cmd+=" $message"
    
    $jobName = "Reminder$Counter"
    Write-Verbose -Message "Creating job $jobname"

    #WhatIf
    $whatif = "'{0}' in {1} seconds" -f $message,$sleep
    if ($PSCmdlet.ShouldProcess( $whatif )) {
     $job = Start-Job -ScriptBlock $sb -ArgumentList $sleep,$cmd -Name $jobName 
     #add some custom properties to the job object
     $job | Add-Member -MemberType NoteProperty -Name Message -Value $message
     $job | Add-Member -MemberType NoteProperty -Name Time -Value (Get-Date).AddSeconds($sleep)
     $job | Add-Member -MemberType NoteProperty -Name Wait -Value $Wait
     if ($passthru) {
      #if -Passthru write the job object to the pipeline
      $job
     }
    }
} #process

End {
    Write-Verbose -Message "Do not close this PowerShell session or you will lose the reminder job"
    Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"
} #end