--
-- CWSSEC / SECURITY_QUESTIONS
--
DELIMITER //

DROP TABLE IF EXISTS CWSSEC.SECURITY_QUESTIONS //

CREATE TABLE CWSSEC.SECURITY_QUESTIONS (
    ID MEDIUMINT NOT NULL AUTO_INCREMENT,
    QUESTION VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    PRIMARY KEY (ID),
    INDEX IDX_QUESTIONS (ID, QUESTION)
) ENGINE=InnoDB CHARSET=utf8mb4 ROW_FORMAT=COMPACT COLLATE utf8mb4_0900_ai_ci //
COMMIT //

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON CWSSEC.* TO 'appadm'@'localhost' //
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON CWSSEC.* TO 'appadm'@'appsrv.lan' //

/*!40000 ALTER TABLE CWSSEC.SECURITY_QUESTIONS DISABLE KEYS */ //
INSERT INTO CWSSEC.SECURITY_QUESTIONS (QUESTION) VALUES ('What is your mother''s maiden name ?') //
INSERT INTO CWSSEC.SECURITY_QUESTIONS (QUESTION) VALUES ('What is your favourite cartoon ?') //
INSERT INTO CWSSEC.SECURITY_QUESTIONS (QUESTION) VALUES ('What is your favourite car ?') //
INSERT INTO CWSSEC.SECURITY_QUESTIONS (QUESTION) VALUES ('What is your least favourite colour ?') //
INSERT INTO CWSSEC.SECURITY_QUESTIONS (QUESTION) VALUES ('Who was your childhood best friend ?') //
/*!40000 ALTER TABLE CWSSEC.SECURITY_QUESTIONS ENABLE KEYS */ //

COMMIT //

--
--
--
DROP PROCEDURE IF EXISTS CWSSEC.retrSecurityQuestions //

CREATE PROCEDURE CWSSEC.retrSecurityQuestions(
)
BEGIN
    SELECT *
    FROM CWSSEC.SECURITY_QUESTIONS;
END //
COMMIT //

GRANT EXECUTE ON PROCEDURE CWSSEC.retrSecurityQuestions TO 'appadm'@'localhost' //
GRANT EXECUTE ON PROCEDURE CWSSEC.retrSecurityQuestions TO 'appadm'@'appsrv.lan' //

DELIMITER ;
