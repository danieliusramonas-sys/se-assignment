// AgeResult.java
package com.seassignment.backend.task1;

public record AgeResult(
        String statusCode,
        Integer errorCode,
        String message
) {
}