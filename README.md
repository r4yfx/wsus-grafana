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
* https://poshwsus.codeplex.com/ - PoshWSUS Module
* https://portal.influxdata.com/downloads - Telegraf
* https://grafana.com/ - Grafana
* https://github.com/jorgedlcruz/veeam_grafana - Veeam Grafana

Special Thanks
--------------
This script wouldn't have been possible without the PoshWSUS module and also Jorge de la Cruz for his veeam-grafana script in which I was able to template my work on. 

Features of the Script
----------------------
* Gathers Client information gives a count on each
* Provides Update information and count on each (Critical/Updates/Services Packs)
* Provides informaton on how many machines require updates, reboots, failed updates


Installation
-------------
Please read the installation documention on how to install this script


Feature Requests & Contribute
-----------------------------
Please feel free to request any additional features and if you wish to contribute I am more than happy for that to happen. 
