####################################################################################
# Autor: Jose Antonio Frutos
# Version: v1
# Creado: 28/03/2022
####################################################################################

$DNSSERVER=gc env:computername

$BkfFolder=”c:\windows\system32\dns\backup”

if ( -not(test-path $BkfFolder)) {
new-item $BkfFolder -Type Directory | Out-Null
} else {

Remove-Item $BkfFolder”\*” -recurse
}


$StrFile=$Bkffolder+”\input.csv”
Add-content $StrFile “Zone,ZoneType,Update,Secondary,DsIntegrated”



$List = gwmi -ComputerName $DNSSERVER -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Zone

$List | foreach {

$line=$_.name+”,”+$_.ZoneType+”,”+$_.AllowUpdate+”,”+$_.MasterServers+”,”+$_.DsIntegrated
Add-content $Strfile $Line

$ZoneName=$_.name
$StrPath=”\backup\”+$_.name



dnscmd $DNSSERVER “/ZoneExport” $ZoneName $StrPath

}