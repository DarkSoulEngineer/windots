Add-Type -AssemblyName System.Windows.Forms
Start-Sleep -Milliseconds 80
[System.Windows.Forms.SendKeys]::SendWait('^l')
Start-Sleep -Milliseconds 200
[System.Windows.Forms.SendKeys]::SendWait('^c')
