function Add-Reminder{
    <#
.Synopsis
Creates a scheduled task that will display a reminder.
.Description
Creates a scheduled task that will display a reminder.
.Parameter Time
Time when the reminder should be displayed.
.Parameter Reminder
Message of the reminder.
.Example
Add-Reminder -Reminder  "Clean Kitchen" -time "1/1/2016 12:00 PM"
This example will remind you to clean your kitchen on 1/1/2016 at 12:00 PM
#>
    Param(
        [string]$Reminder,
        [datetime]$Time
    )
    $Task = New-ScheduledTaskAction -Execute msg -Argument "* $Reminder"
    $trigger =  New-ScheduledTaskTrigger -Once -At $Time
    $Random = (Get-random)
    Register-ScheduledTask -Action $task -Trigger $trigger -TaskName "Reminder_$Random" -Description "Reminder"
}