package com.seassignment.backend.task3;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.transaction.annotation.Transactional;

@SpringBootTest(properties = {
        "logging.level.root=WARN",
        "logging.level.org.springframework=WARN",
        "logging.level.com.zaxxer.hikari=WARN"
})
@AutoConfigureMockMvc
class InvoiceIntegrationTest {

    private static final Pattern INVOICE_ID_PATTERN =
            Pattern.compile("\"invoiceId\"\\s*:\\s*(\\d+)");

    private static final Pattern STATUS_PATTERN =
            Pattern.compile("\"status\"\\s*:\\s*\"([^\"]+)\"");

    private static final Pattern PAYMENT_ID_PATTERN =
            Pattern.compile("\"paymentId\"\\s*:\\s*(\\d+)");

    private static final Pattern UNPAID_INVOICE_PATTERN =
            Pattern.compile(
                    "\\{"
                            + "\"invoiceId\"\\s*:\\s*(\\d+),"
                            + "\"invoiceDate\"\\s*:\\s*\"([^\"]+)\","
                            + "\"invoiceAmount\"\\s*:\\s*(-?\\d+(?:\\.\\d+)?),"
                            + "\"currency\"\\s*:\\s*\"([^\"]+)\","
                            + "\"status\"\\s*:\\s*\"UNPAID\","
                            + "\"debtAmount\"\\s*:\\s*(-?\\d+(?:\\.\\d+)?)"
                            + "\\}"
            );

    @Autowired
    private MockMvc mockMvc;

    @Test
    @DisplayName("Invoice ID filter -> returns requested invoice")
    void returnsRequestedInvoiceUsingRealOracleDatabase() throws Exception {

        String allInvoicesResponse = mockMvc.perform(
                        get("/api/task3/invoices")
                )
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        Matcher invoiceMatcher = INVOICE_ID_PATTERN.matcher(allInvoicesResponse);

        assertTrue(
                invoiceMatcher.find(),
                "No invoices available for integration test"
        );

        long expectedInvoiceId = Long.parseLong(invoiceMatcher.group(1));

        String responseBody = mockMvc.perform(
                        get("/api/task3/invoices")
                                .param(
                                        "invoiceId",
                                        String.valueOf(expectedInvoiceId)
                                )
                )
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        Matcher resultMatcher = INVOICE_ID_PATTERN.matcher(responseBody);

        assertTrue(
                resultMatcher.find(),
                "Filtered response does not contain invoiceId"
        );

        long actualInvoiceId = Long.parseLong(resultMatcher.group(1));
        boolean onlyOneInvoice = !resultMatcher.find();
        boolean invoiceIdMatches = expectedInvoiceId == actualInvoiceId;
        boolean testPassed = invoiceIdMatches && onlyOneInvoice;

        System.out.println();
        System.out.println("========================================");
        System.out.println("Task 3 Backend Integration Test");
        System.out.println("========================================");
        System.out.println("Request:");
        System.out.println(
                "GET /api/task3/invoices?invoiceId="
                        + expectedInvoiceId
        );

        System.out.println();
        System.out.println("Expected:");
        System.out.println("invoiceId = " + expectedInvoiceId);
        System.out.println("Exactly one invoice returned");

        System.out.println();
        System.out.println("Actual:");
        System.out.println("invoiceId = " + actualInvoiceId);
        System.out.println("Exactly one invoice = " + onlyOneInvoice);

        System.out.println();
        System.out.println(
                "Invoice ID comparison: "
                        + (invoiceIdMatches ? "PASS" : "FAIL")
        );
        System.out.println(
                "Record count comparison: "
                        + (onlyOneInvoice ? "PASS" : "FAIL")
        );

        System.out.println();
        System.out.println(
                "RESULT: " + (testPassed ? "PASS" : "FAIL")
        );
        System.out.println("========================================");
        System.out.println();

        assertTrue(invoiceIdMatches, "invoiceId mismatch");
        assertTrue(onlyOneInvoice, "More than one invoice was returned");
    }

