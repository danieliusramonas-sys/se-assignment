// AgeRepository.java
package com.seassignment.backend.task1;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class AgeRepository {

    private final JdbcTemplate jdbcTemplate;

    public AgeRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public AgeResult getAgeResult(Integer age) {
        String sql = """
                SELECT
                    t.r.status_code AS status_code,
                    t.r.error_code  AS error_code,
                    t.r.message     AS message
                FROM (
                    SELECT get_age_result(?) AS r
                    FROM dual
                ) t
                """;

        return jdbcTemplate.queryForObject(
                sql,
                (rs, rowNum) -> new AgeResult(
                        rs.getString("status_code"),
                        rs.getObject("error_code", Integer.class),
                        rs.getString("message")
                ),
                age
        );
    }
}