package com.seassignment.backend.task3;

import java.math.BigDecimal;
import java.time.LocalDate;

public record InvoiceResult(
        Long invoiceId,
        LocalDate invoiceDate,
        BigDecimal invoiceAmount,
        String currency,
        String status,
        BigDecimal debtAmount
) {
}