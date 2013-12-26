--
-- Definition of table `USERS`
-- DATA TABLE
--
DROP TABLE IF EXISTS `CWSSEC`.`USERS`;
CREATE TABLE `CWSSEC`.`USERS` (
    `CN` VARCHAR(128) NOT NULL,
    `UID` VARCHAR(45) NOT NULL,
    `USERPASSWORD` VARCHAR(255) NOT NULL,
    `CWSROLE` VARCHAR(45) NOT NULL,
    `CWSFAILEDPWDCOUNT` MEDIUMINT NOT NULL DEFAULT '0',
    `CWSLASTLOGIN` TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    `CWSISSUSPENDED` BOOLEAN NOT NULL DEFAULT FALSE,
    `CWSISOLRSETUP` BOOLEAN NOT NULL DEFAULT TRUE,
    `CWSISOLRLOCKED` BOOLEAN NOT NULL DEFAULT FALSE,
    `CWSISTCACCEPTED` BOOLEAN NOT NULL DEFAULT FALSE,
    `SN` VARCHAR(100) NOT NULL,
    `GIVENNAME` VARCHAR(100) NOT NULL,
    `DISPLAYNAME` VARCHAR(100) NOT NULL DEFAULT 'DISPLAY NAME',
    `EMAIL` VARCHAR(50) NOT NULL,
    `CWSEXPIRYDATE` BIGINT(20) UNSIGNED NOT NULL DEFAULT '0',
    `CWSSECQ1` VARCHAR(60) NOT NULL DEFAULT 'QUESTION 1',
    `CWSSECQ2` VARCHAR(60) NOT NULL DEFAULT 'QUESTION 2',
    `CWSSECANS1` VARCHAR(255) NOT NULL DEFAULT 'ANSWER 1',
    `CWSSECANS2` VARCHAR(255) NOT NULL DEFAULT 'ANSWER 2',
    `CWSPUBLICKEY` VARBINARY(4352),
    PRIMARY KEY  (`CN`),
    UNIQUE KEY `USERID` (`UID`),
    INDEX `IDX_USERS` (`CN`, `UID`, `EMAIL`),
    FULLTEXT KEY `FT_USERS` (`UID`, `CWSROLE`, `GIVENNAME`, `SN`, `EMAIL`, `CN`)
) ENGINE=MyISAM DEFAULT CHARSET=UTF8 ROW_FORMAT=COMPACT COLLATE UTF8_GENERAL_CI;
COMMIT;

ALTER TABLE `CWSSEC`.`USERS` CONVERT TO CHARACTER SET UTF8 COLLATE UTF8_GENERAL_CI;
COMMIT;

DELIMITER $$

