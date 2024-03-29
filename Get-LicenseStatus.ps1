    ###################################################################################
    # Autor: Jose Antonio Frutos
    # Date: 05/04/2022
    # Version v1
    ###################################################################################
    
    Get-CimInstance -ClassName SoftwareLicensingProduct -ComputerName "HPS" |` 
    Where{$_.PartialProductKey -and $_.Name -like "*Windows*"} | Select ` 
    @{Expression={$_.PSComputerName};Name="ComputerName"},` 
    @{Expression={$_.Name};Name="WindowsName"} ,"ApplicationID",` 
    @{Expression={$LicenseStatus[$($_.LicenseStatus)]};Name="LicenseStatus"} 