# --------------------------------------------------------------------
# Checking Execution Policy
# --------------------------------------------------------------------
#$Policy = "Unrestricted"
$Policy = "RemoteSigned"
If ((get-ExecutionPolicy) -ne $Policy) {
  Write-Host "Script Execution is disabled. Enabling it now"
  Set-ExecutionPolicy $Policy -Force
  Write-Host "Please Re-Run this script in a new powershell enviroment"
  Exit
}

$Package="Web-Server"

#WebDeploy 
$Url="http://download.microsoft.com/download/D/4/4/D446D154-2232-49A1-9D64-F5A9429913A4/WebDeploy_amd64_en-US.msi"
$Path="C:\WebDeploy1.msi"

Import-Module ServerManager
Add-WindowsFeature -Name $Package -IncludeAllSubFeature
 
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile($url,$path)
Start-Process -FilePath "$Path" -ArgumentList "/q" -Wait

#Add firewall rule 
netsh advfirewall firewall add rule name="WebDeploySites" dir=in action=allow protocol=TCP localport=8080-8200 enable=yes

sc privs wmsvc SeChangeNotifyPrivilege/SeImpersonatePrivilege/SeAssignPrimaryTokenPrivilege/SeIncreaseQuotaPrivilege
Remove-Item -Path "$Path" -Force


