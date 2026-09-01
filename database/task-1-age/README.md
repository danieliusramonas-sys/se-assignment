# Task 1 – Age Classification

## Overview

This task implements an Oracle PL/SQL solution that classifies a person by age.

The classification is configuration-driven. Age ranges and their corresponding
descriptions are stored in the `AGE_CATEGORY` table, allowing the classification
rules to be maintained without changing the PL/SQL code.

## Age Categories

The configuration table defines age ranges using inclusive boundaries:

| Age Range | Description |
|---|---|
| 0 – 6 | You are infant |
| 7 – 17 | You are schoolchild |
| 18 – 39 | You are adult |
| 40 – 54 | You are in middle-age |
| >= 55 | You are aged |

The assignment requirements are mapped to inclusive database ranges.
For example, the requirement `7 <= X < 18` is represented by the
configured range `7–17`.

`GET_AGE_RESULT` finds the matching category using the lower and upper
boundaries stored in `AGE_CATEGORY`. A `NULL` upper boundary represents
an open-ended range, such as `>= 55`.

## Database Objects

The solution consists of the following database objects:

* **AGE_CATEGORY** (Table) – Configuration table containing age ranges and their descriptions.
  - `MIN_AGE` – inclusive lower boundary (`NUMBER(3)`)
  - `MAX_AGE` – inclusive upper boundary (`NUMBER(3)`, where `NULL` represents an open-ended upper range)
  - `DESCRIPTION` – description associated with the range (`VARCHAR2(100)`)
* **AGE_RESULT_T** (Object Type) – Oracle object type used for a structured function result:
  - `STATUS_CODE` – `OK` or `FAIL`
  - `ERROR_CODE` – application error code, if applicable
  - `MESSAGE` – configured age description or error message
* **AGE_TEST_DATA** (Table) – Contains input values used by the test runner. The standard seed data generates ages `0–99`.

## Functions

### GET_AGE_RESULT

```sql
get_age_result(p_age NUMBER)
RETURN age_result_t
```

This is the main implementation function. Decimal age values are supported and normalized to completed years using Oracle `TRUNC` before classification. For example, both `17.4` and `17.9` are classified using the completed age of `17`.

For a valid age, the function searches `AGE_CATEGORY` for the matching range and
returns:

```text
OK | NULL | <configured description>
```

Validation and configuration errors are returned as structured `FAIL` results.

| Error code | Description |
|---|---|
| -20001 | Age must be provided |
| -20002 | Age cannot be negative |
| -20003 | Age range is not configured |
| -20004 | Age range configuration is ambiguous |

The last two cases protect against missing or overlapping range configuration.

### GET_AGE_DESCRIPTION

```sql
get_age_description(p_age NUMBER)
RETURN VARCHAR2
```

A simple number-to-text wrapper around `GET_AGE_RESULT`. It provides the interface required by the assignment while keeping the classification and validation logic in one place.

For a valid input, the function returns the configured age description.

Example:

```sql
SELECT get_age_description(25) FROM dual;
```

Result:

```text
You are adult
```

If the input is invalid, the function returns an error message in the following format:

```text
ERROR: <error description>
```

Examples:

```sql
SELECT get_age_description(-1) FROM dual;
-- Result: ERROR: Age cannot be negative

SELECT get_age_description(NULL) FROM dual;
-- Result: ERROR: Age must be provided
```

For callers that require programmatic error handling, `GET_AGE_RESULT` provides the structured status, error code and message.

## Test Runner

`TEST_GET_AGE_RESULT` executes `GET_AGE_RESULT` for every input stored in `AGE_TEST_DATA`. The runner processes the complete dataset even when a `FAIL` result is found, allowing all invalid inputs to be reported in a single execution.

Run:

```sql
BEGIN
    test_get_age_result;
END;
/
```

Example output with the standard `0–99` test dataset:

```text
Running get_age_result tests...
----------------------------------------
Tests executed: 100
Successful:     100
Failed:         0
RESULT: OK
```

Additional invalid inputs can be added to demonstrate validation and error reporting:

```sql
INSERT INTO age_test_data (age) VALUES (-1);
INSERT INTO age_test_data (age) VALUES (NULL);
COMMIT;
```

Example output with errors:

```text
Running get_age_result tests...
----------------------------------------
FAIL | test_case_id=101 | age=-1 | error_code=-20002 | message=Age cannot be negative
FAIL | test_case_id=102 | age=NULL | error_code=-20001 | message=Age must be provided
----------------------------------------
Tests executed: 102
Successful:     100
Failed:         2
RESULT: FAIL
```

## Design Decisions

* **Data-Driven Architecture:** The age classification is data-driven rather than hardcoded in PL/SQL. `AGE_CATEGORY` is the sole source of the classification rules.
* **Separation of Concerns:** `GET_AGE_RESULT` contains all the core classification and validation logic. `GET_AGE_DESCRIPTION` is intentionally kept as a thin wrapper to avoid duplicating business logic.
* **Boundary & Decimal Handling:** An open-ended range is represented by `MAX_AGE IS NULL`. Input values are normalized to completed years using Oracle `TRUNC` to seamlessly align decimal age values with the underlying discrete database ranges.
* **Exception Mapping:** Database constraints validate individual range definitions, while the function detects missing (`NO_DATA_FOUND`) or ambiguous (`TOO_MANY_ROWS`) configuration and maps these cases to explicit application errors.

