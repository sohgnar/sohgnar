Import the SuperOps module
Import-Module $SuperOpsModule

Get Device Type
$systemType = (Get-CimInstance -ClassName Win32_ComputerSystem).PCSystemType
switch ($systemType) {
    1 { $SystemTypeNew = "Desktop" }
    2 { $SystemTypeNew = "Laptop" }
    default { $SystemType = "Unknown" }
}
Send-CustomField -CustomFieldName "System Type" -Value $SystemTypeNew
Write-Host "System Type: $SystemTypeNew"

Get Docking Station Information
if ($systemType = 2) {
    $DockingStation = Get-PnPDevice | where{$.InstanceID -like "USB\VID"} | where{$_.InstanceID -like "_00"} | where{$.Class -like "Disp"}
}
$DockingStationMulti = echo $DockingStation.FriendlyName
Send-CustomField -CustomFieldName "Docking Station" -Value $DockingStationMulti
Write-Host "Docking Station: $DockingStationMulti"

Get Count of Monitors
$MonitorCount = (Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams).Count
Send-CustomField -CustomFieldName "Monitor Count" -Value $MonitorCount
Write-Host "Monitor Count: $MonitorCount"

Get Monitor Models
Get monitor information using WMI
$monitors = Get-WmiObject -Namespace root\wmi -Class WmiMonitorID

Loop through each monitor and display the model
foreach ($monitor in $monitors) {
    $MonitorModel = ($monitor.UserFriendlyName -notmatch 0 | ForEach-Object { [char]$ }) -join ''
    Write-Output "Monitor Model: $MonitorModel"
}
Send-CustomField -CustomFieldName "Monitor Model" -Value $MonitorModel
Write-Host "Monitor Model: $MonitorModel"
