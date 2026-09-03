// AgeRequest.java
package com.seassignment.backend.task1;

import jakarta.validation.constraints.NotNull;

public record AgeRequest(
        @NotNull Integer age
) {
}