-- Task 3
-- Intentionally corrupts test data to verify DATA validation rules VLD-01..VLD-06.
--
-- Negative validation flow:
-- 01_create_structures.sql
-- 02_seed_data.sql
-- 03_create_unpaid_invoices_view.sql
-- 04_create_validation_objects.sql
-- 05_corrupt_test_data.sql
-- 06_run_validation.sql
--
-- To restore clean data, rerun:
-- 01_create_structures.sql
-- 02_seed_data.sql

DECLARE
    l_payment_vld01   payment.payment_id%TYPE;
    l_payment_vld02   payment.payment_id%TYPE;
    l_payment_vld03   payment.payment_id%TYPE;
    l_payment_vld04   payment.payment_id%TYPE;
    l_payment_vld06   payment.payment_id%TYPE;

    l_invoice_vld05   invoice.invoice_id%TYPE;
BEGIN

    ---------------------------------------------------------------------------
    -- Select different PAYMENT rows for VLD-01, VLD-02, VLD-03, VLD-04,
    -- and VLD-06.
    ---------------------------------------------------------------------------
    SELECT
        MAX(CASE WHEN rn = 1 THEN payment_id END),
        MAX(CASE WHEN rn = 2 THEN payment_id END),
        MAX(CASE WHEN rn = 3 THEN payment_id END),
        MAX(CASE WHEN rn = 4 THEN payment_id END),
        MAX(CASE WHEN rn = 5 THEN payment_id END)
    INTO
        l_payment_vld01,
        l_payment_vld02,
        l_payment_vld03,
        l_payment_vld04,
        l_payment_vld06
    FROM (
        SELECT
            payment_id,
            ROW_NUMBER() OVER (ORDER BY payment_id) AS rn
        FROM payment
    )
    WHERE rn <= 5;


    ---------------------------------------------------------------------------
    -- Select an invoice without payments for VLD-05.
    -- This avoids creating an additional VLD-06 error.
    ---------------------------------------------------------------------------
    SELECT invoice_id
    INTO l_invoice_vld05
    FROM (
        SELECT
            i.invoice_id
        FROM invoice i
        LEFT JOIN payment p
            ON p.invoice_id = i.invoice_id
        GROUP BY i.invoice_id
        HAVING COUNT(p.payment_id) = 0
        ORDER BY i.invoice_id
    )
    WHERE ROWNUM = 1;


    ---------------------------------------------------------------------------
    -- VLD-01
    -- Payment date must not be before invoice date.
    ---------------------------------------------------------------------------
    UPDATE payment p
    SET p.payment_date = (
        SELECT i.invoice_date - 1
        FROM invoice i
        WHERE i.invoice_id = p.invoice_id
    )
    WHERE p.payment_id = l_payment_vld01;


    ---------------------------------------------------------------------------
    -- VLD-02
    -- Payment date must not be in the future.
    ---------------------------------------------------------------------------
    UPDATE payment
    SET payment_date = TRUNC(SYSDATE) + 1
    WHERE payment_id = l_payment_vld02;


    ---------------------------------------------------------------------------
    -- VLD-03
    -- Payment currency must match invoice currency.
    ---------------------------------------------------------------------------
    UPDATE payment p
    SET p.currency = (
        SELECT
            CASE i.currency
                WHEN 'EUR' THEN 'USD'
                ELSE 'EUR'
            END
        FROM invoice i
        WHERE i.invoice_id = p.invoice_id
    )
    WHERE p.payment_id = l_payment_vld03;


    ---------------------------------------------------------------------------
    -- VLD-04
    -- Payment amount must be positive.
    --
    -- Temporarily disable the constraint so invalid test data can be created.
    ---------------------------------------------------------------------------
    EXECUTE IMMEDIATE
        'ALTER TABLE payment DISABLE CONSTRAINT chk_payment_amount';

    UPDATE payment
    SET payment_amount = 0
    WHERE payment_id = l_payment_vld04;


    ---------------------------------------------------------------------------
    -- VLD-05
    -- Invoice amount must not be negative.
    --
    -- Temporarily disable the constraint so invalid test data can be created.
    ---------------------------------------------------------------------------
    EXECUTE IMMEDIATE
        'ALTER TABLE invoice DISABLE CONSTRAINT chk_invoice_amount';

    UPDATE invoice
    SET invoice_amount = -1
    WHERE invoice_id = l_invoice_vld05;


    ---------------------------------------------------------------------------
    -- VLD-06
    -- Total payment amount must not exceed invoice amount.
    ---------------------------------------------------------------------------
    UPDATE payment p
    SET p.payment_amount = (
        SELECT i.invoice_amount + 100
        FROM invoice i
        WHERE i.invoice_id = p.invoice_id
    )
    WHERE p.payment_id = l_payment_vld06;


    ---------------------------------------------------------------------------
    -- Commit intentionally corrupted test data.
    ---------------------------------------------------------------------------
    COMMIT;


    ---------------------------------------------------------------------------
    -- Re-enable constraints without validating existing corrupted rows.
    --
    -- Existing intentionally invalid rows remain available for validation,
    -- but future INSERT/UPDATE operations are checked again.
    ---------------------------------------------------------------------------
    EXECUTE IMMEDIATE
        'ALTER TABLE payment ENABLE NOVALIDATE CONSTRAINT chk_payment_amount';

    EXECUTE IMMEDIATE
        'ALTER TABLE invoice ENABLE NOVALIDATE CONSTRAINT chk_invoice_amount';

END;
