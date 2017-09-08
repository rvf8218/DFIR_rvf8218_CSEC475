Param(
[string[]]$computers
)

$command = {

$OS = Get-WmiObject win32_OperatingSystem
$CPU = Get-WmiObject win32_Processor
$RAM = Get-WmiObject win32_PhysicalMemory
$HDD = Get-WmiObject win32_DiskDrive
$FS = Get-PSDrive -PSProvider FileSystem
$SYS = Get-WmiObject win32_ComputerSystem
$Users = Get-WmiObject win32_UserAccount
$startup = Get-WmiObject win32_StartupCommand
$services = Get-WmiObject win32_Service
$interface = Get-WmiObject win32_NetworkAdapterConfiguration
$install = Get-WmiObject win32_Product
$process = Get-WmiObject win32_Process

"Time Information
_______________________________________________________________________________"
Get-Date
$OS.CurrentTimeZone
$sysuptime = (Get-Date) - ($OS.lastbootuptime)
"Uptime: " + $sysuptime.Days + " Days " + $sysuptime.Hours ":" + $sysuptime.Minutes + ":" + $sysuptime.Seconds

"OS Information
_______________________________________________________________________________"
$OS.Version
$OS.Caption

"Hardware Information
_______________________________________________________________________________"
$CPU.Name
"RAM Space: " + $RAM.Capacity/1GB
$HDD | ForEach-Object {"HDD ID: " + $HDD.DeviceID; "HDD Space: " + $HDD.Size/1GB}
$FS | ForEach-Object {"Mounted File Systems:";"    Name: " + $FS.Name;"    Root: " + $FS.Root; "    Location: " + $FS.CurrentLocation}

"Domain Information
________________________________________________________________________________"
"Domain: " + $SYS.Domain
"Hostname: " + $SYS.Name

"User Information
________________________________________________________________________________"
$Users | ForEach-Object {$Users.SID + {$logon = net user $Users.Name; $logon[18]}}
#Need domain user info
#Need system user info
#Need service users
#User login history

"Startup Information
________________________________________________________________________________"
$startup | select Command,Location,User
$services | Where-Object {$_.StartMode -eq "Auto"} | select name

"Scheduled Tasks
_______________________________________________________________________________"
Get-ScheduledTask

"Network Information
_______________________________________________________________________________"
#Still needs listening services
Get-NetNeighbor
$interface | select description, macaddress | Where-Object { $_.macaddress -clike "*:*:*:*:*:*"}
Get-NetRoute
$interface | select description, ipaddress | Where-Object {$_.ipaddress -like "*[0-9]*"}
$interface | select dhcpserver | Where-Object {$_.DHCPServer -like "*[0-9]*"}
Get-DnsClientServerAddress | Where-Object {$_.serveraddresses -like "*[0-9]*"}
$interface | select Description,DefaultIPGateway | Where-Object {$_.DefaultIPGateway -like "*[0-9]*"}
Get-NetTCPConnection -State Established
Get-DnsClientCache

"Connected Network Devices
_______________________________________________________________________________"
Get-WmiObject win32_Share
Get-WMIObject win32_Printer | Where-Object{$_.Network -eq 'true'} 
netsh.exe wlan show profiles

"Installed Software
_______________________________________________________________________________"
#Can improve later - generates log events
$install | select name

"Process List
_______________________________________________________________________________"
$process | select name,parentprocessid,processid,path,@{N="User";E={$_.GetOwner().User}}

"Driver List
_______________________________________________________________________________"
#Missing some information
Get-WmiObject Win32_PnPSignedDriver| select DeviceName, DriverVersion, Manufacturer
"User Files
_______________________________________________________________________________"
$username = $credential.GetNetworkCredential().username
Get-ChildItem -Path C:\Users\$username\Documents
Get-ChildItem -Path C:\Users\$username\Downloads

"Other Information
_______________________________________________________________________________"
Get-ChildItem -Path Registry::HKLM\SYSTEM\CurrentControlSet\Control\usbstor
#Need 2 more
}

#If no name given, localhost is assumed
If($computers -eq ""){$computers = $env:COMPUTERNAME}
#For name in list run all the commands
$i = 1
ForEach($computername in $computers)
{

If($computername -ne $env:COMPUTERNAME)
{
$credential = Invoke-Command -ComputerName $computername {Get-Credential}
Invoke-Command -ComputerName $computername -Credential $credential -ScriptBlock $command | Export-Csv -Path "remoteoutput$i.csv"}
}
Else
{
$command | Export-Csv -Path "output.csv"
}
$i = $i+1

}