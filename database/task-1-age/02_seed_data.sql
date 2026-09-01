-- 02_seed_data.sql

delete from age_category where 1=1;
delete from age_test_data where 1=1;

INSERT INTO age_category (
    min_age,
    max_age,
    description
)
WITH age_data (min_age, max_age, description) AS (
    SELECT 0 AS min_age,  6 AS max_age,    'You are infant'  as description     FROM dual
    UNION ALL
    SELECT 7,  17,   'You are schoolchild'   FROM dual
    UNION ALL
    SELECT 18, 39,   'You are adult'         FROM dual
    UNION ALL
    SELECT 40, 54,   'You are in middle-age' FROM dual
    UNION ALL
    SELECT 55, NULL, 'You are aged'           FROM dual
)
SELECT
    min_age,
    max_age,
    description
FROM age_data;

COMMIT;

INSERT INTO age_test_data (age)
WITH age_generator (age) AS (
    SELECT 0
    FROM dual

    UNION ALL

    SELECT age + 1
    FROM age_generator
    WHERE age < 99
)
SELECT age
FROM age_generator;

COMMIT;

