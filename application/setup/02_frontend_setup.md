# Frontend Development Setup

This document describes the environment required to build, run, and test the Vue frontend.

## Technology Stack

The frontend was developed using:

- Vue 3
- TypeScript
- Vite
- Vue Router
- Vitest
- Vue Test Utils
- ESLint
- Prettier

Development environment:

- Node.js 24.14.1
- npm 11.11.0

Node.js 24.15 or later is recommended.

## Node.js and npm

Node.js and npm are required.

Verify the installed versions:

```bash
node --version
npm --version
```

## Installing Dependencies

From the repository root:

```bash
cd application/frontend
npm install
```

Project dependencies and their versions are defined in:

```text
application/frontend/package.json
```

## Running the Frontend

```bash
cd application/frontend
npm run dev
```

Open the URL displayed by Vite in the browser.

The Spring Boot backend must also be running for REST API functionality.

## Backend Proxy

During local development, Vite proxies requests beginning with:

```text
/api
```

to the Spring Boot backend:

```text
http://localhost:8081
```

For example:

```text
/api/task1/age
```

is forwarded to:

```text
http://localhost:8081/api/task1/age
```

The proxy configuration is located in:

```text
application/frontend/vite.config.ts
```

This allows Vue components to use relative REST API paths without hardcoding the backend host.

## Running Frontend Tests

Run frontend component tests:

```bash
cd application/frontend
NO_COLOR=1 npx vitest run
```

The frontend tests use Vitest and Vue Test Utils with mocked backend requests.

## End-to-End Testing

The running Vue frontend is used by the Selenium E2E tests.

Before running E2E tests, the following components must be running:

```text
Oracle -> Spring Boot -> Vue
```

Selenium tests are executed from the backend project:

```bash
cd application/backend
./gradlew e2eTest
```

See [Backend Development Setup](01_backend_setup.md) for the complete E2E test setup.