--
-- Definition of procedure `CWSSEC`.`getUserByAttribute`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`getUserByAttribute`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`getUserByAttribute`(
    IN attributeName VARCHAR(100)
)
BEGIN
    SELECT
        CN,
        UID,
        GIVENNAME,
        SN,
        DISPLAYNAME,
        EMAIL,
        CWSROLE,
        CWSFAILEDPWDCOUNT,
        CWSLASTLOGIN,
        CWSEXPIRYDATE,
        CWSISSUSPENDED,
        CWSISOLRSETUP,
        CWSISOLRLOCKED,
        CWSISTCACCEPTED,
        CWSSECQ1,
        CWSSECQ2,
        CWSPUBLICKEY,
    MATCH (`UID`, `CWSROLE`, `GIVENNAME`, `SN`, `EMAIL`, `CN`)
    AGAINST (+attributeName WITH QUERY EXPANSION)
    FROM `CWSSEC`.`USERS`
    WHERE MATCH (`UID`, `CWSROLE`, `GIVENNAME`, `SN`, `EMAIL`, `CN`)
    AGAINST (+attributeName IN BOOLEAN MODE);
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`listUserAccounts`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`listUserAccounts`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`listUserAccounts`(
    IN attributeName VARCHAR(100)
)
BEGIN
    SELECT
        CN,
        UID,
        GIVENNAME,
        SN,
        DISPLAYNAME,
        EMAIL,
        CWSROLE,
        CWSFAILEDPWDCOUNT,
        CWSLASTLOGIN,
        CWSEXPIRYDATE,
        CWSISSUSPENDED,
        CWSISOLRSETUP,
        CWSISOLRLOCKED,
        CWSISTCACCEPTED,
        CWSSECQ1,
        CWSSECQ2,
        CWSPUBLICKEY
    FROM `CWSSEC`.`USERS`;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`addUserAccount`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`addUserAccount`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`addUserAccount`(
    IN uid VARCHAR(45),
    IN userPassword VARCHAR(255),
    IN cwsRole VARCHAR(45),
    IN surname VARCHAR(100),
    IN givenName VARCHAR(100),
    IN emailAddr VARCHAR(50),
    IN commonName VARCHAR(128),
    IN displayName VARCHAR(100)
)
BEGIN
    SELECT unix_timestamp(now()) INTO @EXPIRY_TIME;

    INSERT INTO USERS
    (
        UID, USERPASSWORD, CWSROLE, SN, GIVENNAME,
        CWSEXPIRYDATE, EMAIL, CN, DISPLAYNAME
    )
    VALUES
    (
        uid, userPassword, cwsRole, surname, givenName,
        unix_timestamp(now()), emailAddr, commonName, displayName
    );

    COMMIT;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`updateUserAccount`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`updateUserAccount`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`updateUserAccount`(
    IN commonName VARCHAR(128),
    IN cwsRole VARCHAR(45),
    IN surname VARCHAR(100),
    IN givenName VARCHAR(100),
    IN emailAddr VARCHAR(100),
    IN displayName VARCHAR(100)
)
BEGIN
    UPDATE USERS
    SET
        CWSROLE = cwsRole,
        sn = surname,
        GIVENNAME = givenName,
        EMAIL = emailAddr,
        DISPLAYNAME = displayName
    WHERE cn = commonName;

    COMMIT;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`updateUserPassword`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`updateUserPassword`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`updateUserPassword`(
    IN commonName VARCHAR(128),
    IN currentPassword VARCHAR(255),
    IN newPassword VARCHAR(255)
)
BEGIN
    UPDATE USERS
    SET
        USERPASSWORD = newPassword,
        CWSEXPIRYDATE = unix_timestamp(now()),
        CWSFAILEDPWDCOUNT = 0
    WHERE USERPASSWORD = currentPassword
    AND CN = commonName;

    COMMIT;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`resetUserPassword`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`resetUserPassword`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`resetUserPassword`(
    IN commonName VARCHAR(128),
    IN newPassword VARCHAR(255)
)
BEGIN
    UPDATE USERS
    SET
        USERPASSWORD = newPassword,
        CWSEXPIRYDATE = unix_timestamp(now()),
        CWSFAILEDPWDCOUNT = 0
    WHERE CN = commonName;

    COMMIT;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `showUserAccounts`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`showUserAccounts`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`showUserAccounts`(
)
BEGIN
    SELECT
        UID,
        CWSROLE,
        CWSLASTLOGIN,
        SN,
        GIVENNAME,
        CWSEXPIRYDATE,
        EMAIL,
        CWSISSUSPENDED,
        CN,
        CWSISOLRSETUP,
        CWSISOLRLOCKED,
        DISPLAYNAME,
        CWSISTCACCEPTED,
        CWSPUBLICKEY
    FROM USERS;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `showUserAccount`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`showUserAccount`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`showUserAccount`(
    IN commonName VARCHAR(128)
)
BEGIN
    SELECT
        UID,
        CWSROLE,
        CWSFAILEDPWDCOUNT,
        CWSLASTLOGIN,
        SN,
        GIVENNAME,
        CWSEXPIRYDATE,
        EMAIL,
        CWSISSUSPENDED,
        CN,
        CWSISOLRSETUP,
        CWSISOLRLOCKED,
        DISPLAYNAME,
        CWSISTCACCEPTED,
        CWSPUBLICKEY
    FROM USERS
    WHERE cn = commonName;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `removeUserAccount`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`removeUserAccount`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`removeUserAccount`(
    IN commonName VARCHAR(128)
)
BEGIN
    DELETE FROM `CWSSEC`.`USERS`
    WHERE cn = commonName;

    COMMIT;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`performAuthentication`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`performAuthentication`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`performAuthentication`(
    IN guid VARCHAR(128),
    IN username VARCHAR(100),
    IN password VARCHAR(255)
)
BEGIN
    SELECT DISTINCT
        CN,
        UID,
        GIVENNAME,
        SN,
        DISPLAYNAME,
        EMAIL,
        CWSROLE,
        CWSFAILEDPWDCOUNT,
        CWSLASTLOGIN,
        CWSEXPIRYDATE,
        CWSISSUSPENDED,
        CWSISOLRSETUP,
        CWSISOLRLOCKED,
        CWSISTCACCEPTED,
        CWSPUBLICKEY
    FROM `CWSSEC`.`USERS`
    WHERE CN = guid
    AND UID = username
    AND USERPASSWORD = password;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`loginSuccess`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`loginSuccess`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`loginSuccess`(
    IN commonName VARCHAR(128),
    IN userName VARCHAR(100)
)
BEGIN
    UPDATE CWSSEC.USERS
    SET
        CWSLASTLOGIN = unix_timestamp(now()),
        CWSFAILEDPWDCOUNT = 0
    WHERE CN = commonName
    AND UID = username;

    COMMIT;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`verifySecurityQuestions`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`verifySecurityQuestions`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`verifySecurityQuestions`(
    IN commonName VARCHAR(128),
    IN userName VARCHAR(100),
    IN secAnswerOne VARCHAR(255),
    IN secAnswerTwo VARCHAR(255)
)
BEGIN
    SELECT COUNT(CN)
    FROM `CWSSEC`.`USERS`
    WHERE CWSSECANS1 = secAnswerOne
    AND CWSSECANS2 = secAnswerTwo
    AND CN = commonName;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`addOrUpdateSecurityQuestions`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`addOrUpdateSecurityQuestions`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`addOrUpdateSecurityQuestions`(
    IN commonName VARCHAR(128),
    IN userName VARCHAR(100),
    IN userPassword VARCHAR(255),
    IN secQuestionOne VARCHAR(60),
    IN secQuestionTwo VARCHAR(60),
    IN secAnswerOne VARCHAR(255),
    IN secAnswerTwo VARCHAR(255)
)
BEGIN
    UPDATE `CWSSEC`.`USERS`
    SET
        CWSSECQ1 = secQuestionOne,
        CWSSECQ2 = secQuestionTwo,
        CWSSECANS1 = secAnswerOne,
        CWSSECANS2 = secAnswerTwo
    WHERE UID = userName
    AND CN = commonName
    AND USERPASSWORD = userPassword;

    COMMIT;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`lockUserAccount`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`lockUserAccount`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`lockUserAccount`(
    IN commonName VARCHAR(128)
)
BEGIN
    SELECT CWSFAILEDPWDCOUNT
    FROM `CWSSEC`.`USERS`
    WHERE CN = commonName
    INTO @CURRENT_COUNT;

    UPDATE `CWSSEC`.`USERS`
    SET CWSFAILEDPWDCOUNT = @CURRENT_COUNT + 1
    WHERE CN = commonName;

    COMMIT;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`unlockUserAccount`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`unlockUserAccount`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`unlockUserAccount`(
    IN commonName VARCHAR(128)
)
BEGIN
    UPDATE `CWSSEC`.`USERS`
    SET CWSFAILEDPWDCOUNT = 0
    WHERE CN = commonName;

    COMMIT;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`modifyUserSuspension`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`modifyUserSuspension`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`modifyUserSuspension`(
    IN commonName VARCHAR(128),
    IN isSuspended BOOLEAN
)
BEGIN
    UPDATE `CWSSEC`.`USERS`
    SET CWSISSUSPENDED = isSuspended
    WHERE CN = commonName;

    COMMIT;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`addPublicKey`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`addPublicKey`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`addPublicKey`(
    IN commonName VARCHAR(128),
    IN publicKey VARBINARY(4352)
)
BEGIN
    UPDATE `CWSSEC`.`USERS`
    SET CWSPUBLICKEY = publicKey
    WHERE CN = commonName;

    COMMIT;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`retrPublicKey`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`retrPublicKey`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`retrPublicKey`(
    IN commonName VARCHAR(128)
)
BEGIN
    SELECT CWSPUBLICKEY
    FROM `CWSSEC`.`USERS`
    WHERE CN = commonName;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

--
-- Definition of procedure `CWSSEC`.`passwordExpirationNotifier`
--
DROP PROCEDURE IF EXISTS `CWSSEC`.`passwordExpirationNotifier`$$
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */ $$
CREATE PROCEDURE `CWSSEC`.`passwordExpirationNotifier`(
)
BEGIN
    SELECT
        UID,
        SN,
        GIVENNAME,
        CWSEXPIRYDATE,
        EMAIL
    FROM USERS;
END $$
/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$
COMMIT$$

DELIMITER ;
COMMIT;
