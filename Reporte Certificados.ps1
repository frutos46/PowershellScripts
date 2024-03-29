################################################################################
# Autor: Jose Antonio Frutos
# Version: v1
# Creado: 19/08/2021
# Script: Muestra los certificados de usuario y maquina, con la opcion de poder
#         mandarlo enviarlos por ftp o dejarlos en un csv
################################################################################

$equipo = hostname
$usuario = $env:UserName
$fecha = Get-Date -Format "dd/MM/yyyy HH:mm"
#$ftpserver = "xxx.xxx.xxx.xxx"
#$ftpuser = "xxxxx"
#$ftppass = "xxxxx"
$ftpfilecomputer = $equipo + '_' + $usuario + '_computer' + '.csv'
$ftpfileuser = $equipo + '_' + $usuario + '_user' + '.csv'

##Certificados personales de equipo

if ( (Get-ChildItem -Force Cert:\LocalMachine\My) -ne $Null )
{
    #Si hay certificados personales de equipo
	$array = @()
	Get-ChildItem -Path Cert:\LocalMachine\My -recurse | 
    Where-Object {$_.PSISContainer -eq $false} | 
    foreach-object ({
    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name "Equipo" -Value $equipo
    $obj | Add-Member -MemberType NoteProperty -Name "Usuario" -Value $usuario
    $obj | Add-Member -MemberType NoteProperty -Name "Almacén personal" -Value "Equipo"
    $obj | Add-Member -MemberType NoteProperty -Name "Emitido para" -Value $_.Subject
    $obj | Add-Member -MemberType NoteProperty -Name "Emitido Por" -Value $_.Issuer
    $obj | Add-Member -MemberType NoteProperty -Name "Fecha de inicio" -Value $_.NotBefore
    $obj | Add-Member -MemberType NoteProperty -Name "Fecha de validez final" -Value $_.NotAfter
    $obj | Add-Member -MemberType NoteProperty -Name "Huella" -Value $_.Thumbprint
    $obj | Add-Member -MemberType NoteProperty -Name "Número de serie" -Value $_.SerialNumber
    $obj | Add-Member -MemberType NoteProperty -Name "DNS" -Value $_.DnsNameList
    $array += $obj
    $obj = $null
})

$contents = (($array | ConvertTo-Csv -NoTypeInformation) -join [Environment]::NewLine) + [Environment]::NewLine
$array | Export-Csv -Encoding UTF8 -NoTypeInformation -Append -Path "\\172.16.14.20\Certificados\$equipo.csv" -Force
#$client = New-Object System.Net.WebClient
#$client.Credentials = New-Object System.Net.NetworkCredential($ftpuser, $ftppass)
#$client.UploadString('ftp://' + $ftpserver + '/' + $ftpfilecomputer, $contents)


}
else
{
	#NO hay certificados personales de equipo
	$obj = @()
    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name "Equipo" -Value $equipo
    $obj | Add-Member -MemberType NoteProperty -Name "Usuario" -Value $usuario
    $obj | Add-Member -MemberType NoteProperty -Name "Almacén personal" -Value "Equipo"
    $obj | Add-Member -MemberType NoteProperty -Name "Emitido para" -Value ""
    $obj | Add-Member -MemberType NoteProperty -Name "Emitido Por" -Value ""
    $obj | Add-Member -MemberType NoteProperty -Name "Fecha de inicio" -Value $fecha
    $obj | Add-Member -MemberType NoteProperty -Name "Fecha de validez final" -Value ""
    $obj | Add-Member -MemberType NoteProperty -Name "Huella" -Value ""
    $obj | Add-Member -MemberType NoteProperty -Name "Número de serie" -Value ""
    $obj | Add-Member -MemberType NoteProperty -Name "DNS" -Value ""

	$contents = (($obj | ConvertTo-Csv -NoTypeInformation) -join [Environment]::NewLine) + [Environment]::NewLine
    $obj | Export-Csv -Encoding UTF8 -NoTypeInformation -Append -Path "\\172.16.14.20\Certificados\$equipo.csv" -Force
	#$client = New-Object System.Net.WebClient
	#$client.Credentials = New-Object System.Net.NetworkCredential($ftpuser, $ftppass)
	#$client.UploadString('ftp://' + $ftpserver + '/' + $ftpfilecomputer, $contents)

}

