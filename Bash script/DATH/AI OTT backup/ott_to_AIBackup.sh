#!/bin/bash -x

Log_Dir="/NAS_INGEST01/cms/fake/log_send_to_AI_backup"
DATE=`date +%Y%m`
OttCdnPath="/NAS_INGEST01/cdn/ott_rvod/*"
AssetInstaller_Backup="/NAS_INGEST01/cdn/ott_rvod_backup"
OTT="m3u8"

mkdir -p ${Log_Dir}

function print_log {
	echo "`date +%F_%T` $1" >> $Log_Dir/`date +%F`_ott_to_AIBackup.log
}

function move_ott_file_to_AIBackup {

	print_log "::::::::::move_ott_file_to_AIBackup start::::::::::"

	for m3u8 in `ls $OttCdnPath | grep $OTT`
	do
		# m3u8 ex) 2015_4.m3u8 2015_5.m3u8
		# Asset_ID ex) 2015
		# Asset_File ex) 2015_4 2015_5
		Asset_ID=`echo $m3u8 | cut -d'_' -f1`
		Asset_File=`echo $m3u8 | cut -d'.' -f1`

		if ! [ -f ${AssetInstaller_Backup}/${Asset_ID}/${m3u8} ]
		then
			mv ${OttCdnPath}/${Asset_File} ${AssetInstaller_Backup}/${Asset_ID}/
			print_log "mv ${OttCdnPath}/${Asset_File} ${AssetInstaller_Backup}/${Asset_ID}/"
			mv ${OttCdnPath}/${m3u8} ${AssetInstaller_Backup}/${Asset_ID}/
			print_log "mv ${OttCdnPath}/${m3u8} ${AssetInstaller_Backup}/${Asset_ID}/"
		else
			if [ `stat -c %s $AssetInstaller_Backup/$Asset_ID/$m3u8` -eq 0 ];then

				#rm -rf ${AssetInstaller_Backup}/$Asset_ID/$Asset_File
				print_log "test line : rm -rf ${AssetInstaller_Backup}/$Asset_ID/$Asset_File"
				mv ${OttCdnPath}/${Asset_File} ${AssetInstaller_Backup}/${Asset_ID}/
				print_log "mv ${OttCdnPath}/${Asset_File} ${AssetInstaller_Backup}/${Asset_ID}/"

				mv ${OttCdnPath}/${m3u8} ${AssetInstaller_Backup}/${Asset_ID}/
				print_log "mv ${OttCdnPath}/${m3u8} ${AssetInstaller_Backup}/${Asset_ID}/"
			else
				print_log "Already $Asset_ID in AssetInstaller_Backup"
			fi
		fi
	done
}

print_log "========================================================================================="
move_ott_file_to_AIBackup
