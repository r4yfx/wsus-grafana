<#
        .SYNOPSIS
        Windows Update Server Script
  
        .DESCRIPTION
        WSUS Statistic script in which it pulls the data and then t will then convert them into JSON, ready to add into InfluxDB and show it with Grafana
	
        .Notes
        NAME:  wsus-stats.ps1
        ORIGINAL NAME: wsus.ps1
        LASTEDIT: 19/01/2018
        VERSION: 0.2
        KEYWORDS: WSUS, Grafana 
   
        .Link
        https://docs.microsoft.com/en-us/powershell/module/wsus/?view=win10-ps
        https://devhub.io/repos/proxb-PoshWSUS
 
 #Requires PS -Version 3.0
 #Requires -Modules PoshWSUS
 #Requires -Modules WSUS    
 #>

Import-Module PoshWSUS
Connect-PSWSUSServer

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


#region: # InfluxDB Output for Telegraf
 
$Count = $clienthostswina.Count
$body="Windows Server 2012 R2=$Count"
Write-Host $body 
$Count = $clienthostswinb.Count
$body="Windows Server 2008 R2 Datacenter Edition=$Count"
Write-Host $body 
$Count = $clienthostswinc.Count
$body="Windows Server 2008 R2 Standard Edition=$Count"
Write-Host $body
$Count = $clienthostswind.Count
$body="Windows Server 2012=$Count"
Write-Host $body
$Count = $clienthostswine.Count
$body="Windows 7=$Count"
Write-Host $body
$Count = $wsusupdatea.Count
$body="Critical Updates=$Count"
Write-Host $body
$Count = $wsusupdateb.Count
$body="Updates=$Count"
Write-Host $body
$Count = $wsusupdatec.Count
$body="Service Packs=$Count"
Write-Host $body
$Count = $client.Count
Write-Host "`"Number of Clients`"": "$Count,"
$body="Number of Clients=$Count"
Write-Host $body
$Count = $wsusneed.Count
$body="Req-Updates=$Count"
Write-Host $body
$Count = $wsusfailed.Count
$body="Failed=$Count"
Write-Host $body
$Count = $wsusreboot.Count
$body="Req-Reboot=$Count"
Write-Host $body


#endregion
