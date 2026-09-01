# Task 2 - Calculate PI

## Overview

This task implements a PL/SQL function for calculating π using the Bailey-Borwein-Plouffe (BBP) formula.
The function accepts the requested number of decimal places as input, calculates π iteratively, and stores intermediate calculation results in a database table.
Before each valid calculation, intermediate results from the previous execution are removed.

------------------------------------------------------------------------

## BBP Formula

The calculation uses the Bailey-Borwein-Plouffe formula:

π = Σ (1 / 16\^i) \* (4 / (8i + 1) - 2 / (8i + 4) - 1 / (8i + 5) - 1 / (8i + 6))

where `i` starts from `0`.

The formula converges rapidly because each successive term is scaled by `1 / 16^i`.

------------------------------------------------------------------------

## Database Objects

### PI_CALCULATION_RESULT

Stores intermediate results produced during the calculation.

Columns:

-   `ITERATION_NO` -- BBP iteration number, starting from 0
-   `TERM_VALUE` -- BBP term calculated for the current iteration
-   `CALCULATED_PI` -- accumulated π value after the current iteration

The table contains results only from the latest calculation execution.

### PI_TEST_DATA

Contains static reference values used by the test procedure.

Columns:

-   `TEST_CASE_ID` -- test case identifier
-   `PRECISION` -- requested number of decimal places
-   `EXPECTED_PI` -- expected rounded value of π

The expected values are stored independently from the calculation function so that the function is not tested against values produced by itself.

------------------------------------------------------------------------

## Function

### CALCULATE_PI

``` sql
calculate_pi(p_precision IN PLS_INTEGER)
RETURN NUMBER
```

This is the main implementation function. `p_precision` represents the requested number of decimal places.

For example:

``` sql
SELECT calculate_pi(5) FROM dual;
```

returns:

``` text
3.14159
```

Supported precision is from 1 to 37 decimal places. The upper limit is based on the precision available with Oracle `NUMBER`, which supports approximately 38 significant decimal digits.

Invalid precision values are rejected using explicit application errors:

-   `-20011` -- precision is NULL or less than 1
-   `-20012` -- precision exceeds 37 decimal places

------------------------------------------------------------------------

## Convergence

The calculation is performed iteratively. After each BBP iteration, the newly calculated term is added to the accumulated π value.
The calculation stops when two consecutive approximations produce the same rounded value at a slightly higher precision than requested. 
Two additional decimal places are used as guard digits when checking convergence:

``` sql
l_check_precision := LEAST(p_precision + 2, 37);
...
EXIT WHEN ROUND(l_pi, l_check_precision) =
          ROUND(l_previous_pi, l_check_precision);
```

This reduces the risk of stopping the calculation too early when two consecutive approximations temporarily produce the same rounded value at the requested precision.
The final result is returned rounded to the requested precision:

``` sql
ROUND(l_pi, p_precision)
```

------------------------------------------------------------------------

## Intermediate Results

Every BBP iteration is stored in `PI_CALCULATION_RESULT`.

Example:

``` sql
SELECT *
FROM pi_calculation_result
ORDER BY iteration_no;
```

The stored data makes it possible to inspect how the calculated value converges toward π. Before each valid execution, previous intermediate results are deleted.
The function uses an autonomous transaction because it performs DML while remaining directly callable from SQL:

``` sql
SELECT calculate_pi(10) FROM dual;
```

Intermediate results are therefore committed independently from the calling transaction. This behavior is intentional for this assignment because intermediate calculation results are explicitly required to be persisted.

------------------------------------------------------------------------

## Test Runner

The `TEST_CALCULATE_PI` procedure validates the function against static reference values stored in `PI_TEST_DATA`. The test data covers precision values from 3 through 37 decimal places.

Run the tests with:

``` sql
BEGIN
    test_calculate_pi;
END;
/
```

Expected output:

``` text
Running calculate_pi tests...
----------------------------------------
Tests executed: 35
Successful:     35
Failed:         0
RESULT: OK
```
------------------------------------------------------------------------

## Design Decisions
-   **BBP Algorithm:** The Bailey--Borwein--Plouffe formula is implemented directly using a PL/SQL `LOOP` to keep the implementation readable and aligned with the provided mathematical formula.
-   **Precision Interpretation:** Input precision represents the number of requested decimal places.
-   **Convergence & Guard Digits:** Two additional guard digits are used when comparing consecutive approximations to reduce the risk of stopping the calculation too early.
-   **Oracle NUMBER:** The implementation supports up to 37 decimal places. This limit reflects the approximately 38 significant decimal digits available with Oracle `NUMBER`, with one digit required before the decimal point for π.
-   **Intermediate Results:** Previous intermediate results are removed before each valid calculation, so the table contains data only from the latest execution.
-   **Transaction Handling:** `PRAGMA AUTONOMOUS_TRANSACTION` allows the function to persist intermediate results while remaining directly callable from a SQL `SELECT` statement. The intermediate results are committed independently from the calling transaction.
-   **Testing Independence:** Expected π values are stored as static test data rather than generated by `CALCULATE_PI`, keeping the expected results independent from the implementation being tested.
