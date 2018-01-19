# wsus-grafana
Windows Server Update Services - Importing this to Grafana

Thank you for taking the time and looking at this script.
The script is currently in development at the moment, but will extract data from WSUS server, locally and whilst using telegraf this will import the data into an infludb. 

Prerequisite
--------------
* Grafana
* Telegraf v1.5 running on the server
* WSUS Server - Running 2012 R2
* PoshWSUS Module
* Script to run locally on the WSUS Server

Links
-----
https://poshwsus.codeplex.com/ - PoshWSUS Module
https://portal.influxdata.com/downloads - Telegraf
https://grafana.com/ - Grafana
