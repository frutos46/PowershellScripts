####################################################################################
# Autor: Jose Antonio Frutos
# Version: v1
# Creado: 08/03/2022
# Script: Desinstala tanto el flash como IE11
####################################################################################


New-Item C:\tmp -ItemType Directory -Force

Invoke-WebRequest -Uri 'https://fpdownload.macromedia.com/get/flashplayer/current/support/uninstall_flash_player.exe' -OutFile 'c:\tmp\uninstall_flash_player.exe'

c:\tmp\uninstall_flash_player.exe -uninstall



Remove-Item -Path "c:\tmp\uninstall_flash_player.exe" 
Disable-WindowsOptionalFeature -FeatureName Internet-Explorer-Optional-amd64 –Online -NoRestart
