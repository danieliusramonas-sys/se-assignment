-- 01_create_structures.sql


BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE age_test_data PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE age_category PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE age_result_t FORCE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4043 THEN
            RAISE;
        END IF;
END;
/

CREATE TABLE age_category (
    age_category_id NUMBER
        GENERATED ALWAYS AS IDENTITY,

    min_age         NUMBER(3) NOT NULL,
    max_age         NUMBER(3),
    description     VARCHAR2(100) NOT NULL,

    CONSTRAINT pk_age_category
        PRIMARY KEY (age_category_id),

    CONSTRAINT chk_age_category_min
        CHECK (min_age >= 0),

    CONSTRAINT chk_age_category_range
        CHECK (
            max_age IS NULL
            OR max_age >= min_age
        )
);

CREATE TABLE age_test_data (
    test_case_id NUMBER GENERATED ALWAYS AS IDENTITY,
    age          NUMBER(3),

    CONSTRAINT pk_age_test_data
        PRIMARY KEY (test_case_id)
);

CREATE OR REPLACE TYPE age_result_t AS OBJECT (
    status_code VARCHAR2(10),
    error_code  NUMBER,
    message     VARCHAR2(200)
);

ALTER TYPE age_result_t COMPILE;
