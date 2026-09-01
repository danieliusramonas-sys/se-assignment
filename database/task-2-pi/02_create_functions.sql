CREATE OR REPLACE FUNCTION calculate_pi (
    p_precision IN PLS_INTEGER
)
RETURN NUMBER
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_iteration   PLS_INTEGER := 0;
    l_term        NUMBER;
    l_pi          NUMBER := 0;
    l_previous_pi NUMBER;
    l_check_precision PLS_INTEGER;
BEGIN
    IF p_precision IS NULL OR p_precision < 1 THEN
        RAISE_APPLICATION_ERROR(
            -20011,
            'Precision must be greater than zero'
        );
    END IF;

    IF p_precision > 37 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Precision cannot exceed 37 decimal places' );
    END IF;

    -- Use two additional digits when checking convergence.
    -- Oracle NUMBER precision limits the maximum useful precision.
    l_check_precision := LEAST(p_precision + 2, 37);

    DELETE FROM pi_calculation_result;

    LOOP
        l_previous_pi := l_pi;

        l_term :=
            (1 / POWER(16, l_iteration))
            *
            (
                  4 / (8 * l_iteration + 1)
                - 2 / (8 * l_iteration + 4)
                - 1 / (8 * l_iteration + 5)
                - 1 / (8 * l_iteration + 6)
            );

        l_pi := l_pi + l_term;

        INSERT INTO pi_calculation_result (
            iteration_no,
            term_value,
            calculated_pi
        )
        VALUES (
            l_iteration,
            l_term,
            l_pi
        );

        EXIT WHEN ROUND(l_pi, l_check_precision) =
                  ROUND(l_previous_pi, l_check_precision);

        l_iteration := l_iteration + 1;
    END LOOP;

    COMMIT;

    RETURN ROUND(l_pi, p_precision);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
