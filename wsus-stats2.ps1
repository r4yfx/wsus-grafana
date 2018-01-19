<#
        .SYNOPSIS
        Windows Update Server Script
  
        .DESCRIPTION
        WSUS Statistic script in which it pulls the data and then t will then convert them into JSON, ready to add into InfluxDB and show it with Grafana
	
        .Notes
        NAME:  wsus-stats.ps1
        ORIGINAL NAME: wsus.ps1
        LASTEDIT: 15/01/2018
        VERSION: 0.1
        KEYWORDS: WSUS, Grafana 
   
        .Link
        https://docs.microsoft.com/en-us/powershell/module/wsus/?view=win10-ps
        https://devhub.io/repos/proxb-PoshWSUS
 
 #Requires PS -Version 3.0
 #Requires -Modules PoshWSUS
 #Requires -Modules WSUS    
 #>

Import-Module PoshWSUS
$script:Wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer()


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


#region: JSON Output for Telegraf
Write-Host "{" 
$Count = $clienthostswina.Count
Write-Host "`"Windows Server 2012 R2`"": "$Count,"
$Count = $clienthostswinb.Count
Write-Host "`"Windows Server 2008 R2 Datacenter Edition`"": "$Count,"
$Count = $clienthostswinc.Count
Write-Host "`"Windows Server 2008 R2 Standard Edition`"": "$Count,"
$Count = $clienthostswind.Count
Write-Host "`"Windows Server 2012`"": "$Count,"
$Count = $wsusupdatea.Count
Write-Host "`"Critical Updates`"": "$Count,"
$Count = $wsusupdateb.Count
Write-Host "`"Updates`"": "$Count,"
$Count = $wsusupdatec.Count
Write-Host "`"Service Packs`"": "$Count,"
$Count = $client.Count
Write-Host "`"Number of Clients`"": "$Count,"
$Count = $wsusneed.Count
Write-Host "`"Req-Updates`"": "$Count,"
$Count = $wsusfailed.Count
Write-Host "`"Failed`"": "$Count,"
$Count = $wsusreboot.Count
Write-Host "`"Req-Reboot`"": "$Count,"
Write-Host "}" 

#endregion
