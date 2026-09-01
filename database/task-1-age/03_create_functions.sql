CREATE OR REPLACE FUNCTION get_age_result (
    p_age IN NUMBER
) RETURN age_result_t
IS
    v_description age_category.description%TYPE;
BEGIN
    IF p_age IS NULL THEN
        RETURN age_result_t(
            'FAIL',
            -20001,
            'Age must be provided'
        );
    END IF;

    IF p_age < 0 THEN
        RETURN age_result_t(
            'FAIL',
            -20002,
            'Age cannot be negative'
        );
    END IF;

    BEGIN
        SELECT description
          INTO v_description
          FROM age_category
         WHERE TRUNC(p_age) >= min_age
           AND (max_age IS NULL OR TRUNC(p_age) <= max_age); --todo:ROUND?

        RETURN age_result_t(
            'OK',
            NULL,
            v_description
        );

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN age_result_t(
                'FAIL',
                -20003,
                'Age range is not configured'
            );

        WHEN TOO_MANY_ROWS THEN
            RETURN age_result_t(
                'FAIL',
                -20004,
                'Age range configuration is ambiguous'
            );
    END;
END;
/
CREATE OR REPLACE FUNCTION get_age_description ( p_age IN NUMBER ) 
RETURN VARCHAR2
IS
    l_result age_result_t;
BEGIN
    l_result := get_age_result(p_age);

    RETURN l_result.message;
END;
/

