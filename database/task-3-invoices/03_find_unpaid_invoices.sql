-- Task 3
-- Return all invoices that are not fully paid.
-- Invoices without payments are treated as unpaid.
-- EXISTS is intentionally not used.
-- View returning invoices that are not fully paid.

CREATE OR REPLACE VIEW unpaid_invoices_v AS
WITH tp AS (
    SELECT
        invoice_id,
        SUM(payment_amount) AS payment_sum
    FROM payment
    GROUP BY invoice_id
),
tt AS (
    SELECT
        i.invoice_id,
        i.invoice_date
    FROM invoice i
    LEFT JOIN tp
        ON i.invoice_id = tp.invoice_id
    WHERE NVL(tp.payment_sum, 0) < i.invoice_amount
)
SELECT
    invoice_id,
    invoice_date
FROM tt
ORDER BY invoice_id;

select * from unpaid_invoices_v;
