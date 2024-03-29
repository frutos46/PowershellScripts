####################################################################################
# Autor: Jose Antonio Frutos
# Version: v1
# Creado: 25/02/2022
# Script: obtiene el último logon de un usuario en un equipo
####################################################################################

#Definimos variables
$logs = get-eventlog system -source Microsoft-Windows-Winlogon -Newest 1 | Where-Object {$_.instanceid -eq 7001}
$res =@(); 

ForEach ($log in $logs) 
{
if($log.instanceid -eq 7001) {$type = "$env:COMPUTERNAME"} 
#Elseif ($log.instanceid -eq 7002){$type="Logoff"} 
#Else {Continue} 
$res += New-Object PSObject -Property @{Time = $log.TimeWritten.ToString('MM/dd/yyyy HH:mm:ss'); "Machine" = $type; User = (New-Object System.Security.Principal.SecurityIdentifier $Log.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount])}};
$res.Time +" - "+ $res.Machine +" - "+ $res.User 
