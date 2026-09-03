# Task 5 – Full Stack Application

## Overview

This application provides a modern web interface for the core functionality implemented in database Tasks 1–3.

The application consists of:

- **Web Frontend:** Vue 3 / TypeScript
- **Backend Services:** Java / Spring Boot
- **Database Layer:** Oracle Database
- **Communication Layer:** REST API

The system provides interfaces for:

- **Task 1:** Age Classification
- **Task 2:** Calculate PI
- **Task 3:** Invoices and Payments

## Architecture

The application is built using a layered architecture with a clear separation of responsibilities:

```text
Browser ➔ Vue 3 / TypeScript ──[ REST API ]──> Spring Boot Controller ➔ Service ➔ Repository (JDBC) ➔ Oracle DB (SQL/PLSQL)
```

- **Frontend:** Responsible for user interaction, UI rendering, input handling, and immediate client-side validation.
- **Java Backend:** Exposes the REST API and separates HTTP handling, application services, and database access.
- **Oracle Database:** Holds the core database functionality. Business rules and data-intensive operations implemented in Tasks 1–3 remain in Oracle where appropriate rather than being duplicated in Java.

## Testing Strategy

Tests are designed around the specific responsibilities of each layer, rather than just chasing a high test coverage percentage.

### Frontend Testing

Vue components are tested independently using **Vitest** and **Vue Test Utils**.
Backend HTTP dependencies are mocked so that frontend behaviour can be tested independently of the Java backend and Oracle database.

Frontend tests cover:
- User input and event handling
- Frontend validation
- REST request construction
- Backend response handling
- Error handling
- Rendering of results and conditional UI states

Mocking backend responses also allows error scenarios to be tested without changing or deliberately breaking the real backend.
These tests verify the behaviour of the Vue application rather than duplicating tests of backend or database business logic.

Run all Vue component tests:

```bash
cd application/frontend
npm run test:unit
```

### Backend Integration Testing

The Java backend is tested primarily using integration tests rather than mock-heavy unit tests.

The Controller, Service, and Repository layers are intentionally thin, while a significant part of the business logic resides in Oracle. Unit tests that only verify whether a Service delegates a call to a mocked Repository would therefore provide limited value.

Backend integration tests exercise the real application flow:

```text
Mock HTTP Request
        ↓
Spring Boot Controller
        ↓
Service
        ↓
Repository / JDBC
        ↓
Oracle Database
        ↓
HTTP Response
```

Spring `MockMvc` is used to initiate requests through the Spring MVC layer. The application components and Oracle database are not mocked.

The tests therefore verify:

- REST endpoint behaviour
- Request and response contracts
- Controller, Service, and Repository integration
- JDBC database access
- Java-to-Oracle integration
- Results returned by the real Oracle SQL/PLSQL implementation

Expected values are explicitly compared with the actual values returned through the complete backend flow.

Current backend integration test coverage:

- Task 1 – Age Classification: 6 tests
- Task 2 – PI Calculation: 3 tests
- Task 3 – Invoices and Payments: 3 tests
- **Total: 12 backend integration tests**

All current backend integration tests are passing.

Run all backend tests:

```bash
cd application/backend
./gradlew test --rerun-tasks
```

Show a compact integration test result summary:

```bash
cd application/backend
./gradlew test --rerun-tasks 2>&1 \
  | grep -E '(AgeIntegrationTest|PiIntegrationTest|InvoiceIntegrationTest).*(PASSED|FAILED)'
```

### Database Testing

Oracle SQL and PL/SQL functionality is tested directly using the database test scripts and test data provided with Tasks 1–3.
These tests verify database business rules, validation logic, and boundary conditions independently of the Java backend and frontend.

### End-to-End Testing

**!TODO! Implement Selenium end-to-end tests.**

End-to-end browser tests will verify the complete application flow:

```text
Real Browser ➔ Vue Frontend ➔ Spring Boot Backend ➔ Oracle Database
```

The tests will cover selected critical user workflows across the complete application stack.

E2E testing complements the focused frontend, backend integration, and database tests rather than replacing them.


## Running the Application

The application consists of an Oracle database, Spring Boot backend, and Vue frontend.

### 1. Oracle Database

Create and configure the Oracle schema using:

