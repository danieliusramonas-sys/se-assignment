package com.seassignment.backend.task2;

import java.math.BigDecimal;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class PiRepository {

    private final JdbcTemplate jdbcTemplate;

    public PiRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public BigDecimal calculatePi(Integer precision) {
        String sql = """
                SELECT calculate_pi(?) AS calculated_pi
                FROM dual
                """;

        return jdbcTemplate.queryForObject(
                sql,
                BigDecimal.class,
                precision
        );
    }
}