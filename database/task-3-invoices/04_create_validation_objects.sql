-- Task 3 - Validation objects
-- DATA  = generated data quality validations
-- QUERY = UNPAID_INVOICES_V functional validations
-- Script is designed to be re-runnable.


-------------------------------------------------------------------------------
-- Drop existing validation objects
-------------------------------------------------------------------------------

BEGIN
    BEGIN
        EXECUTE IMMEDIATE 'DROP PACKAGE invoice_validation_pkg';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -4043 THEN
                RAISE;
            END IF;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE invoice_validation_result PURGE';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -942 THEN
                RAISE;
            END IF;
    END;
END;
/
-------------------------------------------------------------------------------
-- Validation result table
-------------------------------------------------------------------------------

CREATE TABLE invoice_validation_result (
    validation_code   VARCHAR2(20)   NOT NULL,
    validation_type   VARCHAR2(20)   NOT NULL,
    validation_name   VARCHAR2(200)  NOT NULL,
    validation_time   TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
    status            VARCHAR2(10)   NOT NULL,
    error_count       NUMBER         DEFAULT 0 NOT NULL,
    result_details    CLOB,

    CONSTRAINT chk_inv_val_type
        CHECK (validation_type IN ('DATA', 'QUERY')),

    CONSTRAINT chk_inv_val_status
        CHECK (status IN ('OK', 'FAIL')),

    CONSTRAINT chk_inv_val_error_count
        CHECK (error_count >= 0)
);


-------------------------------------------------------------------------------
-- Package specification
-------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE invoice_validation_pkg AS

    PROCEDURE run_all;

END invoice_validation_pkg;
/

