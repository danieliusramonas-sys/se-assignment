-------------------------------------------------------------------------------
-- Test ADD_PAYMENT function
-------------------------------------------------------------------------------
DECLARE
    l_result              payment_operation_result_t;
    l_payment_count_before NUMBER;
    l_payment_count_after  NUMBER;
    l_test_amount          NUMBER := 10;
    l_invoice_id           NUMBER := 4162;
BEGIN
    ---------------------------------------------------------------------------
    -- Test 1: Valid payment
    ---------------------------------------------------------------------------

    SELECT COUNT(*)
    INTO l_payment_count_before
    FROM payment
    WHERE invoice_id = l_invoice_id
      AND payment_date = TRUNC(SYSDATE)
      AND payment_amount = l_test_amount;

    l_result := add_payment(
        l_invoice_id,
        TRUNC(SYSDATE),
        l_test_amount
    );

    SELECT COUNT(*)
    INTO l_payment_count_after
    FROM payment
    WHERE invoice_id = l_invoice_id
      AND payment_date = TRUNC(SYSDATE)
      AND payment_amount = l_test_amount;

	DBMS_OUTPUT.PUT_LINE('----------------------------------------');
	DBMS_OUTPUT.PUT_LINE('Test 1 - Valid payment');
	DBMS_OUTPUT.PUT_LINE('Expected status: OK');
	DBMS_OUTPUT.PUT_LINE('Actual status:     ' || l_result.status_code);
	DBMS_OUTPUT.PUT_LINE('Actual error code: ' || NVL(TO_CHAR(l_result.error_code), 'NULL'));
	DBMS_OUTPUT.PUT_LINE('Actual message:    ' || l_result.message);
	DBMS_OUTPUT.PUT_LINE('Expected payment row increase: 1');
	DBMS_OUTPUT.PUT_LINE('Actual payment row increase:   ' || (l_payment_count_after - l_payment_count_before));
    IF l_result.status_code = 'OK'
       AND l_payment_count_after - l_payment_count_before = 1
    THEN
        DBMS_OUTPUT.PUT_LINE('RESULT: PASS');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULT: FAIL');
    END IF;


    ---------------------------------------------------------------------------
    -- Test 2: Payment amount exceeds debt
    ---------------------------------------------------------------------------

    l_result := add_payment(
        l_invoice_id,
        TRUNC(SYSDATE),
        999999999
    );

    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Test 2 - Payment amount exceeds debt');
    DBMS_OUTPUT.PUT_LINE('Expected status:     FAIL');
    DBMS_OUTPUT.PUT_LINE('Expected error code: -20039');
    DBMS_OUTPUT.PUT_LINE('Actual status:       ' || l_result.status_code);
    DBMS_OUTPUT.PUT_LINE('Actual error code:   ' || l_result.error_code);
    DBMS_OUTPUT.PUT_LINE('Actual message:      ' || l_result.message);

    IF l_result.status_code = 'FAIL'
       AND l_result.error_code = -20039
    THEN
        DBMS_OUTPUT.PUT_LINE('RESULT: PASS');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULT: FAIL');
    END IF;


    ---------------------------------------------------------------------------
    -- Test 3: Future payment date
    ---------------------------------------------------------------------------

    l_result := add_payment(
        l_invoice_id,
        TRUNC(SYSDATE) + 1,
        1
    );

    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Test 3 - Future payment date');
    DBMS_OUTPUT.PUT_LINE('Expected status:     FAIL');
    DBMS_OUTPUT.PUT_LINE('Expected error code: -20037');
    DBMS_OUTPUT.PUT_LINE('Actual status:       ' || l_result.status_code);
    DBMS_OUTPUT.PUT_LINE('Actual error code:   ' || l_result.error_code);
    DBMS_OUTPUT.PUT_LINE('Actual message:      ' || l_result.message);

    IF l_result.status_code = 'FAIL'
       AND l_result.error_code = -20037
    THEN
        DBMS_OUTPUT.PUT_LINE('RESULT: PASS');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULT: FAIL');
    END IF;


    ---------------------------------------------------------------------------
    -- Test 4: Payment date earlier than invoice date
    ---------------------------------------------------------------------------

    l_result := add_payment(
        l_invoice_id,
        DATE '2025-12-31',
        1
    );

    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Test 4 - Payment date before invoice date');
    DBMS_OUTPUT.PUT_LINE('Expected status:     FAIL');
    DBMS_OUTPUT.PUT_LINE('Expected error code: -20036');
    DBMS_OUTPUT.PUT_LINE('Actual status:       ' || l_result.status_code);
    DBMS_OUTPUT.PUT_LINE('Actual error code:   ' || l_result.error_code);
    DBMS_OUTPUT.PUT_LINE('Actual message:      ' || l_result.message);

    IF l_result.status_code = 'FAIL'
       AND l_result.error_code = -20036
    THEN
        DBMS_OUTPUT.PUT_LINE('RESULT: PASS');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULT: FAIL');
    END IF;


    ---------------------------------------------------------------------------
    -- Test 5: Invalid invoice
    ---------------------------------------------------------------------------

    l_result := add_payment(
        -999999,
        TRUNC(SYSDATE),
        1
    );

    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Test 5 - Invoice does not exist');
    DBMS_OUTPUT.PUT_LINE('Expected status:     FAIL');
    DBMS_OUTPUT.PUT_LINE('Expected error code: -20035');
    DBMS_OUTPUT.PUT_LINE('Actual status:       ' || l_result.status_code);
    DBMS_OUTPUT.PUT_LINE('Actual error code:   ' || l_result.error_code);
    DBMS_OUTPUT.PUT_LINE('Actual message:      ' || l_result.message);

    IF l_result.status_code = 'FAIL'
       AND l_result.error_code = -20035
    THEN
        DBMS_OUTPUT.PUT_LINE('RESULT: PASS');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULT: FAIL');
    END IF;


    ---------------------------------------------------------------------------
    -- Cleanup test payment
    ---------------------------------------------------------------------------

    DELETE FROM payment
    WHERE invoice_id = l_invoice_id
      AND payment_date = TRUNC(SYSDATE)
      AND payment_amount = l_test_amount;

    ROLLBACK;
    
        ---------------------------------------------------------------------------
    -- Test 6: NULL invoice ID
    ---------------------------------------------------------------------------

    l_result := add_payment(
        NULL,
        TRUNC(SYSDATE),
        1
    );

    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Test 6 - NULL invoice ID');
    DBMS_OUTPUT.PUT_LINE('Expected status:     FAIL');
    DBMS_OUTPUT.PUT_LINE('Expected error code: -20031');
    DBMS_OUTPUT.PUT_LINE('Actual status:       ' || l_result.status_code);
    DBMS_OUTPUT.PUT_LINE('Actual error code:   ' || l_result.error_code);
    DBMS_OUTPUT.PUT_LINE('Actual message:      ' || l_result.message);

    IF l_result.status_code = 'FAIL'
       AND l_result.error_code = -20031
    THEN
        DBMS_OUTPUT.PUT_LINE('RESULT: PASS');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULT: FAIL');
    END IF;


    ---------------------------------------------------------------------------
    -- Test 7: NULL payment date
    ---------------------------------------------------------------------------

    l_result := add_payment(
        l_invoice_id,
        NULL,
        1
    );

    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Test 7 - NULL payment date');
    DBMS_OUTPUT.PUT_LINE('Expected status:     FAIL');
    DBMS_OUTPUT.PUT_LINE('Expected error code: -20032');
    DBMS_OUTPUT.PUT_LINE('Actual status:       ' || l_result.status_code);
    DBMS_OUTPUT.PUT_LINE('Actual error code:   ' || l_result.error_code);
    DBMS_OUTPUT.PUT_LINE('Actual message:      ' || l_result.message);

    IF l_result.status_code = 'FAIL'
       AND l_result.error_code = -20032
    THEN
        DBMS_OUTPUT.PUT_LINE('RESULT: PASS');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULT: FAIL');
    END IF;


    ---------------------------------------------------------------------------
    -- Test 8: NULL payment amount
    ---------------------------------------------------------------------------

    l_result := add_payment(
        l_invoice_id,
        TRUNC(SYSDATE),
        NULL
    );

    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Test 8 - NULL payment amount');
    DBMS_OUTPUT.PUT_LINE('Expected status:     FAIL');
    DBMS_OUTPUT.PUT_LINE('Expected error code: -20033');
    DBMS_OUTPUT.PUT_LINE('Actual status:       ' || l_result.status_code);
    DBMS_OUTPUT.PUT_LINE('Actual error code:   ' || l_result.error_code);
    DBMS_OUTPUT.PUT_LINE('Actual message:      ' || l_result.message);

    IF l_result.status_code = 'FAIL'
       AND l_result.error_code = -20033
    THEN
        DBMS_OUTPUT.PUT_LINE('RESULT: PASS');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULT: FAIL');
    END IF;


    ---------------------------------------------------------------------------
    -- Test 9: Payment amount must be greater than zero
    ---------------------------------------------------------------------------

    l_result := add_payment(
        l_invoice_id,
        TRUNC(SYSDATE),
        0
    );

    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Test 9 - Payment amount = 0');
    DBMS_OUTPUT.PUT_LINE('Expected status:     FAIL');
    DBMS_OUTPUT.PUT_LINE('Expected error code: -20034');
    DBMS_OUTPUT.PUT_LINE('Actual status:       ' || l_result.status_code);
    DBMS_OUTPUT.PUT_LINE('Actual error code:   ' || l_result.error_code);
    DBMS_OUTPUT.PUT_LINE('Actual message:      ' || l_result.message);

    IF l_result.status_code = 'FAIL'
       AND l_result.error_code = -20034
    THEN
        DBMS_OUTPUT.PUT_LINE('RESULT: PASS');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULT: FAIL');
    END IF;
    
    ---------------------------------------------------------------------------
    -- Test 10: Invoice already fully paid
    ---------------------------------------------------------------------------

    DECLARE
        l_paid_invoice_id invoice.invoice_id%TYPE;
    BEGIN
        SELECT invoice_id
        INTO l_paid_invoice_id
        FROM (
            SELECT i.invoice_id
            FROM invoice i
            LEFT JOIN (
                SELECT
                    invoice_id,
                    SUM(payment_amount) AS payment_sum
                FROM payment
                GROUP BY invoice_id
            ) p
                ON p.invoice_id = i.invoice_id
            WHERE NVL(p.payment_sum, 0) >= i.invoice_amount
            ORDER BY i.invoice_id
        )
        WHERE ROWNUM = 1;

        l_result := add_payment(
            l_paid_invoice_id,
            TRUNC(SYSDATE),
            1
        );

        DBMS_OUTPUT.PUT_LINE('----------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Test 10 - Invoice already fully paid');
        DBMS_OUTPUT.PUT_LINE('Invoice ID:          ' || l_paid_invoice_id);
        DBMS_OUTPUT.PUT_LINE('Expected status:     FAIL');
        DBMS_OUTPUT.PUT_LINE('Expected error code: -20038');
        DBMS_OUTPUT.PUT_LINE('Actual status:       ' || l_result.status_code);
        DBMS_OUTPUT.PUT_LINE('Actual error code:   ' || l_result.error_code);
        DBMS_OUTPUT.PUT_LINE('Actual message:      ' || l_result.message);

        IF l_result.status_code = 'FAIL'
           AND l_result.error_code = -20038
        THEN
            DBMS_OUTPUT.PUT_LINE('RESULT: PASS');
        ELSE
            DBMS_OUTPUT.PUT_LINE('RESULT: FAIL');
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('----------------------------------------');
            DBMS_OUTPUT.PUT_LINE('Test 10 - Invoice already fully paid');
            DBMS_OUTPUT.PUT_LINE('RESULT: FAIL');
            DBMS_OUTPUT.PUT_LINE('No fully paid invoice exists in the current test data');
    END;

    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Test cleanup completed.');
END;
/


