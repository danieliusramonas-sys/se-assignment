package com.seassignment.backend.task2;

import java.math.BigDecimal;

public record PiResult(
        Integer precision,
        BigDecimal calculatedPi
) {
}