-- Fill in the Mediaverify and ffprobe information parse, just need to fill in the fileName

UPDATE mediaverify SET fileSize = '26348462', displayRuntime = '31', muxRate = '6439600', videoType ='h264', audioType='aac', bitrateType='CBR', resolutionStandard='HD', resolution='1920x1080', bitrate='6595', AlreadyEncodedAvailable='Y' WHERE mediaverify.fileName LIKE '%khoahung%';