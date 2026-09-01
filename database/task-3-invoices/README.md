# Task 3 – Invoices

## Overview

The objective of this task is to return all invoices that are not fully paid.

Required output:

- `invoice_id`
- `invoice_date`

The solution does not use `EXISTS`.

## Database Objects

### INVOICE

Stores invoice information:

- `invoice_id`
- `invoice_date`
- `invoice_amount`
- `currency`

### PAYMENT

Stores payments related to invoices:

- `payment_id`
- `payment_date`
- `payment_amount`
- `currency`
- `invoice_id`

One invoice may have zero, one, or multiple payments.

A payment is assumed to be made in the same currency as its invoice. Currency conversion is therefore outside the scope of this task.

### UNPAID_INVOICES_V

The view contains invoices where the total amount paid is lower than the invoice amount.

Payments are first aggregated by `invoice_id`.

A `LEFT JOIN` is used so that invoices without any payments are also included. For such invoices, `NVL` converts the missing payment amount to zero.

```sql
CREATE OR REPLACE VIEW unpaid_invoices_v AS
WITH tp AS (
    SELECT
        invoice_id,
        SUM(payment_amount) AS payment_sum
    FROM payment
    GROUP BY invoice_id
)
SELECT
    i.invoice_id,
    i.invoice_date
FROM invoice i
LEFT JOIN tp
    ON i.invoice_id = tp.invoice_id
WHERE NVL(tp.payment_sum, 0) < i.invoice_amount;
```

The required result can be retrieved using:

```sql
SELECT
    invoice_id,
    invoice_date
FROM unpaid_invoices_v
ORDER BY invoice_id;
```

## Test Data

Test data is generated for invoices from `2026-01-01` until the current date.

Each day contains between 3 and 15 generated invoices.

The following currencies are used:

| Currency | Approximate distribution |
|---|---:|
| EUR | 50% |
| USD | 20% |
| SEK | 15% |
| GBP | 10% |
| JPY | 5% |

Payment data contains different payment scenarios:

- no payment;
- partial payment;
- full payment;
- multiple payments for the same invoice.

The probability of an invoice being unpaid increases for more recent invoice months. This provides a dataset where newer invoices are more likely to remain unpaid.

`DBMS_RANDOM.SEED` is used to make generated test data reproducible.

## Validation

Validation results are stored in `INVOICE_VALIDATION_RESULT`.

Each validation result contains:

- validation code;
- validation type;
- validation name;
- execution timestamp;
- status (`OK` or `FAIL`);
- error count;
- detailed error information.

Validation results are cleared before every validation run.

Two validation types are used.

### DATA Validations

These validations verify the consistency and quality of invoice and payment data.

| Code | Validation |
|---|---|
| VLD-01 | Payment date must not be before invoice date |
| VLD-02 | Payment date must not be in the future |
| VLD-03 | Payment currency must match invoice currency |
| VLD-04 | Payment amount must be positive |
| VLD-05 | Invoice amount must not be negative |
| VLD-06 | Total payment amount must not exceed invoice amount |

Some DATA validations intentionally overlap with database constraints.

Database constraints prevent invalid data from being created during normal operation, while the validation package provides an additional data-quality verification layer and makes it possible to report detected problems in a consistent format.

### QUERY Validations

These validations verify the functional behaviour of `UNPAID_INVOICES_V`.

| Code | Validation |
|---|---|
| VLD-07 | Invoice without payments must be returned |
| VLD-08 | Partially paid invoice must be returned |
| VLD-09 | Fully paid invoice must not be returned |
| VLD-10 | Multiple payments must be aggregated correctly |

Expected results are calculated independently and compared with the actual contents of `UNPAID_INVOICES_V`.

This verifies the actual query implementation rather than testing a duplicated copy of the same query.

## Negative Validation Testing

`05_corrupt_test_data.sql` intentionally introduces invalid data to demonstrate that the validation rules can detect errors.

The following conditions are created:

- VLD-01 – payment date before invoice date;
- VLD-02 – payment date in the future;
- VLD-03 – payment currency different from invoice currency;
- VLD-04 – zero payment amount;
- VLD-05 – negative invoice amount;
- VLD-06 – total payment amount exceeding invoice amount.

Separate records are selected where possible so that individual validation scenarios remain isolated.

For VLD-05, an invoice without payments is selected. This prevents the negative invoice amount from unintentionally creating an additional VLD-06 error.

### Constraint Handling

`PAYMENT_AMOUNT` and `INVOICE_AMOUNT` are protected by database `CHECK` constraints during normal operation.

To create intentionally invalid records for VLD-04 and VLD-05, the corresponding constraints are temporarily disabled.

After the invalid test data has been created, the constraints are re-enabled using:

```sql
ENABLE NOVALIDATE
```

This keeps the intentionally corrupted existing rows available for validation while enforcing the constraints again for future `INSERT` and `UPDATE` operations.

The negative test script is intended only for validation testing.

## Validation Results

For clean generated data, all validation rules are expected to return:

```text
OK
```

After executing `05_corrupt_test_data.sql`, the expected result is:

```text
VLD-01  DATA   FAIL
VLD-02  DATA   FAIL
VLD-03  DATA   FAIL
VLD-04  DATA   FAIL
VLD-05  DATA   FAIL
VLD-06  DATA   FAIL

VLD-07  QUERY  OK
VLD-08  QUERY  OK
VLD-09  QUERY  OK
VLD-10  QUERY  OK
```

`RESULT_DETAILS` identifies the affected `INVOICE_ID` and, where applicable, `PAYMENT_ID`, dates, currencies and amounts.

## Execution

### Clean Validation

Run the scripts in the following order:

```text
01_create_structures.sql
02_seed_data.sql
03_create_unpaid_invoices_view.sql
04_create_validation_objects.sql
06_run_validation.sql
```

All validation rules are expected to return `OK`.

### Negative Validation

Run:

```text
01_create_structures.sql
02_seed_data.sql
03_create_unpaid_invoices_view.sql
04_create_validation_objects.sql
05_corrupt_test_data.sql
06_run_validation.sql
```

`VLD-01` through `VLD-06` are expected to detect the intentionally corrupted data.

The clean dataset can be recreated by running the structure and seed scripts again.

## Files

```text
01_create_structures.sql
02_seed_data.sql
03_create_unpaid_invoices_view.sql
04_create_validation_objects.sql
05_corrupt_test_data.sql
06_run_validation.sql
README.md
```

## Design Decisions

- Payments are aggregated by `invoice_id` before comparison with the invoice amount.
- `LEFT JOIN` ensures that invoices without payments are included.
- `NVL` treats the absence of payments as zero paid.
- Payment and invoice currencies are assumed to match; FX conversion is outside the scope of the task.
- The solution does not use `EXISTS`.
- The unpaid invoice logic is exposed through a view so the same implementation can be reused by SQL clients, application code and functional tests.
- DATA and QUERY validations are separated by validation type.
- QUERY validations test the actual `UNPAID_INVOICES_V` result against independently calculated expected scenarios.
- Negative test data is intentionally created to demonstrate that validation rules detect invalid conditions.
- Constraints temporarily disabled for negative testing are re-enabled with `ENABLE NOVALIDATE`.
