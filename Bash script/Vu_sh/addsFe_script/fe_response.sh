#!/bin/sh

# 0 : OTT VOD
# 1 : OTT Catch-up
# 2 : OTT TimeShift
# 3 : STB VOD
# 4 : STB Catch-up
# 5 : STB TimeShift
requestType=$1
userId=$2

if [ $requestType -eq 0 ]
then
requestId=`curl -X POST -H "Content-Type: application/json" -H "X-Forwarded-For : 10.60.70.220" -d " \
	{ \
		\"version\":3, \
		\"regionId\":\"GUEST\", \
		\"assetId\":\"51_4\", \
		\"filename\":\"51_4.m3u8\", \
		\"userId\":\"${userId}\", \
		\"manifestType\":\"HLS\",
		\"userDeviceType\":\"HANDHELD\", \
		\"serviceProvider\":\"Joon\", \
		\"bwProfile\":\"5\", \
		\"categoryId\":\"VC_OTT\"
	}\
	" \
	http://10.60.70.201:18081/demandRequestId.json 2> /dev/null | cut -d'"' -f4`
elif [ $requestType -eq 1 ]
then
requestId=`curl -X POST -H "Content-Type: application/json" -H "X-Forwarded-For : 10.60.70.220" -d " \
	{ \
		\"version\":2,
	  \"regionId\":\"GUEST\",
	  \"assetId\":\"20171207160000_154_2168\",
	  \"clientIP\":\"10.60.67.239\",
	  \"filename\":\"20171207160000_154_2168.m3u8\",
	  \"manifestType\":\"HLS\",
		\"userId\":\"${userId}\", \
	  \"userDeviceType\":\"HANDHELD\",
	  \"channelId\":\"155\"  
	}\
        " \
        http://10.60.70.201:18081/demandRequestId.json 2> /dev/null | cut -d'"' -f4`
elif [ $requestType -eq 2 ]
then
requestId=`curl -X POST -H "Content-Type: application/json" -H "X-Forwarded-For : 10.60.70.220" -d " \
	{ \
		\"version\":2,
	  \"regionId\":\"GUEST\",
	  \"assetId\":\"154\",
	  \"clientIP\":\"10.60.67.239\",
	  \"filename\":\"154.m3u8\",
		\"userId\":\"${userId}\", \
	  \"manifestType\":\"HLS\",
	  \"userDeviceType\":\"HANDHELD\",
	  \"channelId\":\"154\"  
	}\
        " \
        http://10.60.70.201:18081/demandRequestId.json 2> /dev/null | cut -d'"' -f4`
elif [ $requestType -eq 3 ]
then
requestId=`curl -X POST -H "Content-Type: application/json" -H "X-Forwarded-For : 10.60.70.220" -d " \
	{ \
		\"version\":2, \
		\"regionId\":\"GUEST\", \
		\"assetId\":\"51_2\", \
		\"filename\":\"51_2.ts\", \
		\"userId\":\"${userId}\", \
		\"userDeviceType\":\"STB\", \
		\"categoryId\":\"VC\",
        \"serviceProvider\":\"VIETTEL\"
	}\
	" \
	http://10.60.70.201:18082/demandRequestId.json 2> /dev/null | cut -d'"' -f4`
elif [ $requestType -eq 4 ]
then
requestId=`curl -X POST -H "Content-Type: application/json" -H "X-Forwarded-For : 10.60.70.220" -d " \
	{ \
		\"version\":2, \
		\"regionId\":\"H004\", \
		\"assetId\":\"20171218165800_155_13482\", \
		\"filename\":\"20171218165800_155_13482.mpg\", \
		\"userId\":\"${userId}\", \
		\"userDeviceType\":\"STB\", \
		\"channelId\":\"154\"
	}\
	" \
	http://10.60.70.201:18082/demandRequestId.json 2> /dev/null | cut -d'"' -f4`
elif [ $requestType -eq 5 ]
then
requestId=`curl -X POST -H "Content-Type: application/json" -H "X-Forwarded-For : 10.60.70.220" -d " \
	{ \
		\"version\":2, \
		\"regionId\":\"H004\", \
		\"assetId\":\"4\", \
		\"filename\":\"4.mpg\", \
		\"userDeviceType\":\"STB\", \
		\"userId\":\"${userId}\", \
		\"userDeviceType\":\"STB\", \
		\"channelId\":\"4\"
	}\
	" \
	http://10.60.70.201:18082/demandRequestId.json 2> /dev/null | cut -d'"' -f4`
elif [ $requestType -eq 10 ]
then
requestId=`curl -X POST -H "Content-Type: application/json" -H "X-Forwarded-For : 10.60.70.220" -d " \
	{ \
		\"version\":2, \
		\"regionId\":\"H004\", \
		\"assetId\":\"4\", \
		\"filename\":\"4.mpg\", \
		\"userId\":\"TEST_1234\", \
		\"userDeviceType\":\"STB\", \
		\"channelId\":\"4\",
        \"bwProfile\":5
	}\
	" \
	http://10.60.70.201:18081/demandRequestId.json 2> /dev/null | cut -d'"' -f4`
fi

requestId=`echo -n "$requestId" | perl -MURI::Escape -ne 'print uri_escape($_)'`
#echo "==== Request GET http://10.60.70.228:18080/ADDSse/PlacementDecisionRequest/3.0?messageId=1234&requestId=${requestId}&resume=true"
#echo ""
sleep 1
echo $requestId
curl "http://10.60.70.228:18080/ADDSse/PlacementDecisionRequest/3.0?messageId=1234&requestId=${requestId}&resume=true" 2> /dev/null | python -mjson.tool

#echo ""
#echo ""
#echo ""
#echo ""
#echo ""
#echo ""
#echo ""
#echo ""
#echo ""
#echo ""
#echo "==== Request GET http://10.60.70.228:18080/ADDSse/DisplayAdDecisionRequest/1.0?messageId=f8098332-57fb-402d-9ce6-cf62b266334c&userId=user342&advPlatformType=STB&sceneId=STB.HOME&regionId=H004&limit=10"
#curl "http://10.60.70.228:18080/ADDSse/DisplayAdDecisionRequest/1.0?messageId=f8098332-57fb-402d-9ce6-cf62b266334c&userId=user342&advPlatformType=STB&sceneId=STB&regionId=H004" 2> /dev/null | python -mjson.tool
#echo "=== REQUEST GET http://10.60.70.228:18080/ADDSse/DisplayAdDecisionRequest/1.0?messageId=f8098332-57fb-402d-9ce6-cf62b266334c&userId=user342&advPlatformType=HANDHELD&sceneId=Mobile&regionId=H004"
#curl "http://10.60.70.228:18080/ADDSse/DisplayAdDecisionRequest/1.0?messageId=f8098332-57fb-402d-9ce6-cf62b266334c&userId=user342&advPlatformType=HANDHELD&sceneId=Mobile.PHONE" 2> /dev/null | python -mjson.tool
