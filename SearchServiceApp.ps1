﻿#Set the primary and replica index locations
$PrimaryIndexLocation = "O:\SearchIndex"
$ReplicaIndexLocation = "P:\SearchIndexReplica"
 
#Prepare Index Locations
Remove-Item -Recurse -Force -LiteralPath $PrimaryIndexLocation -ErrorAction SilentlyContinue
MKDIR -Path $PrimaryIndexLocation -Force
Remove-Item -Recurse -Force -LiteralPath $ReplicaIndexLocation -ErrorAction SilentlyContinue
MKDIR -Path $ReplicaIndexLocation -Force
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
 
#Region Config_Parameters
#Settings for Search Service Application
$SearchServiceApplicationName = "Search Service Application"
$SearchServiceApplicationProxyName = "Search Service Application Proxy"
$SearchAppPoolAccount = "AD\NPF1A0005b8SPAFarm"
$SearchDatabaseServer = "agl-sppre-d.ad.ing.net"
$SearchServiceApplicationDatabase = "Search Service DB"
$SearchAppPoolName = "Service Application Admin App Pool"
 
#Farm Server topology: App with Search role: 2
$SearchAppServer1 = "sx9000080724"
$SearchAppServer2 = "sx9000080726"
 
#Set the primary and replica index locations
$PrimaryIndexLocation = "O:\SearchIndex"
$ReplicaIndexLocation = "P:\SearchIndexReplica"
#EndRegion
 
 
#*** Step 1: Create Managed Account, Service Application Pool for Search Service Application **** 
#Check if Managed account is registered already
Write-Host -ForegroundColor Yellow "Checking if the Managed Accounts already exists..."
$SearchAppPoolAccount = Get-SPManagedAccount -Identity $SearchAppPoolAccount -ErrorAction SilentlyContinue
If ($SearchAppPoolAccount -eq $null)
{
    Write-Host "Please Enter the password for the Service Account..."
    $AppPoolCredentials = Get-Credential $SearchAppPoolAccount
    $SearchAppPoolAccount = New-SPManagedAccount -Credential $AppPoolCredentials
    write-host "Managed Account has been Created!" -ForegroundColor Green
}
 
#Try to Get the existing Application Pool
Write-Host -ForegroundColor Yellow "Checking if the App Pool already exists..."
$SearchServiceAppPool = Get-SPServiceApplicationPool -Identity $SearchAppPoolName -ErrorAction SilentlyContinue
#If Application pool Doesn't exists, Create it
if ($SearchServiceAppPool -eq $Null)
{ 
    $SearchServiceAppPool = New-SPServiceApplicationPool -Name $SearchAppPoolName -Account $SearchAppPoolAccount
    write-host "Created New Service Application Pool!" -ForegroundColor Green
}
 
#*** Step 2: Start Search Service Instances on required servers ***
Write-host "Starting Service Instances..." -ForegroundColor Green
#Search App Server 1
$SearchAppInstance1 = Get-SPEnterpriseSearchServiceInstance $SearchAppServer1
if(-not($SearchAppInstance1.Status -eq "Online"))
{
    Write-Host -ForegroundColor Yellow "Starting Search Service instance on $SearchAppServer1..." -NoNewline
    $SearchAppInstance1 | Start-SPEnterpriseSearchServiceInstance
    while ($SearchAppInstance1.Status -ne "Online")
    {
        Write-Host -ForegroundColor Green "." -NoNewline
        Start-Sleep -Seconds 5
        $SearchAppInstance1 = Get-SPEnterpriseSearchServiceInstance $SearchAppServer1
    }
    Write-Host -ForegroundColor Green "Started Search Service instance on $SearchAppServer1"
}
Start-SPEnterpriseSearchQueryAndSiteSettingsServiceInstance $SearchAppServer1 -ErrorAction SilentlyContinue
 
#Search App Server 2
$SearchAppInstance2 = Get-SPEnterpriseSearchServiceInstance $SearchAppServer2
if(-not($SearchAppInstance2.Status -eq "Online"))
{
    Write-Host -ForegroundColor Yellow "Starting Search Service instance on $SearchAppServer2..." -NoNewline
    $SearchAppInstance2 | Start-SPEnterpriseSearchServiceInstance
    while ($SearchAppInstance2.Status -ne "Online")
    {
        Write-Host -ForegroundColor Green "." -NoNewline
        Start-Sleep -Seconds 5
        $SearchAppInstance2 = Get-SPEnterpriseSearchServiceInstance $SearchAppServer2
    }
    Write-Host -ForegroundColor Green "Started Search Service instance on $SearchAppServer2"
}
Start-SPEnterpriseSearchQueryAndSiteSettingsServiceInstance $SearchAppServer2 -ErrorAction SilentlyContinue
 
