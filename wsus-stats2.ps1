<#
        .SYNOPSIS
        Windows Update Server Script
  
        .DESCRIPTION
        WSUS Statistic script in which it pulls the data and then t will then convert them into JSON, ready to add into InfluxDB and show it with Grafana
	
        .Notes
        NAME:  wsus-stats.ps1
        ORIGINAL NAME: wsus.ps1
        LASTEDIT: 19/01/2018
        VERSION: 0.3
        KEYWORDS: WSUS, Grafana 
   
        .Link
        https://docs.microsoft.com/en-us/powershell/module/wsus/?view=win10-ps
        https://devhub.io/repos/proxb-PoshWSUS
 
 #Requires PS -Version 3.0
 #Requires -Modules PoshWSUS
 #Requires -Modules WSUS    
 #>

Import-Module PoshWSUS
Connect-PSWSUSServer | Out-Null

#region: Data Collecting
# Collect Client Information
$client = Get-PSWSUSClient

# Collect Group Information
$wsusgroup = Get-PSWSUSGroup

# Collect Update Summary per Client
$updatesummary = Get-PSWSUSUpdateSummaryPerClient
$wsusupdates = Get-WsusUpdate

#endregion


#region: Preparing Client Information
$clienthostswina = @($client | ?{$_.OSDescription -eq "Windows Server 2012 R2"})
$clienthostswinb = @($client | ?{$_.OSDescription -eq "Windows Server 2008 R2 Datacenter Edition"})
$clienthostswinc = @($client | ?{$_.OSDescription -eq "Windows Server 2008 R2 Standard Edition"})
$clienthostswind = @($client | ?{$_.OSDescription -eq "Windows Server 2012"})
$clienthostswine = @($client | ?{$_.OSDescription -eq "Windows 7"}) 

#endregion

#region: Preparing Update Information
$wsusupdatea = @($wsusupdates | ?{$_.Classification -eq "Critical Updates"})
$wsusupdateb = @($wsusupdates | ?{$_.Classification -eq "Updates"})
$wsusupdatec = @($wsusupdates | ?{$_.Classification -eq "Service Packs"})

#endregion

#region: Summary of Updates
$wsusneed = @($updatesummary | ?{$_.Needed -ge 1})
$wsusfailed = @($updatesummary | ?{$_.Failed -ge 1})
$wsusreboot = @($updatesummary | ?{$_.PendingReboot -ge 1})

#region: Prepare all Groups
$wsusvtec = Get-WsusComputer -ComputerTargetGroups 4_VTEC
$wsusmgmt = Get-WsusComputer -ComputerTargetGroups 0_Management
$wsusutila = Get-WsusComputer -ComputerTargetGroups 1_Utilita
$wsusoceana = Get-WsusComputer -ComputerTargetGroups 97_Oceana
$wsusnewdaya = Get-WsusComputer -ComputerTargetGroups 8_Newday-Test
$wsushome = Get-WsusComputer -ComputerTargetGroups 12_HomeBase
$wsusinsightt = Get-WsusComputer -ComputerTargetGroups 0_Insight-Test
$wsusutilb = Get-WsusComputer -ComputerTargetGroups 11_Utilita2
$wsusfc = Get-WsusComputer -ComputerTargetGroups 3_FlightCentre
$wsusinsightp = Get-WsusComputer -ComputerTargetGroups 0_Insight-Prod
$wsusnewdayd = Get-WsusComputer -ComputerTargetGroups 9_Newday-Dev
$wsusjourney = Get-WsusComputer -ComputerTargetGroups 14_JourneyCall
$wsusswift = Get-WsusComputer -ComputerTargetGroups 13_Swift
$wsusasra = Get-WsusComputer -ComputerTargetGroups 6_ASRA
$wsusdemo = Get-WsusComputer -ComputerTargetGroups 99_Demo
$wsusnewdayp = Get-WsusComputer -ComputerTargetGroups 7_Newday-Prod
$wsusdx = Get-WsusComputer -ComputerTargetGroups 2_DX
$wsusverint = Get-WsusComputer -ComputerTargetGroups 0_Verint-Bundle3

#endregion

#region: # InfluxDB Output for Telegraf
 
$Count = $clienthostswina.Count
$body="wsus-stats windows2012r2=$Count"
Write-Host $body 
$Count = $clienthostswinb.Count
$body="wsus-stats windows2008r2dced=$Count"
Write-Host $body 
$Count = $clienthostswinc.Count
$body="wsus-stats windows2008stded=$Count"
Write-Host $body
$Count = $clienthostswind.Count
$body="wsus-stats windows2012=$Count"
Write-Host $body
$Count = $clienthostswine.Count
$body="wsus-stats windows7=$Count"
Write-Host $body
$Count = $wsusupdatea.Count
$body="wsus-stats criticalupdates=$Count"
Write-Host $body
$Count = $wsusupdateb.Count
$body="wsus-stats updates=$Count"
Write-Host $body
$Count = $wsusupdatec.Count
$body="wsus-stats sp=$Count"
Write-Host $body
$Count = $client.Count
$body="wsus-stats numberofclients=$Count"
Write-Host $body
$Count = $wsusneed.Count
$body="wsus-stats requpdates=$Count"
Write-Host $body
$Count = $wsusfailed.Count
$body="wsus-stats failed=$Count"
Write-Host $body
$Count = $wsusreboot.Count
$body="wsus-stats reqreboot=$Count"
Write-Host $body


#endregion