    @Test
    @DisplayName("Status filter UNPAID -> all invoices UNPAID")
    void filtersUnpaidInvoicesUsingRealOracleDatabase() throws Exception {

        MvcResult result = mockMvc.perform(
                        get("/api/task3/invoices")
                                .param("status", "UNPAID")
                )
                .andExpect(status().isOk())
                .andReturn();

        String responseBody =
                result.getResponse().getContentAsString();

        Matcher matcher =
                STATUS_PATTERN.matcher(responseBody);

        int count = 0;
        boolean allUnpaid = true;

        while (matcher.find()) {
            count++;

            if (!"UNPAID".equals(matcher.group(1))) {
                allUnpaid = false;
            }
        }

        boolean hasInvoices = count > 0;
        boolean testPassed = hasInvoices && allUnpaid;

        System.out.println();
        System.out.println("========================================");
        System.out.println("Task 3 Backend Integration Test");
        System.out.println("========================================");
        System.out.println("Request:");
        System.out.println("GET /api/task3/invoices?status=UNPAID");

        System.out.println();
        System.out.println("Expected:");
        System.out.println("Invoices returned > 0");
        System.out.println("Every status = UNPAID");

        System.out.println();
        System.out.println("Actual:");
        System.out.println("Invoices checked = " + count);
        System.out.println("All statuses UNPAID = " + allUnpaid);

        System.out.println();
        System.out.println(
                "Count comparison:  "
                        + (hasInvoices ? "PASS" : "FAIL")
        );
        System.out.println(
                "Status comparison: "
                        + (allUnpaid ? "PASS" : "FAIL")
        );

        System.out.println();
        System.out.println(
                "RESULT: " + (testPassed ? "PASS" : "FAIL")
        );
        System.out.println("========================================");
        System.out.println();

        assertTrue(
                hasInvoices,
                "No UNPAID invoices were returned"
        );

        assertTrue(
                allUnpaid,
                "Response contains invoice with status other than UNPAID"
        );
    }

    @Test
    @DisplayName("Payments endpoint -> returns payment data")
    void returnsPaymentsUsingRealOracleDatabase() throws Exception {

        MvcResult result = mockMvc.perform(
                        get("/api/task3/payments")
                )
                .andExpect(status().isOk())
                .andReturn();

        String responseBody =
                result.getResponse().getContentAsString();

        boolean hasPayments =
                responseBody != null
                        && !responseBody.isBlank()
                        && !"[]".equals(responseBody.trim());

        boolean hasPaymentId =
                responseBody.contains("\"paymentId\":");

        boolean hasInvoiceId =
                responseBody.contains("\"invoiceId\":");

        boolean hasPaymentDate =
                responseBody.contains("\"paymentDate\":");

        boolean hasPaymentAmount =
                responseBody.contains("\"paymentAmount\":");

        boolean testPassed =
                hasPayments
                        && hasPaymentId
                        && hasInvoiceId
                        && hasPaymentDate
                        && hasPaymentAmount;

        System.out.println();
        System.out.println("========================================");
        System.out.println("Task 3 Backend Integration Test");
        System.out.println("========================================");
        System.out.println("Request:");
        System.out.println("GET /api/task3/payments");

        System.out.println();
        System.out.println("Expected:");
        System.out.println("Non-empty payment array");
        System.out.println("paymentId present");
        System.out.println("invoiceId present");
        System.out.println("paymentDate present");
        System.out.println("paymentAmount present");

        System.out.println();
        System.out.println("Actual checks:");
        System.out.println(
                "Non-empty response: "
                        + (hasPayments ? "PASS" : "FAIL")
        );
        System.out.println(
                "paymentId:          "
                        + (hasPaymentId ? "PASS" : "FAIL")
        );
        System.out.println(
                "invoiceId:          "
                        + (hasInvoiceId ? "PASS" : "FAIL")
        );
        System.out.println(
                "paymentDate:        "
                        + (hasPaymentDate ? "PASS" : "FAIL")
        );
        System.out.println(
                "paymentAmount:      "
                        + (hasPaymentAmount ? "PASS" : "FAIL")
        );

        System.out.println();
        System.out.println(
                "RESULT: " + (testPassed ? "PASS" : "FAIL")
        );
        System.out.println("========================================");
        System.out.println();

        assertTrue(hasPayments, "Payment response is empty");
        assertTrue(hasPaymentId, "paymentId is missing");
        assertTrue(hasInvoiceId, "invoiceId is missing");
        assertTrue(hasPaymentDate, "paymentDate is missing");
        assertTrue(hasPaymentAmount, "paymentAmount is missing");
    }

