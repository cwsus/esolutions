--
-- AUDIT / AUDIT_DATA
--
DELIMITER //

DROP DATABASE IF EXISTS AUDIT //
DROP DATABASE IF EXISTS CWSSEC //
DROP DATABASE IF EXISTS ESOLUTIONS //

CREATE DATABASE AUDIT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci //
CREATE DATABASE CWSSEC CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci //
CREATE DATABASE ESOLUTIONS CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci //

GRANT SELECT, UPDATE, INSERT, DELETE, EXECUTE ON AUDIT.* TO 'appadm'@'localhost' //
GRANT SELECT, UPDATE, INSERT, DELETE, EXECUTE ON AUDIT.* TO 'appadm'@'appsrv.lan' //

GRANT SELECT, UPDATE, INSERT, DELETE, EXECUTE ON CWSSEC.* TO 'appadm'@'localhost' //
GRANT SELECT, UPDATE, INSERT, DELETE, EXECUTE ON CWSSEC.* TO 'appadm'@'appsrv.lan' //

GRANT SELECT, UPDATE, INSERT, DELETE, EXECUTE ON ESOLUTIONS.* TO 'appadm'@'localhost' //
GRANT SELECT, UPDATE, INSERT, DELETE, EXECUTE ON ESOLUTIONS.* TO 'appadm'@'appsrv.lan' //

DELIMITER ;