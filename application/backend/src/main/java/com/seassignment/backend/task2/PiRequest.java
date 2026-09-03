package com.seassignment.backend.task2;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record PiRequest(
        @NotNull
        @Min(1)
        @Max(27)
        Integer precision
) {
}