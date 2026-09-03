package com.seassignment.backend.task3;

import java.math.BigDecimal;
import java.time.LocalDate;

public record PaymentResult(
        Long paymentId,
        Long invoiceId,
        LocalDate paymentDate,
        BigDecimal paymentAmount
) {
}