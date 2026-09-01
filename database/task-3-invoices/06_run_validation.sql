-- Task 3
-- Run all invoice validations and display results.

BEGIN
    invoice_validation_pkg.run_all;
END;


-------------------------------------------------------------------------------
-- Detailed validation results
-------------------------------------------------------------------------------

SELECT
    validation_code,
    validation_type,
    validation_name,
    validation_time,
    status,
    error_count,
    result_details
FROM invoice_validation_result
ORDER BY validation_code;


-------------------------------------------------------------------------------
-- Validation summary
-------------------------------------------------------------------------------

SELECT
    COUNT(*) AS validations_executed,
    SUM(CASE WHEN status = 'OK' THEN 1 ELSE 0 END) AS cnt_successful,
    SUM(CASE WHEN status = 'FAIL' THEN 1 ELSE 0 END) AS cnt_failed,
    CASE
        WHEN SUM(CASE WHEN status = 'FAIL' THEN 1 ELSE 0 END) = 0
            THEN 'OK'
        ELSE 'FAIL'
    END AS overall_status
FROM invoice_validation_result;

06_run_validation.sql
