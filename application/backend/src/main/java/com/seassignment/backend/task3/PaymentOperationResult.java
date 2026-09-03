package com.seassignment.backend.task3;

public record PaymentOperationResult(
        String statusCode,
        Integer errorCode,
        String message
) {
}
