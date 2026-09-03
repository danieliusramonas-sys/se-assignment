BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE invoice_result_tab_t FORCE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4043 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE invoice_result_t FORCE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4043 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE payment_operation_result_t FORCE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4043 THEN
            RAISE;
        END IF;
END;
/

CREATE OR REPLACE TYPE invoice_result_t AS OBJECT (
    invoice_id      NUMBER,
    invoice_date    DATE,
    invoice_amount  NUMBER,
    currency        VARCHAR2(3),
    status          VARCHAR2(10),
    debt_amount     NUMBER
);
/

CREATE OR REPLACE TYPE invoice_result_tab_t
AS TABLE OF invoice_result_t;
/

CREATE OR REPLACE TYPE payment_operation_result_t AS OBJECT (
    status_code VARCHAR2(10),
    error_code  NUMBER,
    message     VARCHAR2(200)
);
/
