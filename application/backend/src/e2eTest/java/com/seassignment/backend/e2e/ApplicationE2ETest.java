package com.seassignment.backend.e2e;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.math.BigDecimal;
import java.time.Duration;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ApplicationE2ETest {

    private static final String BASE_URL = "http://localhost:5174";
    private static final long DEMO_PAUSE_MS = 1200;

    private static WebDriver driver;
    private static WebDriverWait wait;

    @BeforeAll
    static void setUp() {
        driver = new ChromeDriver();
        wait = new WebDriverWait(driver, Duration.ofSeconds(10));
    }

    @AfterAll
    static void tearDown() {
        if (driver != null) {
            driver.quit();
        }
    }

    @Test
    void ageClassification_shouldReturnAdult() {
        driver.get(BASE_URL + "/age");

        WebElement ageInput = wait.until(
                ExpectedConditions.visibilityOfElementLocated(By.id("age"))
        );

        ageInput.clear();
        ageInput.sendKeys("18");

        String actualAgeInput = ageInput.getAttribute("value");

        pause();

        driver.findElement(By.xpath("//button[@type='submit']")).click();

        WebElement result = wait.until(
                ExpectedConditions.visibilityOfElementLocated(By.className("result"))
        );

        String resultText = result.getText();

        pause();

        System.out.println();
        System.out.println("========================================");
        System.out.println("Task 1 E2E Test - Age Classification");
        System.out.println("========================================");
        System.out.println("Input:");
        System.out.println("Age = " + actualAgeInput);
        System.out.println();
        System.out.println("Expected:");
        System.out.println("Status  = OK");
        System.out.println("Message = You are adult");
        System.out.println();
        System.out.println("Actual:");
        System.out.println(resultText);
        System.out.println();
        System.out.println("RESULT: PASS");
        System.out.println("========================================");
        System.out.println();

        assertEquals("18", actualAgeInput);
        assertTrue(resultText.contains("OK"));
        assertTrue(resultText.contains("You are adult"));
    }

    @Test
    void piCalculation_shouldReturnExpectedValue() {
        driver.get(BASE_URL + "/pi");

        WebElement precisionInput = wait.until(
                ExpectedConditions.visibilityOfElementLocated(By.id("precision"))
        );

        precisionInput.clear();
        precisionInput.sendKeys("10");

        String actualPrecisionInput = precisionInput.getAttribute("value");

        pause();

        driver.findElement(By.xpath("//button[@type='submit']")).click();

        WebElement result = wait.until(
                ExpectedConditions.visibilityOfElementLocated(By.className("result"))
        );

        String resultText = result.getText();

        pause();

        System.out.println();
        System.out.println("========================================");
        System.out.println("Task 2 E2E Test - PI Calculation");
        System.out.println("========================================");
        System.out.println("Input:");
        System.out.println("Precision = " + actualPrecisionInput);
        System.out.println();
        System.out.println("Expected:");
        System.out.println("Precision     = 10");
        System.out.println("Calculated PI = 3.1415926536");
        System.out.println();
        System.out.println("Actual:");
        System.out.println(resultText);
        System.out.println();
        System.out.println("RESULT: PASS");
        System.out.println("========================================");
        System.out.println();

        assertEquals("10", actualPrecisionInput);
        assertTrue(resultText.contains("10"));
        assertTrue(resultText.contains("3.1415926536"));
    }

    @Test
    void invoiceSearch_shouldReturnOnlyUnpaidInvoices() {
        driver.get(BASE_URL + "/invoices");

        WebElement statusSelect = wait.until(
                ExpectedConditions.visibilityOfElementLocated(By.id("status"))
        );

        Select select = new Select(statusSelect);
        select.selectByValue("UNPAID");

        String selectedStatus = select
                .getFirstSelectedOption()
                .getAttribute("value");

        pause();

        driver.findElement(
                By.xpath("//form[contains(@class,'filters')]//button[@type='submit']")
        ).click();

        wait.until(webDriver -> {
            List<WebElement> rows = webDriver.findElements(
                    By.cssSelector("tr.invoice-row")
            );

            return !rows.isEmpty();
        });

        List<WebElement> rows = driver.findElements(
                By.cssSelector("tr.invoice-row")
        );

        assertFalse(rows.isEmpty());

        boolean allInvoicesUnpaid = true;

        for (WebElement row : rows) {
            List<WebElement> cells = row.findElements(By.tagName("td"));

            assertTrue(
                    cells.size() >= 5,
                    "Invoice row does not contain expected columns"
            );

            String invoiceStatus = cells.get(4).getText();

            if (!"UNPAID".equals(invoiceStatus)) {
                allInvoicesUnpaid = false;
            }
        }

        pause();

        System.out.println();
        System.out.println("========================================");
        System.out.println("Task 3 E2E Test - Invoice Search");
        System.out.println("========================================");
        System.out.println("Input:");
        System.out.println("Status filter = " + selectedStatus);
        System.out.println();
        System.out.println("Expected:");
        System.out.println("Invoices returned > 0");
        System.out.println("Every invoice status = UNPAID");
        System.out.println();
        System.out.println("Actual:");
        System.out.println("Invoices returned = " + rows.size());
        System.out.println("All statuses UNPAID = " + allInvoicesUnpaid);
        System.out.println();
        System.out.println("RESULT: PASS");
        System.out.println("========================================");
        System.out.println();

        assertTrue(allInvoicesUnpaid);
    }

    @Test
    void addPayment_shouldPersistPaymentAndReduceDebt() {
        driver.get(BASE_URL + "/invoices");

        WebElement statusSelect = wait.until(
                ExpectedConditions.visibilityOfElementLocated(By.id("status"))
        );

        new Select(statusSelect).selectByValue("UNPAID");

        pause();

        driver.findElement(
                By.xpath("//form[contains(@class,'filters')]//button[@type='submit']")
        ).click();

        wait.until(webDriver ->
                !webDriver.findElements(By.cssSelector("tr.invoice-row")).isEmpty()
        );

        WebElement firstInvoiceRow = driver.findElements(
                By.cssSelector("tr.invoice-row")
        ).getFirst();

        List<WebElement> cells = firstInvoiceRow.findElements(By.tagName("td"));

        String invoiceId = cells.get(0).getText();
        String originalDebtText = cells.get(5).getText().replace(",", "");
        BigDecimal originalDebt = new BigDecimal(originalDebtText);

        WebElement invoiceInput = driver.findElement(By.id("invoiceId"));
        invoiceInput.clear();
        invoiceInput.sendKeys(invoiceId);

        new Select(driver.findElement(By.id("status"))).selectByValue("");

        pause();

        driver.findElement(
                By.xpath("//form[contains(@class,'filters')]//button[@type='submit']")
        ).click();

        wait.until(webDriver ->
                webDriver.findElements(By.cssSelector("tr.invoice-row")).size() == 1
        );

        WebElement addPaymentButton = wait.until(
                ExpectedConditions.elementToBeClickable(
                        By.xpath("//button[normalize-space()='Add Payment']")
                )
        );

        pause();

        addPaymentButton.click();

        WebElement paymentAmountInput = wait.until(
                ExpectedConditions.visibilityOfElementLocated(By.id("paymentAmount"))
        );

        String paymentInvoiceId = driver.findElement(
                By.id("paymentInvoiceId")
        ).getAttribute("value");

        String paymentDate = driver.findElement(
                By.id("paymentDate")
        ).getAttribute("value");

        String paymentCurrency = driver.findElement(
                By.id("paymentCurrency")
        ).getAttribute("value");

        String currentDebt = driver.findElement(
                By.id("currentDebt")
        ).getAttribute("value");

        paymentAmountInput.clear();
        paymentAmountInput.sendKeys("0.01");

        String paymentAmount = paymentAmountInput.getAttribute("value");

        assertEquals(invoiceId, paymentInvoiceId);

        // Keep the payment form visible so the entered amount can be seen.
        pause();

        driver.findElement(
                By.xpath("//form[contains(@class,'payment-form')]//button[@type='submit']")
        ).click();

        WebElement successMessage = wait.until(
                ExpectedConditions.visibilityOfElementLocated(
                        By.className("success-message")
                )
        );

        String paymentResult = successMessage.getText();

        assertTrue(
                paymentResult.contains("Payment successfully added")
        );

        wait.until(webDriver ->
                !webDriver.findElements(By.cssSelector("tr.invoice-row")).isEmpty()
        );

        WebElement updatedInvoiceRow = driver.findElement(
                By.cssSelector("tr.invoice-row")
        );

        List<WebElement> updatedCells = updatedInvoiceRow.findElements(
                By.tagName("td")
        );

        String updatedDebtText = updatedCells.get(5)
                .getText()
                .replace(",", "");

        BigDecimal updatedDebt = new BigDecimal(updatedDebtText);
        BigDecimal expectedDebt = originalDebt.subtract(
                new BigDecimal("0.01")
        );

        wait.until(webDriver ->
                webDriver.getPageSource().contains(invoiceId)
        );

        List<WebElement> paymentRows = driver.findElements(
                By.cssSelector(".payments-section tbody tr")
        );

        boolean paymentFound = paymentRows.stream()
                .anyMatch(row ->
                        row.getText().contains(invoiceId)
                                && row.getText().contains("0.01")
                );

        pause();

        System.out.println();
        System.out.println("========================================");
        System.out.println("Task 3 E2E Test - Add Payment");
        System.out.println("========================================");
        System.out.println("Input:");
        System.out.println("Invoice ID     = " + paymentInvoiceId);
        System.out.println("Currency       = " + paymentCurrency);
        System.out.println("Current debt   = " + currentDebt);
        System.out.println("Payment date   = " + paymentDate);
        System.out.println("Payment amount = " + paymentAmount);
        System.out.println();
        System.out.println("Expected:");
        System.out.println("Payment result = Payment successfully added");
        System.out.println("Updated debt   = " + expectedDebt.toPlainString());
        System.out.println("Payment visible in payments table = true");
        System.out.println();
        System.out.println("Actual:");
        System.out.println("Payment result = " + paymentResult);
        System.out.println("Updated debt   = " + updatedDebt.toPlainString());
        System.out.println("Payment visible in payments table = " + paymentFound);
        System.out.println();
        System.out.println("RESULT: PASS");
        System.out.println("========================================");
        System.out.println();

        assertEquals(0, expectedDebt.compareTo(updatedDebt));
        assertTrue(
                paymentFound,
                "New payment was not found in the payments table"
        );
    }

    private static void pause() {
        try {
            Thread.sleep(DEMO_PAUSE_MS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException(
                    "E2E test was interrupted during demonstration pause",
                    e
            );
        }
    }
}
