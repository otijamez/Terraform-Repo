install-windowsfeature -name Web-Server -IncludeManagementTools
Set-location -Path c:\inetpub\wwwroot
Add-Content iisstart.htm `
    "<H1><center> $env:COMPUTERNAME, SERVER </center></H1>"
Invoke-Command -ScriptBlock{iisreset}