    @Test
    @Transactional
    @Rollback
    @DisplayName("Add payment -> OK / payment stored")
    void addsPaymentUsingRealOracleDatabase() throws Exception {

        UnpaidInvoice invoice = findUnpaidInvoice();

        int paymentsBefore =
                countPayments(invoice.invoiceId());

        BigDecimal paymentAmount =
                new BigDecimal("0.01");

        String requestBody = """
                {
                  "invoiceId": %d,
                  "paymentDate": "%s",
                  "paymentAmount": %s
                }
                """.formatted(
                invoice.invoiceId(),
                LocalDate.now(),
                paymentAmount.toPlainString()
        );

        String responseBody = mockMvc.perform(
                        post("/api/task3/payments")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(requestBody)
                )
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        boolean statusMatches =
                responseBody.contains("\"statusCode\":\"OK\"");

        boolean errorCodeMatches =
                responseBody.contains("\"errorCode\":null");

        boolean messageMatches =
                responseBody.contains(
                        "\"message\":\"Payment successfully added\""
                );

        int paymentsAfter =
                countPayments(invoice.invoiceId());

        boolean paymentCreated =
                paymentsAfter == paymentsBefore + 1;

        boolean testPassed =
                statusMatches
                        && errorCodeMatches
                        && messageMatches
                        && paymentCreated;

        System.out.println();
        System.out.println("========================================");
        System.out.println("Task 3 Backend Integration Test");
        System.out.println("========================================");
        System.out.println("Request:");
        System.out.println("POST /api/task3/payments");
        System.out.println("invoiceId     = " + invoice.invoiceId());
        System.out.println("paymentDate   = " + LocalDate.now());
        System.out.println(
                "paymentAmount = "
                        + paymentAmount.toPlainString()
        );

        System.out.println();
        System.out.println("Expected:");
        System.out.println("statusCode = OK");
        System.out.println("errorCode  = null");
        System.out.println(
                "message    = Payment successfully added"
        );
        System.out.println(
                "Payment count = "
                        + paymentsBefore
                        + " -> "
                        + (paymentsBefore + 1)
        );

        System.out.println();
        System.out.println("Actual:");
        System.out.println("Response:");
        System.out.println(responseBody);
        System.out.println(
                "Payment count = "
                        + paymentsBefore
                        + " -> "
                        + paymentsAfter
        );

        System.out.println();
        System.out.println(
                "Status comparison:  "
                        + (statusMatches ? "PASS" : "FAIL")
        );
        System.out.println(
                "Error comparison:   "
                        + (errorCodeMatches ? "PASS" : "FAIL")
        );
        System.out.println(
                "Message comparison: "
                        + (messageMatches ? "PASS" : "FAIL")
        );
        System.out.println(
                "INSERT comparison:  "
                        + (paymentCreated ? "PASS" : "FAIL")
        );

        System.out.println();
        System.out.println(
                "RESULT: " + (testPassed ? "PASS" : "FAIL")
        );
        System.out.println("========================================");
        System.out.println();

        assertTrue(statusMatches, "statusCode mismatch");
        assertTrue(errorCodeMatches, "errorCode mismatch");
        assertTrue(messageMatches, "message mismatch");
        assertTrue(
                paymentCreated,
                "Payment row was not created"
        );
    }

