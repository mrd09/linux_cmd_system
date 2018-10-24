#!/bin/bash

read -p "Enter port of tomcat: " port

#1.Stop Service
 GETPID=$(netstat -anp | grep "$port" | grep LISTEN | awk '{print $7}' | cut -d '/' -f1 | awk '!a[$0]++' | awk '{print}' ORS=' ') && echo "The process ID is: $GETPID";

 if [ -z $GETPID ]; 
  then 
    echo "This process is not running"
  else kill -9 $GETPID && echo "This process has been killed" && echo "I've check the netstat again and result is: `netstat -anp | grep "$port"` ";fi
echo "---------------"

#2. Remove all in folder /castis/.../cms
cd /castis/bin/CMSAdmin/cms && echo "Inside folder: `ls -lrt`"
echo "---------------"

while true; do
 read -p "Did you check the ls result? If yes I will continue to rm all?  " yn
 case $yn in
     [Yy]* ) rm -rf /castis/bin/CMSAdmin/cms/*;;
     [Nn]* ) exit;;
     * ) echo "Please answer yes or no.";;
 esac
 break
done

echo "----------------"
#3. Copy war file to folder, then change extension from .war to .zip

while [ -z "$(ls -A /castis/bin/CMSAdmin/cms/)"]; do
 read -p "Did you copy the war file? Also don’t forget to update your DB first!  " yn
 case $yn in
     [Yy]* ) cd /castis/bin/CMSAdmin/cms && mv CMS-Viettel.war CMS-Viettel.zip && echo "----------------" && echo "Inside folder: `ls -lrt`";;
     [Nn]* ) exit;;
     * ) echo "Please answer yes or no.";;
 esac
done

echo "----------------"
#4. unzip CMS-Viettel.zip
unzip CMS-Viettel.zip &
wait $!
echo "Unzip done";
echo "----------------"
#5. find and replace string in log4j
find /castis/bin/CMSAdmin/cms -type f -name log4j.xml -exec sed -i 's/console/file/g' {} \; && echo "Check the changing. True if empty: `cat /castis/bin/CMSAdmin/cms/WEB-INF/classes/log4j.xml | grep console`"
find /castis/bin/CMSAdmin/cms -type f -name log4j.xml -exec sed -i 's/cms_log/cms_log_live/g' {} \; && echo "Check the changing: `cat /castis/bin/CMSAdmin/cms/WEB-INF/classes/log4j.xml | grep cms_log_live`"
echo "Change output log done"
echo "----------------"
#6. start service
echo "Service is starting: `/bin/sh /castis/bin/tomcat_cms_live/bin/./startup.sh`" &&
echo "Port to check service: $port" && sleep 2s &&
echo "Check service: `netstat -anp | grep "$port"` "