#*** Step 3: Create Search Service Application and proxy**** 
Write-host "Creating Search Service Application..." -ForegroundColor Yellow
# Get the Search Service Application
$SearchServiceApplication = Get-SPEnterpriseSearchServiceApplication -Identity $SearchServiceApplicationName -ErrorAction SilentlyContinue
# Create the Search Service Application, If it doesn't exist! 
if(!$SearchServiceApplication)
{
    $SearchServiceApplication = New-SPEnterpriseSearchServiceApplication -Name $SearchServiceApplicationName -ApplicationPool $SearchServiceAppPool -DatabaseServer $SearchDatabaseServer -DatabaseName $SearchServiceApplicationDatabase
    write-host "Created New Search Service Application" -ForegroundColor Green
}
 
#Get the Search Service Application Proxy
$SearchServiceAppProxy = Get-SPEnterpriseSearchServiceApplicationProxy -Identity $SearchServiceApplicationProxyName -ErrorAction SilentlyContinue
# Create the Proxy If it doesn't exist! 
if(!$SearchServiceAppProxy)
{
    $SearchServiceAppProxy = New-SPEnterpriseSearchServiceApplicationProxy -Name $SearchServiceApplicationProxyName -SearchApplication $SearchServiceApplication
    write-host "Created New Search Service Application Proxy" -ForegroundColor Green
}
 
#*** Step 4: Create New Search Topology and add components to it
Write-Host -ForegroundColor Yellow "Creating Search Service Topology..."
# Create New Search Topology 
$SearchTopology =  New-SPEnterpriseSearchTopology -SearchApplication $SearchServiceApplication
 
#Admin Component: App 01 and 02
New-SPEnterpriseSearchAdminComponent -SearchTopology $SearchTopology -SearchServiceInstance $SearchAppInstance1
New-SPEnterpriseSearchAdminComponent -SearchTopology $SearchTopology -SearchServiceInstance $SearchAppInstance2
 
#Content Processing: App 01 and 02
New-SPEnterpriseSearchContentProcessingComponent -SearchTopology $SearchTopology -SearchServiceInstance $SearchAppInstance1
New-SPEnterpriseSearchContentProcessingComponent -SearchTopology $SearchTopology -SearchServiceInstance $SearchAppInstance2
 
#Analytics processing: App01 and 02
New-SPEnterpriseSearchAnalyticsProcessingComponent -SearchTopology $SearchTopology -SearchServiceInstance $SearchAppInstance1
New-SPEnterpriseSearchAnalyticsProcessingComponent -SearchTopology $SearchTopology -SearchServiceInstance $SearchAppInstance2
 
#Crawl components: App 01 and 02
New-SPEnterpriseSearchCrawlComponent -SearchTopology $SearchTopology -SearchServiceInstance $SearchAppInstance1
New-SPEnterpriseSearchCrawlComponent -SearchTopology $SearchTopology -SearchServiceInstance $SearchAppInstance2
 
#Query processing: App 01 and 02
New-SPEnterpriseSearchQueryProcessingComponent -SearchTopology $SearchTopology -SearchServiceInstance $SearchAppInstance1
New-SPEnterpriseSearchQueryProcessingComponent -SearchTopology $SearchTopology -SearchServiceInstance $SearchAppInstance2
 
#Create Index Components: App 01 and 02
#Two index partitions and replicas for each partition
New-SPEnterpriseSearchIndexComponent -SearchTopology $SearchTopology -SearchServiceInstance $SearchAppInstance1 -RootDirectory $PrimaryIndexLocation -IndexPartition 0
New-SPEnterpriseSearchIndexComponent -SearchTopology $SearchTopology -SearchServiceInstance $SearchAppInstance2 -RootDirectory $ReplicaIndexLocation -IndexPartition 0
New-SPEnterpriseSearchIndexComponent -SearchTopology $SearchTopology -SearchServiceInstance $SearchAppInstance2 -RootDirectory $PrimaryIndexLocation -IndexPartition 1
New-SPEnterpriseSearchIndexComponent -SearchTopology $SearchTopology -SearchServiceInstance $SearchAppInstance1 -RootDirectory $ReplicaIndexLocation -IndexPartition 1
 
#Activate the Topology for Search Service
$SearchTopology.Activate() # Or Use: Set-SPEnterpriseSearchTopology -Identity $SearchTopology
 
#Remove all inactive topologies
$InactiveTopologies = Get-SPEnterpriseSearchTopology -SearchApplication $SearchServiceApplication | Where {$_.State -ne "Active"}
$InactiveTopologies | Remove-SPEnterpriseSearchTopology -Confirm:$false
 