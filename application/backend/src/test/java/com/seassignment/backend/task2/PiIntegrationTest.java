package com.seassignment.backend.task2;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.math.BigDecimal;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

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
class PiIntegrationTest {

    private static final Pattern PRECISION_PATTERN =
            Pattern.compile("\"precision\"\\s*:\\s*(\\d+)");

    private static final Pattern PI_PATTERN =
            Pattern.compile("\"calculatedPi\"\\s*:\\s*(-?\\d+(?:\\.\\d+)?)");

    @Autowired
    private MockMvc mockMvc;

    @ParameterizedTest(name = "Precision {0} -> {1}")
    @CsvSource({
            "1,  '3.1'",
            "10, '3.1415926536'",
            "27, '3.141592653589793238462643383'"
    })
    void calculatesPiUsingRealOracleDatabase(
            int expectedPrecision,
            String expectedPiText
    ) throws Exception {

        MvcResult result = mockMvc.perform(
                        get("/api/task2/pi")
                                .param(
                                        "precision",
                                        String.valueOf(expectedPrecision)
                                )
                )
                .andExpect(status().isOk())
                .andReturn();

        String responseBody =
                result.getResponse().getContentAsString();

        int actualPrecision =
                extractPrecision(responseBody);

        BigDecimal expectedPi =
                new BigDecimal(expectedPiText);

        BigDecimal actualPi =
                extractCalculatedPi(responseBody);

        boolean precisionMatches =
                expectedPrecision == actualPrecision;

        boolean piMatches =
                expectedPi.compareTo(actualPi) == 0;

        boolean testPassed =
                precisionMatches && piMatches;

        printResult(
                expectedPrecision,
                responseBody,
                expectedPi,
                actualPrecision,
                actualPi,
                precisionMatches,
                piMatches,
                testPassed
        );

        assertTrue(
                precisionMatches,
                () -> "Expected precision = "
                        + expectedPrecision
                        + ", but actual precision = "
                        + actualPrecision
        );

        assertTrue(
                piMatches,
                () -> "Expected calculatedPi = "
                        + expectedPi.toPlainString()
                        + ", but actual calculatedPi = "
                        + actualPi.toPlainString()
        );
    }

    private int extractPrecision(String responseBody) {

        Matcher matcher =
                PRECISION_PATTERN.matcher(responseBody);

        assertTrue(
                matcher.find(),
                "Response does not contain precision"
        );

        return Integer.parseInt(matcher.group(1));
    }

    private BigDecimal extractCalculatedPi(String responseBody) {

        Matcher matcher =
                PI_PATTERN.matcher(responseBody);

        assertTrue(
                matcher.find(),
                "Response does not contain calculatedPi"
        );

        return new BigDecimal(matcher.group(1));
    }

    private void printResult(
            int expectedPrecision,
            String responseBody,
            BigDecimal expectedPi,
            int actualPrecision,
            BigDecimal actualPi,
            boolean precisionMatches,
            boolean piMatches,
            boolean testPassed
    ) {
        System.out.println();
        System.out.println("========================================");
        System.out.println("Task 2 Backend Integration Test");
        System.out.println("========================================");

        System.out.println("Request:");
        System.out.println(
                "GET /api/task2/pi?precision=" + expectedPrecision
        );

        System.out.println();
        System.out.println("Actual response:");
        System.out.println(responseBody);

        System.out.println();
        System.out.println("Expected:");
        System.out.println("precision    = " + expectedPrecision);
        System.out.println("calculatedPi = " + expectedPi.toPlainString());

        System.out.println();
        System.out.println("Actual:");
        System.out.println("precision    = " + actualPrecision);
        System.out.println("calculatedPi = " + actualPi.toPlainString());

        System.out.println();
        System.out.println("Precision comparison: " + (precisionMatches ? "PASS" : "FAIL"));
        System.out.println("PI comparison:        " + (piMatches ? "PASS" : "FAIL"));
        System.out.println();
        System.out.println("RESULT: " + (testPassed ? "PASS" : "FAIL"));

        System.out.println("========================================");
        System.out.println();
    }
}