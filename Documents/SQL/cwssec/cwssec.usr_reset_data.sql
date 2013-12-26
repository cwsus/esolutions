﻿--
-- Dumping data for table `RESET_DATA`
--
DROP TABLE IF EXISTS `CWSSEC`.`RESET_DATA`;
CREATE TABLE `CWSSEC`.`RESET_DATA` (
    `CN` VARCHAR(128) NOT NULL,
    `RESET_KEY` VARCHAR(128) NOT NULL,
    `SMS_CODE` VARCHAR(8),
    `CREATE_TIME` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (`CN`),
    CONSTRAINT `FK_LGN_GUID`
        FOREIGN KEY (`CN`)
        REFERENCES `CWSSEC`.`usr_lgn` (`CN`)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    INDEX `IDX_USERS` (`CN`, `RESET_KEY`, `SMS_CODE`)
) ENGINE=MyISAM DEFAULT CHARSET=UTF8 ROW_FORMAT=COMPACT COLLATE UTF8_GENERAL_CI;
COMMIT;

ALTER TABLE `CWSSEC`.`RESET_DATA` CONVERT TO CHARACTER SET UTF8 COLLATE UTF8_GENERAL_CI;
COMMIT;

DELIMITER $$

--
-- Definition of procedure `CWSSEC`.`insertResetData`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`insertResetData`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`insertResetData`(
    IN guid VARCHAR(128),
    IN resetId VARCHAR(128),
    IN timeCreated BIGINT(20),
    IN smsId VARCHAR(8)
)
BEGIN
    INSERT INTO `CWSSEC`.`RESET_DATA`
    (CN, RESET_KEY, CREATE_TIME, SMS_CODE)
    VALUES
    (guid, resetId, timeCreated, SMS_CODE);

    COMMIT;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`getResetData`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`getResetData`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`getResetData`(
    IN resetId VARCHAR(128)
)
BEGIN
    SELECT CN, CREATE_TIME
    FROM RESET_DATA
    WHERE RESET_KEY = resetId;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`verifySmsCodeForReset`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`verifySmsCodeForReset`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`verifySmsCodeForReset`(
    IN guid VARCHAR(128),
    IN resetId VARCHAR(128),
    IN smsId VARCHAR(8)
)
BEGIN
    SELECT RESET_KEY, CREATE_TIME
    FROM RESET_DATA
    WHERE CN = guid
    AND RESET_KEY = resetId
    AND SMS_CODE = smsId;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`listActiveResetRequests`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`listActiveResetRequests`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`listActiveResetRequests`(
)
BEGIN
    SELECT CN, RESET_KEY, CREATE_TIME
    FROM RESET_DATA;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`removeResetData`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`removeResetData`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`removeResetData`(
    IN commonName VARCHAR(128),
    IN resetId VARCHAR(128)
)
BEGIN
    DELETE FROM RESET_DATA
    WHERE RESET_KEY = resetId
    AND CN = commonName;

    COMMIT;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

DELIMITER ;
COMMIT;
