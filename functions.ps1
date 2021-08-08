Function OpenUrls ($urls) {
    foreach ($url in $urls)
    {
        $url.replace("%", "%%")
        # Default browser
        Start-Process $url
        # Edge
        #$Browser=new-object -com internetExplorer.application
        # $Browser.navigate2($SitePath)
        # $Browser.visible=$true
        # FireFox
        #[system.Diagnostics.Process]::Start("firefox", $SitePath)
    }
}

Function OpenUrlsFromFile ($path) {
    [string[]]$urls = Get-Content -Path $path
    OpenUrls $urls
}

Function OpenApplications ($applications) {
    foreach ($application in $applications)
    {
        Start-Process -FilePath $application
    }
}

Function OpenApplicationsFromFile ($path) {
    [string[]]$applications = Get-Content -Path $path
    OpenApplications $applications
}

Function MinimizeWindows () {
    $shell = New-Object -ComObject "Shell.Application"
    $shell.minimizeall()
}


Function ShowWarning ($msg) {
    # Popup
    [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    [System.Windows.Forms.MessageBox]::Show($msg,'WARNING')
}

Function OpenForm ($buttonText, $button_Onclick) {
    Add-Type -AssemblyName System.Windows.Forms

    $Form = New-Object system.Windows.Forms.Form
    $Form.Text = 'Are you working on your MOST IMPORTANT TASK?'
    $Form.Width = 300
    $Form.Height = 200

    $label2 = New-Object system.windows.Forms.Label
    $label2.AutoSize = $true
    $label2.Width = 25
    $label2.Height = 10
    $label2.location = new-object system.drawing.size(71,89)
    $label2.Font = "Microsoft Sans Serif,10"
    $Form.controls.Add($label2)

    $button4 = New-Object system.windows.Forms.Button
    $button4.add_Click($button_Onclick)
    $button4.Text = $buttonText
    $button4.Width = 100
    $button4.Height = 30
    $button4.location = new-object system.drawing.size(15,15)
    $button4.Font = "Microsoft Sans Serif,10"
    $button4.AutoEllipsis
    $Form.controls.Add($button4)

    $Form.ShowDialog()
}