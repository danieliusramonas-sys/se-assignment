-- 04_test.sql
-- Test runner for get_age_result().
--
-- The procedure processes all input values from AGE_TEST_DATA.
-- All test cases are executed even if failures are found.
-- Failed results are reported at the end.

CREATE OR REPLACE PROCEDURE test_get_age_result
IS
    l_result        age_result_t;
    l_total_count   PLS_INTEGER := 0;
    l_success_count PLS_INTEGER := 0;
    l_failed_count  PLS_INTEGER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Running get_age_result tests...');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');

    FOR r IN (
        SELECT
            test_case_id,
            age
        FROM age_test_data
        ORDER BY test_case_id
    )
    LOOP
        l_total_count := l_total_count + 1;

        l_result := get_age_result(r.age);

        IF l_result.status_code = 'OK' THEN
            l_success_count := l_success_count + 1;
        ELSE
            l_failed_count := l_failed_count + 1;

            DBMS_OUTPUT.PUT_LINE(
                'FAIL'
                || ' | test_case_id=' || r.test_case_id
                || ' | age=' || NVL(TO_CHAR(r.age), 'NULL')
                || ' | error_code='
                || NVL(TO_CHAR(l_result.error_code), 'NULL')
                || ' | message='
                || NVL(l_result.message, 'NULL')
            );
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Tests executed: ' || l_total_count);
    DBMS_OUTPUT.PUT_LINE('Successful:     ' || l_success_count);
    DBMS_OUTPUT.PUT_LINE('Failed:         ' || l_failed_count);

    IF l_failed_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('RESULT: OK');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULT: FAIL');
    END IF;
END;
/

BEGIN
    test_get_age_result;
END;
/
