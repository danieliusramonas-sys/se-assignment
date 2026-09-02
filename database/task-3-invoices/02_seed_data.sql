--------------------------------------------------------------------------------
-- Task 3 - Invoices
--------------------------------------------------------------------------------
DELETE FROM payment where 1=1;
DELETE FROM invoice where 1=1;
--------------------------------------------------------------------------------
-- Generate invoices for 2026
--
-- 3 to 15 invoices are generated for each calendar day.
--
-- Currency distribution:
--     EUR  50%
--     USD  20%
--     SEK  15%
--     GBP  10%
--     JPY   5%
--------------------------------------------------------------------------------

DECLARE
    l_start_date    DATE := DATE '2026-01-01';
    l_end_date      DATE := LEAST(TRUNC(SYSDATE), DATE '2026-12-31');

    l_date          DATE;
    l_invoice_count PLS_INTEGER;
    l_currency      VARCHAR2(3);
    l_random        NUMBER;
    l_amount        NUMBER(18, 2);

BEGIN
    DBMS_RANDOM.SEED(202601);

    l_date := l_start_date;

    WHILE l_date <= l_end_date
    LOOP
        ------------------------------------------------------------------------
        -- Generate between 3 and 15 invoices per day
        ------------------------------------------------------------------------
        l_invoice_count := TRUNC(DBMS_RANDOM.VALUE(3, 16));

        FOR i IN 1 .. l_invoice_count
        LOOP
            --------------------------------------------------------------------
            -- Select currency according to configured distribution
            --------------------------------------------------------------------
            l_random := DBMS_RANDOM.VALUE(0, 100);

            l_currency :=
                CASE
                    WHEN l_random < 50 THEN 'EUR'
                    WHEN l_random < 70 THEN 'USD'
                    WHEN l_random < 85 THEN 'SEK'
                    WHEN l_random < 95 THEN 'GBP'
                    ELSE                    'JPY'
                END;

            --------------------------------------------------------------------
            -- Generate invoice amount
            --
            -- Amounts are generated in the invoice currency.
            --------------------------------------------------------------------
            l_amount :=
                CASE l_currency 
                WHEN 'EUR' THEN ROUND(DBMS_RANDOM.VALUE(50, 10000), 2)
		WHEN 'USD' THEN ROUND(DBMS_RANDOM.VALUE(50, 12000), 2)
                WHEN 'SEK' THEN ROUND(DBMS_RANDOM.VALUE(500, 100000), 2)
                WHEN 'GBP' THEN ROUND(DBMS_RANDOM.VALUE(50, 8000), 2)
                WHEN 'JPY' THEN ROUND(DBMS_RANDOM.VALUE(5000, 1500000), 2)
                END;

            INSERT INTO invoice ( invoice_date,invoice_amount, currency) VALUES (l_date,l_amount,l_currency);
        END LOOP;

        l_date := l_date + 1;
    END LOOP;
COMMIT;
END;
/
--------------------------------------------------------------------------------
-- Generate payments
--
-- Debt probability:
--     invoice month number * 8%
--
-- Coverage:
--     unpaid invoices: 0%, 10%, 50%
--     paid invoices:   100%
--
-- Number of payment rows:
--     invoice_id divisible by 7 -> random 1..5
--     invoice_id divisible by 5 -> random 1..3
--     otherwise                 -> 1
--
-- If invoice_id is divisible by both 5 and 7,
-- the rule for 7 takes precedence.
--
-- Payment dates:
--     invoice_date .. invoice_date + 100 days
--     never later than today.
--------------------------------------------------------------------------------

DECLARE
    l_debt_probability NUMBER;
    l_random           NUMBER;
    l_coverage         NUMBER;

    l_payment_count    PLS_INTEGER;
    l_max_days         PLS_INTEGER;
    l_payment_date     DATE;

    l_total_payment    NUMBER(18, 2);
    l_remaining_amount NUMBER(18, 2);

    l_total_weight     NUMBER;
    l_payment_amount   NUMBER(18, 2);

    TYPE t_weights IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    l_weights t_weights;