-------------------------------------------------------------------------------
-- Package body
-------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY invoice_validation_pkg AS

    c_max_details CONSTANT PLS_INTEGER := 20;


    ---------------------------------------------------------------------------
    -- Save validation result
    ---------------------------------------------------------------------------
    PROCEDURE save_result (
        p_validation_code IN VARCHAR2,
        p_validation_type IN VARCHAR2,
        p_validation_name IN VARCHAR2,
        p_status          IN VARCHAR2,
        p_error_count     IN NUMBER,
        p_result_details  IN CLOB
    )
    IS
    BEGIN
        INSERT INTO invoice_validation_result (
            validation_code,
            validation_type,
            validation_name,
            validation_time,
            status,
            error_count,
            result_details
        )
        VALUES (
            p_validation_code,
            p_validation_type,
            p_validation_name,
            SYSTIMESTAMP,
            p_status,
            p_error_count,
            p_result_details
        );
    END save_result;


    ---------------------------------------------------------------------------
    -- VLD-01 / DATA
    -- Payment date must not be before invoice date
    ---------------------------------------------------------------------------
    PROCEDURE validate_vld_01
    IS
        l_error_count NUMBER := 0;
        l_detail_no   NUMBER := 0;
        l_details     CLOB;
    BEGIN
        FOR r IN (
            SELECT
                p.payment_id,
                i.invoice_id,
                i.invoice_date,
                p.payment_date
            FROM payment p
            JOIN invoice i
                ON i.invoice_id = p.invoice_id
            WHERE p.payment_date < i.invoice_date
            ORDER BY i.invoice_id, p.payment_id
        )
        LOOP
            l_error_count := l_error_count + 1;

            IF l_detail_no < c_max_details THEN
                l_detail_no := l_detail_no + 1;

                l_details :=
                    l_details ||
                    'PAYMENT_ID=' || r.payment_id ||
                    ', INVOICE_ID=' || r.invoice_id ||
                    ', INVOICE_DATE=' ||
                        TO_CHAR(r.invoice_date, 'YYYY-MM-DD') ||
                    ', PAYMENT_DATE=' ||
                        TO_CHAR(r.payment_date, 'YYYY-MM-DD') ||
                    CHR(10);
            END IF;
        END LOOP;

        save_result(
            'VLD-01',
            'DATA',
            'Payment date must not be before invoice date',
            CASE WHEN l_error_count = 0 THEN 'OK' ELSE 'FAIL' END,
            l_error_count,
            CASE
                WHEN l_error_count = 0
                    THEN 'No invalid records found'
                ELSE l_details
            END
        );
    END validate_vld_01;


    ---------------------------------------------------------------------------
    -- VLD-02 / DATA
    -- Payment date must not be in the future
    ---------------------------------------------------------------------------
    PROCEDURE validate_vld_02
    IS
        l_error_count NUMBER := 0;
        l_detail_no   NUMBER := 0;
        l_details     CLOB;
    BEGIN
        FOR r IN (
            SELECT
                payment_id,
                invoice_id,
                payment_date
            FROM payment
            WHERE payment_date > TRUNC(SYSDATE)
            ORDER BY invoice_id, payment_id
        )
        LOOP
            l_error_count := l_error_count + 1;

            IF l_detail_no < c_max_details THEN
                l_detail_no := l_detail_no + 1;

                l_details :=
                    l_details ||
                    'PAYMENT_ID=' || r.payment_id ||
                    ', INVOICE_ID=' || r.invoice_id ||
                    ', PAYMENT_DATE=' ||
                        TO_CHAR(r.payment_date, 'YYYY-MM-DD') ||
                    CHR(10);
            END IF;
        END LOOP;

        save_result(
            'VLD-02',
            'DATA',
            'Payment date must not be in the future',
            CASE WHEN l_error_count = 0 THEN 'OK' ELSE 'FAIL' END,
            l_error_count,
            CASE
                WHEN l_error_count = 0
                    THEN 'No invalid records found'
                ELSE l_details
            END
        );
    END validate_vld_02;


    ---------------------------------------------------------------------------
    -- VLD-03 / DATA
    -- Payment currency must match invoice currency
    ---------------------------------------------------------------------------
    PROCEDURE validate_vld_03
    IS
        l_error_count NUMBER := 0;
        l_detail_no   NUMBER := 0;
        l_details     CLOB;
    BEGIN
        FOR r IN (
            SELECT
                p.payment_id,
                i.invoice_id,
                i.currency AS invoice_currency,
                p.currency AS payment_currency
            FROM payment p
            JOIN invoice i
                ON i.invoice_id = p.invoice_id
            WHERE p.currency <> i.currency
            ORDER BY i.invoice_id, p.payment_id
        )
        LOOP
            l_error_count := l_error_count + 1;

            IF l_detail_no < c_max_details THEN
                l_detail_no := l_detail_no + 1;

                l_details :=
                    l_details ||
                    'PAYMENT_ID=' || r.payment_id ||
                    ', INVOICE_ID=' || r.invoice_id ||
                    ', INVOICE_CURRENCY=' || r.invoice_currency ||
                    ', PAYMENT_CURRENCY=' || r.payment_currency ||
                    CHR(10);
            END IF;
        END LOOP;

        save_result(
            'VLD-03',
            'DATA',
            'Payment currency must match invoice currency',
            CASE WHEN l_error_count = 0 THEN 'OK' ELSE 'FAIL' END,
            l_error_count,
            CASE
                WHEN l_error_count = 0
                    THEN 'No currency mismatches found'
                ELSE l_details
            END
        );
    END validate_vld_03;


    ---------------------------------------------------------------------------
    -- VLD-04 / DATA
    -- Payment amount must be positive
    ---------------------------------------------------------------------------
    PROCEDURE validate_vld_04
    IS
        l_error_count NUMBER := 0;
        l_detail_no   NUMBER := 0;
        l_details     CLOB;
    BEGIN
        FOR r IN (
            SELECT
                payment_id,
                invoice_id,
                payment_amount
            FROM payment
            WHERE payment_amount <= 0
            ORDER BY invoice_id, payment_id
        )
        LOOP
            l_error_count := l_error_count + 1;

            IF l_detail_no < c_max_details THEN
                l_detail_no := l_detail_no + 1;

                l_details :=
                    l_details ||
                    'PAYMENT_ID=' || r.payment_id ||
                    ', INVOICE_ID=' || r.invoice_id ||
                    ', PAYMENT_AMOUNT=' || r.payment_amount ||
                    CHR(10);
            END IF;
        END LOOP;

        save_result(
            'VLD-04',
            'DATA',
            'Payment amount must be positive',
            CASE WHEN l_error_count = 0 THEN 'OK' ELSE 'FAIL' END,
            l_error_count,
            CASE
                WHEN l_error_count = 0
                    THEN 'No invalid payment amounts found'
                ELSE l_details
            END
        );
    END validate_vld_04;


    ---------------------------------------------------------------------------
    -- VLD-05 / DATA
    -- Invoice amount must not be negative
    ---------------------------------------------------------------------------
    PROCEDURE validate_vld_05
    IS
        l_error_count NUMBER := 0;
        l_detail_no   NUMBER := 0;
        l_details     CLOB;
    BEGIN
        FOR r IN (
            SELECT
                invoice_id,
                invoice_amount
            FROM invoice
            WHERE invoice_amount < 0
            ORDER BY invoice_id
        )
        LOOP
            l_error_count := l_error_count + 1;

            IF l_detail_no < c_max_details THEN
                l_detail_no := l_detail_no + 1;

                l_details :=
                    l_details ||
                    'INVOICE_ID=' || r.invoice_id ||
                    ', INVOICE_AMOUNT=' || r.invoice_amount ||
                    CHR(10);
            END IF;
        END LOOP;

        save_result(
            'VLD-05',
            'DATA',
            'Invoice amount must not be negative',
            CASE WHEN l_error_count = 0 THEN 'OK' ELSE 'FAIL' END,
            l_error_count,
            CASE
                WHEN l_error_count = 0
                    THEN 'No invalid invoice amounts found'
                ELSE l_details
            END
        );
    END validate_vld_05;


    ---------------------------------------------------------------------------
    -- VLD-06 / DATA
    -- Total payment amount must not exceed invoice amount
    ---------------------------------------------------------------------------
    PROCEDURE validate_vld_06
    IS
        l_error_count NUMBER := 0;
        l_detail_no   NUMBER := 0;
        l_details     CLOB;
    BEGIN
        FOR r IN (
            SELECT
                i.invoice_id,
                i.invoice_amount,
                SUM(p.payment_amount) AS payment_sum
            FROM invoice i
            JOIN payment p
                ON p.invoice_id = i.invoice_id
            GROUP BY
                i.invoice_id,
                i.invoice_amount
            HAVING SUM(p.payment_amount) > i.invoice_amount
            ORDER BY i.invoice_id
        )
        LOOP
            l_error_count := l_error_count + 1;

            IF l_detail_no < c_max_details THEN
                l_detail_no := l_detail_no + 1;

                l_details :=
                    l_details ||
                    'INVOICE_ID=' || r.invoice_id ||
                    ', INVOICE_AMOUNT=' || r.invoice_amount ||
                    ', PAYMENT_SUM=' || r.payment_sum ||
                    CHR(10);
            END IF;
        END LOOP;

        save_result(
            'VLD-06',
            'DATA',
            'Total payment amount must not exceed invoice amount',
            CASE WHEN l_error_count = 0 THEN 'OK' ELSE 'FAIL' END,
            l_error_count,
            CASE
                WHEN l_error_count = 0
                    THEN 'No overpaid invoices found'
                ELSE l_details
            END
        );
    END validate_vld_06;


    ---------------------------------------------------------------------------
    -- VLD-07 / QUERY
    -- Invoice without payments must be returned by UNPAID_INVOICES_V
    ---------------------------------------------------------------------------
    PROCEDURE validate_vld_07
    IS
        l_error_count NUMBER := 0;
        l_detail_no   NUMBER := 0;
        l_details     CLOB;
    BEGIN
        FOR r IN (
            SELECT invoice_id
            FROM (
                SELECT
                    i.invoice_id
                FROM invoice i
                LEFT JOIN payment p
                    ON p.invoice_id = i.invoice_id
                GROUP BY i.invoice_id
                HAVING COUNT(p.payment_id) = 0

                MINUS

                SELECT
                    invoice_id
                FROM unpaid_invoices_v
            )
            ORDER BY invoice_id
        )
        LOOP
            l_error_count := l_error_count + 1;

            IF l_detail_no < c_max_details THEN
                l_detail_no := l_detail_no + 1;

                l_details :=
                    l_details ||
                    'INVOICE_ID=' || r.invoice_id ||
                    ' is missing from UNPAID_INVOICES_V' ||
                    CHR(10);
            END IF;
        END LOOP;

        save_result(
            'VLD-07',
            'QUERY',
            'Invoice without payments must be returned',
            CASE WHEN l_error_count = 0 THEN 'OK' ELSE 'FAIL' END,
            l_error_count,
            CASE
                WHEN l_error_count = 0
                    THEN 'All invoices without payments are returned'
                ELSE l_details
            END
        );
    END validate_vld_07;


    ---------------------------------------------------------------------------
    -- VLD-08 / QUERY
    -- Partially paid invoice must be returned by UNPAID_INVOICES_V
    ---------------------------------------------------------------------------
    PROCEDURE validate_vld_08
    IS
        l_error_count NUMBER := 0;
        l_detail_no   NUMBER := 0;
        l_details     CLOB;
    BEGIN
        FOR r IN (
            SELECT invoice_id
            FROM (
                SELECT
                    i.invoice_id
                FROM invoice i
                JOIN payment p
                    ON p.invoice_id = i.invoice_id
                GROUP BY
                    i.invoice_id,
                    i.invoice_amount
                HAVING SUM(p.payment_amount) > 0
                   AND SUM(p.payment_amount) < i.invoice_amount

                MINUS

                SELECT
                    invoice_id
                FROM unpaid_invoices_v
            )
            ORDER BY invoice_id
        )
        LOOP
            l_error_count := l_error_count + 1;

            IF l_detail_no < c_max_details THEN
                l_detail_no := l_detail_no + 1;

                l_details :=
                    l_details ||
                    'INVOICE_ID=' || r.invoice_id ||
                    ' is partially paid but missing from UNPAID_INVOICES_V' ||
                    CHR(10);
            END IF;
        END LOOP;

        save_result(
            'VLD-08',
            'QUERY',
            'Partially paid invoice must be returned',
            CASE WHEN l_error_count = 0 THEN 'OK' ELSE 'FAIL' END,
            l_error_count,
            CASE
                WHEN l_error_count = 0
                    THEN 'All partially paid invoices are returned'
                ELSE l_details
            END
        );
    END validate_vld_08;


    ---------------------------------------------------------------------------
    -- VLD-09 / QUERY
    -- Fully paid invoice must not be returned by UNPAID_INVOICES_V
    ---------------------------------------------------------------------------
    PROCEDURE validate_vld_09
    IS
        l_error_count NUMBER := 0;
        l_detail_no   NUMBER := 0;
        l_details     CLOB;
    BEGIN
        FOR r IN (
            SELECT
                v.invoice_id
            FROM unpaid_invoices_v v
            JOIN (
                SELECT
                    i.invoice_id
                FROM invoice i
                JOIN payment p
                    ON p.invoice_id = i.invoice_id
                GROUP BY
                    i.invoice_id,
                    i.invoice_amount
                HAVING SUM(p.payment_amount) = i.invoice_amount
            ) fp
                ON fp.invoice_id = v.invoice_id
            ORDER BY v.invoice_id
        )
        LOOP
            l_error_count := l_error_count + 1;

            IF l_detail_no < c_max_details THEN
                l_detail_no := l_detail_no + 1;

                l_details :=
                    l_details ||
                    'INVOICE_ID=' || r.invoice_id ||
                    ' is fully paid but returned by UNPAID_INVOICES_V' ||
                    CHR(10);
            END IF;
        END LOOP;

        save_result(
            'VLD-09',
            'QUERY',
            'Fully paid invoice must not be returned',
            CASE WHEN l_error_count = 0 THEN 'OK' ELSE 'FAIL' END,
            l_error_count,
            CASE
                WHEN l_error_count = 0
                    THEN 'No fully paid invoices are returned'
                ELSE l_details
            END
        );
    END validate_vld_09;


    ---------------------------------------------------------------------------
    -- VLD-10 / QUERY
    -- Multiple payments must be aggregated correctly
    ---------------------------------------------------------------------------
    PROCEDURE validate_vld_10
    IS
        l_error_count NUMBER := 0;
        l_detail_no   NUMBER := 0;
        l_details     CLOB;
    BEGIN

        -----------------------------------------------------------------------
        -- Case A:
        -- Multiple payments, payment sum < invoice amount
        -- Invoice must be returned by the view
        -----------------------------------------------------------------------
        FOR r IN (
            SELECT invoice_id
            FROM (
                SELECT
                    i.invoice_id
                FROM invoice i
                JOIN payment p
                    ON p.invoice_id = i.invoice_id
                GROUP BY
                    i.invoice_id,
                    i.invoice_amount
                HAVING COUNT(p.payment_id) > 1
                   AND SUM(p.payment_amount) < i.invoice_amount

                MINUS

                SELECT
                    v.invoice_id
                FROM unpaid_invoices_v v
            )
            ORDER BY invoice_id
        )
        LOOP
            l_error_count := l_error_count + 1;

            IF l_detail_no < c_max_details THEN
                l_detail_no := l_detail_no + 1;

                l_details :=
                    l_details ||
                    'INVOICE_ID=' || r.invoice_id ||
                    ' has multiple partial payments but is missing from view' ||
                    CHR(10);
            END IF;
        END LOOP;


        -----------------------------------------------------------------------
        -- Case B:
        -- Multiple payments, payment sum >= invoice amount
        -- Invoice must not be returned by the view
        -----------------------------------------------------------------------
        FOR r IN (
            SELECT
                v.invoice_id
            FROM unpaid_invoices_v v
            JOIN (
                SELECT
                    i.invoice_id
                FROM invoice i
                JOIN payment p
                    ON p.invoice_id = i.invoice_id
                GROUP BY
                    i.invoice_id,
                    i.invoice_amount
                HAVING COUNT(p.payment_id) > 1
                   AND SUM(p.payment_amount) >= i.invoice_amount
            ) mp
                ON mp.invoice_id = v.invoice_id
            ORDER BY v.invoice_id
        )
        LOOP
            l_error_count := l_error_count + 1;

            IF l_detail_no < c_max_details THEN
                l_detail_no := l_detail_no + 1;

                l_details :=
                    l_details ||
                    'INVOICE_ID=' || r.invoice_id ||
                    ' has multiple payments covering the invoice but is returned by view' ||
                    CHR(10);
            END IF;
        END LOOP;

        save_result(
            'VLD-10',
            'QUERY',
            'Multiple payments must be aggregated correctly',
            CASE WHEN l_error_count = 0 THEN 'OK' ELSE 'FAIL' END,
            l_error_count,
            CASE
                WHEN l_error_count = 0
                    THEN 'Multiple-payment invoices are classified correctly'
                ELSE l_details
            END
        );
    END validate_vld_10;


    ---------------------------------------------------------------------------
    -- Run all validations
    ---------------------------------------------------------------------------
    PROCEDURE run_all
    IS
    BEGIN
        DELETE FROM invoice_validation_result;

        validate_vld_01;
        validate_vld_02;
        validate_vld_03;
        validate_vld_04;
        validate_vld_05;
        validate_vld_06;
        validate_vld_07;
        validate_vld_08;
        validate_vld_09;
        validate_vld_10;

        COMMIT;
    END run_all;

END invoice_validation_pkg;
/
