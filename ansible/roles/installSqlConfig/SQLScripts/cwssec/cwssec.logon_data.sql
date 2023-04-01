--
-- CWSSEC / LOGON_DATA
--
DELIMITER //

DROP TABLE IF EXISTS CWSSEC.LOGON_DATA //

CREATE TABLE CWSSEC.LOGON_DATA (
    CN VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    SALT VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    SALT_TYPE ENUM ('LOGON', 'RESET') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    PRIMARY KEY (CN, SALT_TYPE),
    UNIQUE KEY UNQ_SALTDATA (CN, SALT, SALT_TYPE),
    INDEX IDX_LOGON_DATA (CN, SALT, SALT_TYPE),
    CONSTRAINT FK_LGN_DATA
        FOREIGN KEY (CN)
        REFERENCES CWSSEC.USERS (CN)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    KEY IDX_SALTDATA (SALT,SALT_TYPE) USING HASH
) ENGINE=InnoDB CHARSET=utf8mb4 ROW_FORMAT=COMPACT COLLATE utf8mb4_0900_ai_ci //
COMMIT //

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON CWSSEC.* TO 'appadm'@'localhost' //
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON CWSSEC.* TO 'appadm'@'appsrv.lan' //

--
-- BEGIN STORED PROCEDURES
--
DROP PROCEDURE IF EXISTS CWSSEC.getUserSalt //
DROP PROCEDURE IF EXISTS CWSSEC.addOrUpdateUserSalt //

CREATE PROCEDURE CWSSEC.addOrUpdateUserSalt(
    IN guid VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN newSalt VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    in sType VARCHAR(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
)
BEGIN
    SELECT SALT_TYPE
    FROM CWSSEC.LOGON_DATA
    WHERE CN = guid
    AND SALT_TYPE = sType
    INTO @hasSaltValue;

    SELECT @hasSaltValue;

    IF ((SELECT @hashValue) = sType)
    THEN
        UPDATE CWSSEC.LOGON_DATA
        SET SALT = newSalt
        WHERE CN = guid
        AND SALT_TYPE = sType;

        COMMIT;
    ELSE
        INSERT INTO CWSSEC.LOGON_DATA (CN, SALT, SALT_TYPE)
        VALUES (guid, newSalt, sType);

        COMMIT;
    END IF;

    COMMIT;
END //
COMMIT //

CREATE PROCEDURE CWSSEC.getUserSalt(
    IN guid VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
    IN sType VARCHAR(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
)
BEGIN
    SELECT SALT
    FROM CWSSEC.LOGON_DATA
    WHERE CN = guid
    AND SALT_TYPE = sType;
END //
COMMIT //

GRANT EXECUTE ON PROCEDURE CWSSEC.addOrUpdateUserSalt TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.getUserSalt TO 'appadm'@'localhost' //

GRANT EXECUTE ON PROCEDURE CWSSEC.addOrUpdateUserSalt TO 'appadm'@'appsrv.lan' //
GRANT EXECUTE ON PROCEDURE CWSSEC.getUserSalt TO 'appadm'@'appsrv.lan' //

DELIMITER ;