BEGIN
    DBMS_RANDOM.SEED(202602);

    FOR r_invoice IN (
        SELECT
            invoice_id,
            invoice_date,
            invoice_amount,
            currency
        FROM invoice
        ORDER BY invoice_id
    )
    LOOP
        ------------------------------------------------------------------------
        -- Probability that invoice is not fully paid:
        --
        -- January   =  8%
        -- February  = 16%
        -- ...
        -- September = 72%
        ------------------------------------------------------------------------
        l_debt_probability := EXTRACT(MONTH FROM r_invoice.invoice_date) * 8;
        l_random := DBMS_RANDOM.VALUE(0, 100);
        
        IF l_random < l_debt_probability THEN

            --------------------------------------------------------------------
            -- Invoice is not fully paid:
            -- randomly select 0%, 10% or 50% coverage.
            --------------------------------------------------------------------
            l_random := DBMS_RANDOM.VALUE(0, 100);

            l_coverage :=
                CASE
                    WHEN l_random < 33.3333 THEN 0
                    WHEN l_random < 66.6667 THEN 0.10
                    ELSE                        0.50
                END;

        ELSE
            --------------------------------------------------------------------
            -- Fully paid invoice
            --------------------------------------------------------------------
            l_coverage := 1;
        END IF;
        ------------------------------------------------------------------------
        -- 0% coverage means no PAYMENT records.
        ------------------------------------------------------------------------
        IF l_coverage > 0 THEN

            l_total_payment := ROUND(r_invoice.invoice_amount * l_coverage, 2);
            --------------------------------------------------------------------
            -- Determine number of payment rows.
            --
            -- Divisible by 7 has priority over divisible by 5.
            ------------------------------------------------------------------------
            IF MOD(r_invoice.invoice_id, 7) = 0 THEN
                l_payment_count := TRUNC(DBMS_RANDOM.VALUE(1, 6));       -- 1..5
            ELSIF MOD(r_invoice.invoice_id, 5) = 0 THEN
                l_payment_count := TRUNC(DBMS_RANDOM.VALUE(1, 4));       -- 1..3
            ELSE
                l_payment_count := 1;
            END IF;
            --------------------------------------------------------------------
            -- Generate random weights used to split the total payment amount.
            --------------------------------------------------------------------
            l_total_weight := 0;

            FOR i IN 1 .. l_payment_count
            LOOP
                l_weights(i) := DBMS_RANDOM.VALUE(0.5, 1.5);
                l_total_weight := l_total_weight + l_weights(i);
            END LOOP;

            --------------------------------------------------------------------
            -- Maximum payment delay:
            -- 100 days or today, whichever comes first.
            --------------------------------------------------------------------
            l_max_days :=LEAST(100,TRUNC(SYSDATE) - TRUNC(r_invoice.invoice_date));
            l_remaining_amount := l_total_payment;
            --------------------------------------------------------------------
            -- Generate PAYMENT rows.
            --------------------------------------------------------------------
            FOR i IN 1 .. l_payment_count
            LOOP
                ----------------------------------------------------------------
                -- Last payment receives the remaining amount.
                -- This prevents rounding differences between PAYMENT sum
                -- and the intended invoice coverage.
                ----------------------------------------------------------------
                IF i = l_payment_count THEN
                    l_payment_amount := l_remaining_amount;
                ELSE
                    l_payment_amount := ROUND(l_total_payment * l_weights(i) / l_total_weight,2);
                    l_remaining_amount := l_remaining_amount - l_payment_amount;
                END IF;

                ----------------------------------------------------------------
                -- Random payment date between invoice date and maximum date.
                ----------------------------------------------------------------
                l_payment_date := r_invoice.invoice_date + TRUNC(DBMS_RANDOM.VALUE(0, l_max_days + 1 ));
                INSERT INTO payment (payment_date,payment_amount,currency,invoice_id) VALUES (l_payment_date,l_payment_amount,r_invoice.currency,r_invoice.invoice_id);

            END LOOP;

        END IF;

    END LOOP;
COMMIT;
END;
/

