<#
        .SYNOPSIS
        Windows Update Server Script
  
        .DESCRIPTION
        WSUS Statistic script in which it pulls the data and then t will then convert them into JSON, ready to add into InfluxDB and show it with Grafana
	
        .Notes
        NAME:  wsus-stats.ps1
        ORIGINAL NAME: wsus.ps1
        LASTEDIT: 28/02/2022
        VERSION: 0.4
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


#region: Client Information
foreach ($os in ($client | Select-Object -ExpandProperty OSDescription -Unique | Sort-Object)) {
        $osString = switch ($os) {
             'Windows (Version 10.0)' {'windows10'}
             'Windows 10 Enterprise'  {'windows10ent'}
             {$_ -match 'Windows 10 Pro'} {'windows10pro'}
             'Windows (Version 11.0)' {'windows11'}
             'Windows 10 Enterprise'  {'windows11ent'}
             {$_ -match 'Windows 11 Pro'} {'windows11pro'}
             'Windows Server 2012' {'windows2012'}
             'Windows Server 2012 R2' {'windows2012r2'}
             'Windows Server 2016 Standard' {'windows2016'}
             'Windows Server 2016 Datacenter' {'windows2016dc'}
             'Windows Server 2019 Standard' {'windows2019'}
             'Windows Server 2019 Datacenter' {'windows2019dc'}
             'Windows Server 2022 Standard' {'windows2022'}
             'Windows Server 2022 Datacenter' {'windows2022dc'}
             Default {$_ -replace "\s" -replace 'server'} # should handle most cases where OSver not in above list
        }
        $osCount = ($client | Where-Object {$_.OSDescription -eq $os}).count
        Write-Host "wsus-stats $($osString)=$($osCount)"
}
#endregion

#region: Update Information
foreach ($wsusUpdateClassification in ($wsusupdates | Where-Object {$_.Classification -in @('Updates', 'Critical Updates', 'Service Packs')} | Select-Object -ExpandProperty Classification -Unique)) {
        $wsusUpdateCount = ($wsusupdates | Where-Object {$_.Classification -eq $wsusUpdateClassification}).Count
        $wsusClassificationString = $($wsusUpdateClassification -replace "\s").ToLower()
        Write-Host "wsus-stats $($wsusClassificationString)=$($wsusUpdateCount)"
}
#endregion

#region: Summary of Updates
$wsusneed = @($updatesummary | ?{$_.Needed -ge 1})
$wsusfailed = @($updatesummary | ?{$_.Failed -ge 1})
$wsusreboot = @($updatesummary | ?{$_.PendingReboot -ge 1})


#region: # InfluxDB Output for Telegraf
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