- [Create schema](../database/setup/01_create_schema.sql)
- [Configure schema](../database/setup/02_configure_schema.sql)

Database objects required by individual tasks are located in their corresponding directories under `database/`.

### 2. Spring Boot Backend

Run from `application/backend`:

```bash
./gradlew bootRun
```

The backend REST API runs on `http://localhost:8081`.
For prerequisites and configuration, see [Backend setup](setup/01_backend_setup.md).

### 3. Vue Frontend

Run from `application/frontend`:

```bash
npm install
npm run dev
```

Vite will display the local application URL when the development server starts.
For prerequisites and configuration, see [Frontend setup](setup/02_frontend_setup.md).

## Running Tests

The project uses multiple levels of automated testing.

### Frontend Tests

Frontend component tests use Vitest and Vue Test Utils with mocked backend requests.

Run from `application/frontend`:

```bash
NO_COLOR=1 npx vitest run
```

Current result: **15 tests passed**.

[Test execution results](test-results/frontend/component-tests.txt)

### Backend Integration Tests

Backend integration tests use the real Spring Boot application and Oracle database:
```text
MockMvc -> Controller -> Service -> Repository -> JDBC -> Oracle
```

Run from `application/backend`:
```bash
./gradlew test --rerun-tasks
```

Current result: **14 integration tests passed**.
[Test execution results](test-results/backend/integration-tests.txt)

### Database Tests

Database tests validate the PL/SQL implementation and business rules for Tasks 1–3 and the additional payment functionality used by the application.
[Test execution results](test-results/database/all-database-tests.txt)

### End-to-End Tests

Selenium E2E tests will validate the complete application flow:

```text
Browser -> Vue -> Spring Boot -> Oracle
```

E2E test results will be added after implementation.

### Testing Approach

Tests are designed around the specific responsibilities of each layer rather than just chasing a high test coverage percentage.

## REST API

The Spring Boot backend exposes the following REST endpoints:

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/task1/age` | Classifies a person by age using the configured Oracle age categories. |
| `POST` | `/api/task2/pi` | Calculates PI to the requested decimal precision using the Oracle BBP implementation. |
| `GET` | `/api/task3/invoices` | Returns invoices with their payment status and outstanding debt. |
| `GET` | `/api/task3/invoices?invoiceId={id}` | Returns a specific invoice by invoice ID. |
| `GET` | `/api/task3/invoices?status={status}` | Filters invoices by `PAID` or `UNPAID` status. |
| `GET` | `/api/task3/payments` | Returns all payments. |
| `GET` | `/api/task3/payments?invoiceId={id}` | Returns payments for a specific invoice. |
| `POST` | `/api/task3/payments` | Adds a payment to an invoice. Payment business rules are validated by Oracle PL/SQL. |


## AI Tools

AI tools were actively used during the implementation of this assignment. The primary AI tool used was **ChatGPT**, which was used as a development assistant throughout the project.

AI assistance included:
- discussing architecture and implementation alternatives;
- generating initial code examples and implementation drafts;
- assisting with the Vue / TypeScript frontend implementation;
- assisting with Spring Boot and JDBC integration;
- suggesting test cases and test structures;
- reviewing and refactoring code;
- troubleshooting compilation, configuration, and test failures;
- assisting with technical documentation.

AI assistance was particularly significant in the frontend implementation, as Vue and TypeScript are not my primary technologies.

For the frontend, I defined the functional requirements, expected application behaviour, screen structure, and required user interactions. AI was then used to help translate these requirements into Vue / TypeScript implementation.
The AI-generated proposals were treated as implementation suggestions rather than final solutions. I reviewed the proposed approaches, identified and rejected unsuitable implementation choices, corrected incorrect assumptions, and iteratively refined the implementation based on the actual application behaviour and requirements.
The same verification approach was used throughout the project. Generated code and technical suggestions were executed and tested in my local environment, and issues were investigated and corrected rather than accepting AI-generated output as automatically correct.
Database logic, REST integration, frontend behaviour, and automated tests were validated against the running application and Oracle database.
AI-generated suggestions were accepted only after they were understood, reviewed, and verified by running the relevant application or tests.
I remain responsible for the requirements, architecture and implementation decisions, verification, testing, and final submitted solution.
