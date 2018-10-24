#!/bin/bash

#Apps Folder and Execute bin Folder

#Test
#Exbin="/castis/bin/tomcat_cms_test/bin"
#AppsFol="/home/dath/test"
#ConfFol="/home/dath/test/conf/cms-config"

#Live
Exbin="/castis/bin/tomcat_cms/bin"
AppsFol="/castis/bin/tomcat_cms/webapps"
ConfFol="/castis/bin/tomcat_cms/conf/cms-config"


#Function

function test_AppsFol() {
	while [ -z "`ls -A ${AppsFol} | grep $1`" ]; do echo "Please copy the war file to server"
        done
}

function test_ConfFol() {
	while [ -z "`ls -A ${ConfFol} | grep $1`" ]; do echo "Please provide the config file to server"
        done
}

# Script Body to stop service, get the value from variable: $fileName, $Config, remind to update DB

while [ -z $port ]; do
read -p "Enter port of tomcat testbed: 18082: " port
done

#1.Stop Service
 GETPID=$(netstat -anp | grep "$port" | grep LISTEN | awk '{print $7}' | cut -d '/' -f1 | awk '!a[$0]++' | awk '{print}' ORS=' ') && echo "The process ID is: $GETPID";

 if [ -z $GETPID ]; 
  then 
    echo "This process is not running"
  else kill -9 $GETPID && echo "This process has been killed" && echo "I've check the netstat again and result is: `netstat -anp | grep "$port"` ";fi
echo "---------------"

#2. Get the value from $fileName, $Config
while [ -z ${fileName} ]; do
 read -p "Please provide the deploy's fileName: " fileName
done

while [ -z ${Config} ]; do
 read -p "Please provide the Config file name: " Config
done

#3. Remind to update DB
while true; do
 read -p "Have update your DB yet!?
 If done type: y, not done: n. Your choice: " yn
 case $yn in
     [Yy]* ) echo "Please continue";;
     [Nn]* ) exit;;
     * ) echo "Please answer yes or no.";;
 esac
 break
done

#4. Function to ln to new config and deploy new apps
test_ConfFol ${Config};

	cd ${ConfFol} && ln -sf ${ConfFol}/${Config} config.properties

test_AppsFol ${fileName};

	cd ${AppsFol} && rm -rf ${AppsFol}/CMSAdmin && ln -sf ${AppsFol}/${fileName} CMSAdmin.war

#5. start service

echo "Deploy done, Service is starting: `${Exbin}/startup.sh`" &&
echo "Port to check service: $port" && sleep 2s &&
echo "Check service: `netstat -anp | grep $port` "