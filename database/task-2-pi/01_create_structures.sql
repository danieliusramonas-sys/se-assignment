-- 01_create_structures.sql

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE pi_calculation_result PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE pi_test_data PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

CREATE TABLE pi_calculation_result (
    iteration_no   NUMBER NOT NULL,
    term_value     NUMBER,
    calculated_pi  NUMBER,
    CONSTRAINT pk_pi_calculation_result  PRIMARY KEY (iteration_no)
);

CREATE TABLE pi_test_data (
    test_case_id NUMBER GENERATED ALWAYS AS IDENTITY,
    precision    NUMBER(2) NOT NULL,
    expected_pi  NUMBER NOT NULL,
    CONSTRAINT pk_pi_test_data PRIMARY KEY (test_case_id)
);
