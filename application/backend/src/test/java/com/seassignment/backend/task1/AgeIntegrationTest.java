package com.seassignment.backend.task1;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

@SpringBootTest(properties = {
        "logging.level.root=WARN",
        "logging.level.org.springframework=WARN",
        "logging.level.com.zaxxer.hikari=WARN"
})
@AutoConfigureMockMvc
class AgeIntegrationTest {

    private static final Pattern STATUS_PATTERN =
            Pattern.compile("\"statusCode\"\\s*:\\s*\"([^\"]+)\"");

    private static final Pattern ERROR_CODE_PATTERN =
            Pattern.compile("\"errorCode\"\\s*:\\s*(null|-?\\d+)");

    private static final Pattern MESSAGE_PATTERN =
            Pattern.compile("\"message\"\\s*:\\s*\"([^\"]+)\"");

    @Autowired
    private MockMvc mockMvc;

    @ParameterizedTest(name = "Age {0} -> {1}")
    @CsvSource({
            "0,  'You are infant'",
            "7,  'You are schoolchild'",
            "18, 'You are adult'",
            "40, 'You are in middle-age'",
            "55, 'You are aged'"
    })
    void calculatesAgeCategoryUsingRealOracleDatabase(
            int age,
            String expectedMessage
    ) throws Exception {

        executeAndVerify(
                age,
                "OK",
                "null",
                expectedMessage
        );
    }

    @Test
    @DisplayName("Age -1 -> FAIL / -20002")
    void rejectsNegativeAgeUsingRealOracleDatabase() throws Exception {

        executeAndVerify(
                -1,
                "FAIL",
                "-20002",
                "Age cannot be negative"
        );
    }

    private void executeAndVerify(
            int age,
            String expectedStatus,
            String expectedErrorCode,
            String expectedMessage
    ) throws Exception {

        MvcResult result = mockMvc.perform(
                        get("/api/task1/age")
                                .param("age", String.valueOf(age))
                )
                .andExpect(status().isOk())
                .andReturn();

        String responseBody =
                result.getResponse().getContentAsString();

        String actualStatus =
                extractRequired(STATUS_PATTERN, responseBody, "statusCode");

        String actualErrorCode =
                extractRequired(ERROR_CODE_PATTERN, responseBody, "errorCode");

        String actualMessage =
                extractRequired(MESSAGE_PATTERN, responseBody, "message");

        boolean statusMatches =
                expectedStatus.equals(actualStatus);

        boolean errorCodeMatches =
                expectedErrorCode.equals(actualErrorCode);

        boolean messageMatches =
                expectedMessage.equals(actualMessage);

        boolean testPassed =
                statusMatches
                        && errorCodeMatches
                        && messageMatches;

        printResult(
                age,
                responseBody,
                expectedStatus,
                expectedErrorCode,
                expectedMessage,
                actualStatus,
                actualErrorCode,
                actualMessage,
                statusMatches,
                errorCodeMatches,
                messageMatches,
                testPassed
        );

        assertTrue(
                statusMatches,
                () -> "Expected statusCode = "
                        + expectedStatus
                        + ", but actual = "
                        + actualStatus
        );

        assertTrue(
                errorCodeMatches,
                () -> "Expected errorCode = "
                        + expectedErrorCode
                        + ", but actual = "
                        + actualErrorCode
        );

        assertTrue(
                messageMatches,
                () -> "Expected message = "
                        + expectedMessage
                        + ", but actual = "
                        + actualMessage
        );
    }

    private String extractRequired(
            Pattern pattern,
            String responseBody,
            String fieldName
    ) {
        Matcher matcher = pattern.matcher(responseBody);

        assertTrue(
                matcher.find(),
                "Response does not contain " + fieldName
        );

        return matcher.group(1);
    }

    private void printResult(
            int age,
            String responseBody,
            String expectedStatus,
            String expectedErrorCode,
            String expectedMessage,
            String actualStatus,
            String actualErrorCode,
            String actualMessage,
            boolean statusMatches,
            boolean errorCodeMatches,
            boolean messageMatches,
            boolean testPassed
    ) {
        System.out.println();
        System.out.println("========================================");
        System.out.println("Task 1 Backend Integration Test");
        System.out.println("========================================");

        System.out.println("Request:");
        System.out.println("GET /api/task1/age?age=" + age);

        System.out.println();
        System.out.println("Actual response:");
        System.out.println(responseBody);

        System.out.println();
        System.out.println("Expected:");
        System.out.println("statusCode = " + expectedStatus);
        System.out.println("errorCode  = " + expectedErrorCode);
        System.out.println("message    = " + expectedMessage);

        System.out.println();
        System.out.println("Actual:");
        System.out.println("statusCode = " + actualStatus);
        System.out.println("errorCode  = " + actualErrorCode);
        System.out.println("message    = " + actualMessage);

        System.out.println();
        System.out.println("Status comparison:     " + (statusMatches ? "PASS" : "FAIL"));
        System.out.println("Error code comparison: " + (errorCodeMatches ? "PASS" : "FAIL"));
        System.out.println("Message comparison:    " + (messageMatches ? "PASS" : "FAIL"));
        System.out.println();
        System.out.println("RESULT: " + (testPassed ? "PASS" : "FAIL"));

        System.out.println("========================================");
        System.out.println();
    }
}