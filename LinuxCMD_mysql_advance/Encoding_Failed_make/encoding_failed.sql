
-- Create the Encoding Failed content, Just need to fill in the SubsetID

UPDATE `atemeencodingjobqueue` SET `state`='Encoding Failed' , `retryCount`='3' WHERE  `outputFileName` LIKE '%176716%';

UPDATE `contentasset` SET `stageCode`='10' WHERE `contentSubsetId` LIKE '%176716%';

UPDATE `contentsubset` SET `stageCode`='10' WHERE `contentSubsetId` LIKE '%176716%';

UPDATE `contentgroup` SET `stageCode`='10' WHERE `movieSubsetId` LIKE '%176716%';

UPDATE `offer` SET `stageCode`='10' WHERE `offerId` IN (SELECT `offerId` FROM `offercontentgroup` WHERE `contentGroupId` IN(SELECT `contentGroupId` FROM `contentgroup` WHERE `movieSubsetId` LIKE '%176716%'));


