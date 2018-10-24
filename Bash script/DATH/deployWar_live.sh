#!/bin/bash

#Variable
dateTime=`date +%F_%H-%M-%S`

#Test
CMSFol=/home/dath/castis/bin/CMSAdmin/cms
bakFolder=/home/dath/castis/bin/CMSAdmin/cms_bak/${dateTime}
CMSConf=/home/dath/castis/bin/CMSAdmin/cms-config
CMSExe=/home/dath/castis/bin/tomcat_cms_live/bin/startup.sh

#Live
#CMSFol=/castis/bin/CMSAdmin/cms
#bakFolder=/castis/bin/CMSAdmin/cms_bak/${dateTime}
#CMSConf=/castis/bin/CMSAdmin/cms-config
#CMSExe=/castis/bin/tomcat_cms_live/bin/startup.sh

mkdir -p ${bakFolder}

#Check service

while [ -z $port ]; do
read -p "Enter port of tomcat live test: 18084: " port
done

#1.Stop Service
 GETPID=$(netstat -anp | grep "$port" | grep LISTEN | awk '{print $7}' | cut -d '/' -f1 | awk '!a[$0]++' | awk '{print}' ORS=' ') && echo "The process ID is: ${GETPID}";

 if [ -z ${GETPID} ]; 
  then 
    echo "This process is not running"
  else kill -9 ${GETPID} && echo "This process has been killed" && echo "I've check the netstat again and result is: `netstat -anp | grep "$port"` ";fi
echo "---------------"

#2. Backup CMS folder /castis/.../cms
cd ${CMSFol} && echo "Inside folder: `ls -lrt`"
echo "---------------"

echo "I will backup the CMS in /castis/bin/CMSAdmin/cms"
mv ${CMSFol} ${bakFolder}/
mkdir -p ${CMSFol}

#3. Copy zip file to folder
while [ -z "`ls -A ${CMSFol}`" ]; do echo "Please provide the zip file to server"
done

while [[ ! `ls -A ${CMSFol} | grep .zip` =~ \.zip$ ]]; do echo "Please recheck the file: The extension must be .zip"
done
echo "----------------"

#4. unzip CMS-Viettel.zip
zipFile=${CMSFol}/*.zip

current=`date +%s`
last_modified=`stat -c "%Y" $zipFile`

while [[ ! $(($current-$last_modified)) -gt 30 ]]; do
	unset current && unset last_modified
        echo "Please wait to copy file"
	current=`date +%s`
	last_modified=`stat -c "%Y" $zipFile`
done

cd ${CMSFol} && unzip ${zipFile} &
wait $!
echo "Unzip done";
echo "----------------"

#5. Change CMS Config
while [[ -z ${ConfName} ]]; do
	 read -p "Please provide the config.properties's fileName: format: config.properties.v1.X.X: " ConfName
done

cd ${CMSConf} && cp ${CMSConf}/config.properties ${CMSConf}/${ConfName}

while true; do
	 read -p "Please modify the config file ${ConfName} if needed?
	  If done type: y, not done: n. Your choice: " yn
	   case $yn in
	        [Yy]* ) break;;
		    * ) echo "Please modify and type y to exit.";;
           esac
	   #break
done


#6 [Optional]. find and replace string in log4j
find ${CMSFol} -type f -name log4j.xml -exec sed -i 's/console/file/g' {} \; && echo "Check the changing. True if empty: `cat ${CMSFol}/WEB-INF/classes/log4j.xml | grep console`"
find ${CMSFol} -type f -name log4j.xml -exec sed -i 's/cms_log/cms_log_live/g' {} \; && echo "Check the changing: `cat ${CMSFol}/WEB-INF/classes/log4j.xml | grep cms_log_live`"
echo "Change output log done"
echo "----------------"

#7. start service
#echo "Service is starting: `/bin/sh /castis/bin/tomcat_cms_live/bin/startup.sh`" &&
echo "Service is starting: ${CMSExe}" &&
echo "Port to check service: $port" && sleep 2s &&
echo "Check service: `netstat -anp | grep "$port"` "
