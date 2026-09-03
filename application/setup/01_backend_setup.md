# Backend Development Setup

This document describes the environment required to build, run, and test the Spring Boot backend.

## Technology Stack

The backend was developed and tested using:

- Java 21
- Spring Boot 4.0.8
- Gradle Wrapper
- Spring Web MVC
- Spring JDBC
- Jakarta Validation
- Oracle JDBC Driver
- JUnit 5
- Selenium WebDriver

## Java Installation

Java 21 is required.

Example installation on Ubuntu:

```bash
sudo apt update
sudo apt install openjdk-21-jdk
```

Verify the installation:

```bash
java -version
javac -version
```

The project uses the Gradle Wrapper, therefore a separate Gradle installation is not required.

## Database Connection

The backend connects to Oracle using environment variables.

```bash
export DB_URL='jdbc:oracle:thin:@//localhost:1521/FREEPDB1'
export DB_USERNAME='SE_ASSIGNMENT'
export DB_PASSWORD='your_password'
```

Database credentials are not stored in the repository.

Spring Boot configuration is located in:

```text
application/backend/src/main/resources/application.properties
```

## Running the Backend

From the repository root:

```bash
cd application/backend
./gradlew bootRun
```

The backend runs on:

```text
http://localhost:8081
```

The Oracle database must be running and the required database objects must be installed before starting the backend.

## Running Backend Tests

Run the backend integration tests:

```bash
cd application/backend
./gradlew test --rerun-tasks
```

A detailed Gradle test report is generated at:

```text
application/backend/build/reports/tests/test/index.html
```

## Running End-to-End Tests

Selenium E2E tests validate the complete application flow:

```text
Browser -> Vue -> Spring Boot -> Oracle
```

Before running E2E tests, the following components must be running:

- Oracle database
- Spring Boot backend on port `8081`
- Vue frontend

A Chrome or Chromium browser is required. Selenium Manager automatically manages the required WebDriver.

Run the E2E tests from `application/backend`:

```bash
./gradlew e2eTest
```

The E2E tests are kept separate from the backend integration tests, so running `./gradlew test` does not start Selenium tests.