    @Test
    @Transactional
    @Rollback
    @DisplayName("Add payment above debt -> FAIL / -20039")
    void rejectsPaymentAboveDebtUsingRealOracleDatabase()
            throws Exception {

        UnpaidInvoice invoice = findUnpaidInvoice();

        int paymentsBefore =
                countPayments(invoice.invoiceId());

        BigDecimal paymentAmount =
                invoice.debtAmount().add(BigDecimal.ONE);

        String requestBody = """
                {
                  "invoiceId": %d,
                  "paymentDate": "%s",
                  "paymentAmount": %s
                }
                """.formatted(
                invoice.invoiceId(),
                LocalDate.now(),
                paymentAmount.toPlainString()
        );

        String responseBody = mockMvc.perform(
                        post("/api/task3/payments")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(requestBody)
                )
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        boolean statusMatches =
                responseBody.contains("\"statusCode\":\"FAIL\"");

        boolean errorCodeMatches =
                responseBody.contains("\"errorCode\":-20039");

        boolean messageMatches =
                responseBody.contains(
                        "\"message\":\"Payment amount exceeds outstanding debt\""
                );

        int paymentsAfter =
                countPayments(invoice.invoiceId());

        boolean noPaymentCreated =
                paymentsAfter == paymentsBefore;

        boolean testPassed =
                statusMatches
                        && errorCodeMatches
                        && messageMatches
                        && noPaymentCreated;

        System.out.println();
        System.out.println("========================================");
        System.out.println("Task 3 Backend Integration Test");
        System.out.println("========================================");
        System.out.println("Request:");
        System.out.println("POST /api/task3/payments");
        System.out.println("invoiceId     = " + invoice.invoiceId());
        System.out.println(
                "current debt  = "
                        + invoice.debtAmount().toPlainString()
        );
        System.out.println(
                "paymentAmount = "
                        + paymentAmount.toPlainString()
        );

        System.out.println();
        System.out.println("Expected:");
        System.out.println("statusCode = FAIL");
        System.out.println("errorCode  = -20039");
        System.out.println(
                "message    = Payment amount exceeds outstanding debt"
        );
        System.out.println(
                "Payment count remains = "
                        + paymentsBefore
        );

        System.out.println();
        System.out.println("Actual:");
        System.out.println("Response:");
        System.out.println(responseBody);
        System.out.println(
                "Payment count = "
                        + paymentsBefore
                        + " -> "
                        + paymentsAfter
        );

        System.out.println();
        System.out.println(
                "Status comparison:  "
                        + (statusMatches ? "PASS" : "FAIL")
        );
        System.out.println(
                "Error comparison:   "
                        + (errorCodeMatches ? "PASS" : "FAIL")
        );
        System.out.println(
                "Message comparison: "
                        + (messageMatches ? "PASS" : "FAIL")
        );
        System.out.println(
                "No INSERT comparison: "
                        + (noPaymentCreated ? "PASS" : "FAIL")
        );

        System.out.println();
        System.out.println(
                "RESULT: " + (testPassed ? "PASS" : "FAIL")
        );
        System.out.println("========================================");
        System.out.println();

        assertTrue(statusMatches, "statusCode mismatch");
        assertTrue(errorCodeMatches, "errorCode mismatch");
        assertTrue(messageMatches, "message mismatch");
        assertTrue(
                noPaymentCreated,
                "Rejected payment unexpectedly created a row"
        );
    }

    private UnpaidInvoice findUnpaidInvoice()
            throws Exception {

        String responseBody = mockMvc.perform(
                        get("/api/task3/invoices")
                                .param("status", "UNPAID")
                )
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        Matcher matcher =
                UNPAID_INVOICE_PATTERN.matcher(responseBody);

        LocalDate today = LocalDate.now();

        while (matcher.find()) {
            long invoiceId =
                    Long.parseLong(matcher.group(1));

            LocalDate invoiceDate =
                    LocalDate.parse(matcher.group(2));

            BigDecimal debtAmount =
                    new BigDecimal(matcher.group(5));

            if (!invoiceDate.isAfter(today)
                    && debtAmount.compareTo(
                    new BigDecimal("0.01")
            ) >= 0) {

                return new UnpaidInvoice(
                        invoiceId,
                        invoiceDate,
                        debtAmount
                );
            }
        }

        throw new AssertionError(
                "No suitable UNPAID invoice available for payment test"
        );
    }

    private int countPayments(long invoiceId)
            throws Exception {

        String responseBody = mockMvc.perform(
                        get("/api/task3/payments")
                                .param(
                                        "invoiceId",
                                        String.valueOf(invoiceId)
                                )
                )
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        Matcher matcher =
                PAYMENT_ID_PATTERN.matcher(responseBody);

        int count = 0;

        while (matcher.find()) {
            count++;
        }

        return count;
    }

    private record UnpaidInvoice(
            long invoiceId,
            LocalDate invoiceDate,
            BigDecimal debtAmount
    ) {
    }
}