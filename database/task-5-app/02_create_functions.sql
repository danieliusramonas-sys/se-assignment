CREATE OR REPLACE FUNCTION get_invoice_statuses (
    p_invoice_id IN NUMBER   DEFAULT NULL,
    p_status     IN VARCHAR2 DEFAULT NULL
)
RETURN invoice_result_tab_t PIPELINED
AS
BEGIN
    FOR r IN (
        SELECT
            i.invoice_id,
            i.invoice_date,
            i.invoice_amount,
            i.currency,

            DECODE(
                ui.invoice_id,
                NULL, 'PAID',
                'UNPAID'
            ) AS status,

            GREATEST(
                i.invoice_amount - NVL(p.payment_sum, 0),
                0
            ) AS debt_amount

        FROM invoice i

        LEFT JOIN (
            SELECT
                invoice_id,
                SUM(payment_amount) AS payment_sum
            FROM payment
            GROUP BY invoice_id
        ) p
            ON p.invoice_id = i.invoice_id

        LEFT JOIN unpaid_invoices_v ui
            ON ui.invoice_id = i.invoice_id

        WHERE (p_invoice_id IS NULL OR i.invoice_id = p_invoice_id)

          AND (
              p_status IS NULL
              OR DECODE(
                     ui.invoice_id,
                     NULL, 'PAID',
                     'UNPAID'
                 ) = UPPER(p_status)
          )

        ORDER BY i.invoice_id
    )
    LOOP
        PIPE ROW(
            invoice_result_t(
                r.invoice_id,
                r.invoice_date,
                r.invoice_amount,
                r.currency,
                r.status,
                r.debt_amount
            )
        );
    END LOOP;

    RETURN;
END;
/
-------------------------------------------------------------------------------
-- Add payment API
-------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION add_payment (
    p_invoice_id      IN NUMBER,
    p_payment_date    IN DATE,
    p_payment_amount  IN NUMBER
)
RETURN payment_operation_result_t
AS
    l_invoice_date    invoice.invoice_date%TYPE;
    l_invoice_amount  invoice.invoice_amount%TYPE;
    l_currency        invoice.currency%TYPE;    
    l_payment_sum     NUMBER;
    l_debt_amount     NUMBER;
BEGIN
    ---------------------------------------------------------------------------
    -- Validate mandatory parameters
    ---------------------------------------------------------------------------

    IF p_invoice_id IS NULL THEN
        RETURN payment_operation_result_t('FAIL', -20031,'Invoice ID must be provided');
    END IF;

    IF p_payment_date IS NULL THEN
        RETURN payment_operation_result_t('FAIL',-20032,'Payment date must be provided');
    END IF;

    IF p_payment_amount IS NULL THEN
        RETURN payment_operation_result_t('FAIL',-20033,'Payment amount must be provided');
    END IF;

    IF p_payment_amount <= 0 THEN
        RETURN payment_operation_result_t('FAIL',-20034,'Payment amount must be greater than zero');
    END IF;

    ---------------------------------------------------------------------------
    -- Get invoice
    ---------------------------------------------------------------------------
    BEGIN
        SELECT invoice_date, invoice_amount, currency
        INTO l_invoice_date, l_invoice_amount, l_currency
        FROM invoice
        WHERE invoice_id = p_invoice_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN payment_operation_result_t('FAIL',-20035,'Invoice does not exist');
    END;

    ---------------------------------------------------------------------------
    -- Validate payment date
    ---------------------------------------------------------------------------

    IF TRUNC(p_payment_date) < TRUNC(l_invoice_date) THEN
        RETURN payment_operation_result_t('FAIL',-20036,'Payment date cannot be earlier than invoice date');
    END IF;

    IF TRUNC(p_payment_date) > TRUNC(SYSDATE) THEN
        RETURN payment_operation_result_t('FAIL',-20037,'Payment date cannot be in the future');
    END IF;

    ---------------------------------------------------------------------------
    -- Calculate outstanding debt
    ---------------------------------------------------------------------------

    SELECT NVL(SUM(payment_amount), 0)
    INTO l_payment_sum
    FROM payment
    WHERE invoice_id = p_invoice_id;

    l_debt_amount := l_invoice_amount - l_payment_sum;

    ---------------------------------------------------------------------------
    -- Validate outstanding debt
    ---------------------------------------------------------------------------

    IF l_debt_amount <= 0 THEN
        RETURN payment_operation_result_t('FAIL',-20038,'Invoice is already fully paid');
    END IF;

    IF p_payment_amount > l_debt_amount THEN
        RETURN payment_operation_result_t('FAIL',-20039,'Payment amount exceeds outstanding debt');
    END IF;

    ---------------------------------------------------------------------------
    -- Create payment
    ---------------------------------------------------------------------------

    INSERT INTO payment (invoice_id, payment_date,payment_amount,currency) VALUES (p_invoice_id,TRUNC(p_payment_date),p_payment_amount,l_currency);

    ---------------------------------------------------------------------------
    -- Successful result
    ---------------------------------------------------------------------------

    RETURN payment_operation_result_t('OK',NULL,'Payment successfully added');

EXCEPTION
    WHEN OTHERS THEN
        RETURN payment_operation_result_t('FAIL',SQLCODE,SQLERRM);
END;
/