##Certificados personales de usuario

if ( (Get-ChildItem -Force Cert:\CurrentUser\My) -ne $Null )
{
    #Si hay certificados personales de usuario
	$array = @()
	Get-ChildItem -Path Cert:\CurrentUser\My -recurse | 
    Where-Object {$_.PSISContainer -eq $false} | 
    foreach-object ({
    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name "Equipo" -Value $equipo
    $obj | Add-Member -MemberType NoteProperty -Name "Usuario" -Value $usuario
    $obj | Add-Member -MemberType NoteProperty -Name "Almacén personal" -Value "Usuario"
    $obj | Add-Member -MemberType NoteProperty -Name "Emitido para" -Value $_.Subject
    $obj | Add-Member -MemberType NoteProperty -Name "Emitido Por" -Value $_.Issuer
    $obj | Add-Member -MemberType NoteProperty -Name "Fecha de inicio" -Value $_.NotBefore
    $obj | Add-Member -MemberType NoteProperty -Name "Fecha de validez final" -Value $_.NotAfter
    $obj | Add-Member -MemberType NoteProperty -Name "Huella" -Value $_.Thumbprint
    $obj | Add-Member -MemberType NoteProperty -Name "Número de serie" -Value $_.SerialNumber
    $obj | Add-Member -MemberType NoteProperty -Name "DNS" -Value $_.DnsNameList
    $array += $obj
    $obj = $null
})

$contents = (($array | ConvertTo-Csv -NoTypeInformation) -join [Environment]::NewLine) + [Environment]::NewLine
$array | Export-Csv -Encoding UTF8 -NoTypeInformation -Append -Path "\\172.16.14.20\Certificados\$usuario.csv" -Force
#$client = New-Object System.Net.WebClient
#$client.Credentials = New-Object System.Net.NetworkCredential($ftpuser, $ftppass)
#$client.UploadString('ftp://' + $ftpserver + '/' + $ftpfileuser, $contents)


}
else
{
	#NO hay certificados personales de usuario
	$obj = @()
    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name "Equipo" -Value $equipo
    $obj | Add-Member -MemberType NoteProperty -Name "Usuario" -Value $usuario
    $obj | Add-Member -MemberType NoteProperty -Name "Almacén personal" -Value "Usuario"
    $obj | Add-Member -MemberType NoteProperty -Name "Emitido para" -Value ""
    $obj | Add-Member -MemberType NoteProperty -Name "Emitido Por" -Value ""
    $obj | Add-Member -MemberType NoteProperty -Name "Fecha de inicio" -Value $fecha
    $obj | Add-Member -MemberType NoteProperty -Name "Fecha de validez final" -Value ""
    $obj | Add-Member -MemberType NoteProperty -Name "Huella" -Value ""
    $obj | Add-Member -MemberType NoteProperty -Name "Número de serie" -Value ""
    $obj | Add-Member -MemberType NoteProperty -Name "DNS" -Value ""
	
	$contents = (($obj | ConvertTo-Csv -NoTypeInformation) -join [Environment]::NewLine) + [Environment]::NewLine

    $obj | Export-Csv -Encoding UTF8 -NoTypeInformation -Append -Path "\\172.16.14.20\Certificados\$usuario.csv" -Force
	#$client = New-Object System.Net.WebClient
	#$client.Credentials = New-Object System.Net.NetworkCredential($ftpuser, $ftppass)
	#$client.UploadString('ftp://' + $ftpserver + '/' + $ftpfileuser, $contents)

}
