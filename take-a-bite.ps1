$shell = New-Object -ComObject "Shell.Application"
$shell.minimizeall()

# Popup
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[System.Windows.Forms.MessageBox]::Show('Take a bite','WARNING')


