-- Execute as SYS or another DBA user

CREATE USER se_assignment IDENTIFIED BY se_assignment;

GRANT CREATE SESSION TO se_assignment;
GRANT CREATE TABLE TO se_assignment;
GRANT CREATE PROCEDURE TO se_assignment;
GRANT CREATE SEQUENCE TO se_assignment;
GRANT CREATE VIEW TO se_assignment;

ALTER USER se_assignment QUOTA UNLIMITED ON USERS;
