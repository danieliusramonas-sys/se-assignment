CREATE OR REPLACE PROCEDURE test_calculate_pi
IS
    l_actual_pi     NUMBER;
    l_total_count   PLS_INTEGER := 0;
    l_success_count PLS_INTEGER := 0;
    l_failed_count  PLS_INTEGER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Running calculate_pi tests...');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');

    FOR r IN (
        SELECT
            test_case_id,
            precision,
            expected_pi
        FROM pi_test_data
        ORDER BY precision
    )
    LOOP
        l_total_count := l_total_count + 1;

        BEGIN
            l_actual_pi := calculate_pi(r.precision);

            IF l_actual_pi = r.expected_pi THEN
                l_success_count := l_success_count + 1;
            ELSE
                l_failed_count := l_failed_count + 1;

                DBMS_OUTPUT.PUT_LINE(
                    'FAIL'
                    || ' | test_case_id=' || r.test_case_id
                    || ' | precision=' || r.precision
                    || ' | expected=' || TO_CHAR(r.expected_pi)
                    || ' | actual=' || TO_CHAR(l_actual_pi)
                );
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                l_failed_count := l_failed_count + 1;

                DBMS_OUTPUT.PUT_LINE(
                    'FAIL'
                    || ' | test_case_id=' || r.test_case_id
                    || ' | precision=' || r.precision
                    || ' | error=' || SQLERRM
                );
        END;
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
    test_calculate_pi;
END;
/
