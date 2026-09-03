# Test Results

## Test Summary

| Layer | Test Type | Technology | Current Result | Execution Log |
|---|---|---|---|---|
| Frontend | Component / Unit | Vitest + Vue Test Utils + Fetch Mocking | 21 passed | [component-tests.txt](frontend/component-tests.txt) |
| Backend | Integration | JUnit + Spring Boot + JDBC + Oracle | 14 passed | [integration-tests.txt](backend/integration-tests.txt) |
| Database | SQL / PL/SQL | Oracle SQL / PL/SQL | 155 passed | [all-database-tests.txt](database/all-database-tests.txt) |
| End-to-End | Browser E2E | Selenium WebDriver | 4 passed | [selenium-tests.txt](e2e/selenium-tests.txt) |

## Test Scenarios

| Layer | Type | Task | Test / Scenario | Description | Result |
|---|---|---|---|---|---|
| Frontend | Component (Mock) | Task‑1 | FE‑AGE‑01 — Age view load | Verifies the age classification view is rendered correctly. | PASS |
| Frontend | Component (Mock) | Task‑1 | FE‑AGE‑02 — Missing age | Verifies client-side validation for missing age input. | PASS |
| Frontend | Component (Mock) | Task‑1 | FE‑AGE‑03 — Valid age request | Verifies the correct REST request is sent to the backend. | PASS |
| Frontend | Component (Mock) | Task‑1 | FE‑AGE‑04 — Successful classification | Verifies the classification result is displayed correctly. | PASS |
| Frontend | Component (Mock) | Task‑1 | FE‑AGE‑05 — Validation failure | Verifies a structured backend validation failure is displayed. | PASS |
| Frontend | Component (Mock) | Task‑1 | FE‑AGE‑06 — HTTP error | Verifies backend HTTP errors are handled correctly. | PASS |
| Frontend | Component (Mock) | Task‑1 | FE‑AGE‑07 — Empty response | Verifies an empty backend response is handled correctly. | PASS |
| Frontend | Component (Mock) | Task‑1 | FE‑AGE‑08 — Loading state | Verifies the UI loading state during request processing. | PASS |
| Frontend | Component (Mock) | Task‑2 | FE‑PI‑01 — Valid PI calculation | Verifies PI request construction and result rendering. | PASS |
| Frontend | Component (Mock) | Task‑2 | FE‑PI‑02 — Precision below range | Verifies precision below the supported range is rejected. | PASS |
| Frontend | Component (Mock) | Task‑2 | FE‑PI‑03 — Precision above range | Verifies precision above the supported range is rejected. | PASS |
| Frontend | Component (Mock) | Task‑2 | FE‑PI‑04 — Backend error | Verifies PI calculation backend errors are displayed. | PASS |
| Frontend | Component (Mock) | Task‑3 | FE‑INV‑01 — Load invoices and payments | Verifies invoice and payment data is loaded when the view opens. | PASS |
| Frontend | Component (Mock) | Task‑3 | FE‑INV‑02 — UNPAID filter | Verifies the correct REST request is created for the UNPAID filter. | PASS |
| Frontend | Component (Mock) | Task‑3 | FE‑INV‑03 — Select invoice | Verifies payments are loaded for the selected invoice. | PASS |
| Frontend | Component (Mock) | Task‑3 | FE‑PAY‑01 — UNPAID invoice payment | Verifies Add Payment is enabled for a specifically searched unpaid invoice. | PASS |
| Frontend | Component (Mock) | Task‑3 | FE‑PAY‑02 — PAID invoice payment | Verifies Add Payment remains disabled for a paid invoice. | PASS |
| Frontend | Component (Mock) | Task‑3 | FE‑PAY‑03 — Open payment form | Verifies the payment form is populated with invoice data. | PASS |
| Frontend | Component (Mock) | Task‑3 | FE‑PAY‑04 — Submit payment | Verifies the correct payment POST request and payload are created. | PASS |
| Frontend | Component (Mock) | Task‑3 | FE‑PAY‑05 — Payment validation failure | Verifies Oracle validation failure details are displayed in the UI. | PASS |
| Frontend | Component (Mock) | Task‑3 | FE‑PAY‑06 — Successful payment | Verifies successful payment closes the form and reloads data. | PASS |
| Backend | Integration (MockMvc) | Task‑1 | BE‑AGE — Age REST integration | Verifies Controller → Service → Repository → JDBC → Oracle age classification flow. | PASS |
| Backend | Integration (MockMvc) | Task‑2 | BE‑PI — PI REST integration | Verifies PI calculations for supported precisions using the real Oracle implementation. | PASS |
| Backend | Integration (MockMvc) | Task‑3 | BE‑INV‑01 — UNPAID invoice filter | Verifies all returned invoices have UNPAID status. | PASS |
| Backend | Integration (MockMvc) | Task‑3 | BE‑INV‑02 — Invoice ID filter | Verifies exactly the requested invoice is returned. | PASS |
| Backend | Integration (MockMvc) | Task‑3 | BE‑PAY‑01 — Retrieve payments | Verifies payment data is returned through the REST API. | PASS |
| Backend | Integration (MockMvc) | Task‑3 | BE‑PAY‑02 — Add valid payment | Verifies a valid payment is stored and returns OK. | PASS |
| Backend | Integration (MockMvc) | Task‑3 | BE‑PAY‑03 — Payment exceeds debt | Verifies Oracle rejects payment above outstanding debt with error -20039. | PASS |
| Database | PL/SQL | Task‑1 | DB‑AGE — Age classification tests | Verifies age ranges, boundaries and validation rules. | PASS |
| Database | PL/SQL | Task‑2 | DB‑PI — PI calculation tests | Verifies BBP calculations against independent expected values. | PASS |
| Database | PL/SQL | Task‑3 | DB‑INV — Invoice validation | Verifies invoice and payment validation rules including corrupted test data. | PASS |
| Database | PL/SQL | Task‑5 | DB‑PAY‑01 — Valid payment | Verifies a valid payment is accepted and inserted. | PASS |
| Database | PL/SQL | Task‑5 | DB‑PAY‑02 — Payment exceeds debt | Verifies error -20039 is returned. | PASS |
| Database | PL/SQL | Task‑5 | DB‑PAY‑03 — Future payment date | Verifies error -20037 is returned. | PASS |
| Database | PL/SQL | Task‑5 | DB‑PAY‑04 — Payment before invoice date | Verifies error -20036 is returned. | PASS |
| Database | PL/SQL | Task‑5 | DB‑PAY‑05 — Missing invoice | Verifies error -20035 is returned. | PASS |
| Database | PL/SQL | Task‑5 | DB‑PAY‑06 — NULL invoice ID | Verifies error -20031 is returned. | PASS |
| Database | PL/SQL | Task‑5 | DB‑PAY‑07 — NULL payment date | Verifies error -20032 is returned. | PASS |
| Database | PL/SQL | Task‑5 | DB‑PAY‑08 — NULL payment amount | Verifies error -20033 is returned. | PASS |
| Database | PL/SQL | Task‑5 | DB‑PAY‑09 — Zero payment amount | Verifies error -20034 is returned. | PASS |
| Database | PL/SQL | Task‑5 | DB‑PAY‑10 — Fully paid invoice | Verifies error -20038 is returned. | PASS |
| End-to-End | Selenium | Task‑1 | E2E‑AGE‑01 — Age classification | Verifies age 18 returns OK and You are adult through the complete stack. | PASS |
| End-to-End | Selenium | Task‑2 | E2E‑PI‑01 — PI calculation | Verifies precision 10 returns 3.1415926536 through the complete stack. | PASS |
| End-to-End | Selenium | Task‑3 | E2E‑INV‑01 — UNPAID invoice filter | Verifies browser filtering returns only unpaid invoices. | PASS |
| End-to-End | Selenium | Task‑3 | E2E‑PAY‑01 — Add payment | Verifies a real payment is persisted and invoice debt is reduced. | PASS |

### Mock vs MockMvc

- **Mock** — used in frontend component tests. Backend HTTP calls made with `fetch` are mocked, so Vue components are tested independently without running the Java backend or Oracle database.
- **MockMvc** — used in backend integration tests only as the HTTP request/test harness. The application layers are not mocked: the tests execute the real Controller → Service → Repository/JDBC → Oracle flow.
- **Database** and **Selenium E2E** tests do not mock application dependencies. Database tests execute directly against Oracle, while Selenium tests exercise the complete running Browser → Vue → Java → Oracle stack.
