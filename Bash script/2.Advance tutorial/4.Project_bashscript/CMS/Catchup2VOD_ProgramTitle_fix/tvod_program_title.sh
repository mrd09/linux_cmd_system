#!/bin/bash

#Log
logFolder="/home/vt_admin/tvod_program_title_fix"
mkdir -p ${logFolder}

# DB Live Variable

#user="cmsuser"
#password='castis!cms!@#'
#dbIp="172.23.40.6"
#dbName="cms"

# DB Test Variable

user="root"
password='castis'
dbIp="10.60.70.200"
dbName="cms_1_8_live"

# Function Print Log
function print_log { 
	echo "[`date +"%Y-%m-%d-%H:%M:%S"`] $1" >> ${logFolder}/$(date +%d-%m-%Y)_tvod_program_title.log
}

# Compare Variable
sql_replace=$(mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "select count(ProgramTitle) from tvodepgadiinfo where ProgramTitle like '%\'%';")

# Script 

if [[ ${sql_replace} != 0 ]]; then
	print_log "There is ${sql_replace} TVOD records has apostrophe in DB cms"
	`mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "update tvodepgadiinfo set ProgramTitle = REPLACE (ProgramTitle, '\'', '') WHERE ProgramTitle like '%\'%';"`
		if [[ $? == 0 ]]; then
			print_log "Replace Query OK"
		else print_log "Replace Query Fail"; fi
	else print_log "There is No TVOD Program has apostrophe in CMS"; fi

