# Oracle Forms Modernization

## Overview

Oracle Forms applications often contain much more than a user interface. Business rules, validations, navigation logic, database interactions, and application-specific behavior may be tightly coupled across forms, triggers, LOVs, relations, and PL/SQL code.
Modernization should therefore avoid direct source-code translation. The objective is to understand **what the existing application does**, separate business requirements from Forms-specific implementation details, and map each responsibility to the appropriate layer of the target architecture.

## Modernization Approach

```text
Oracle Forms (.FMB)
        |
        v
Forms2XML / metadata extraction
        |
        v
Structured Forms representation
        |
        v
Automated + AI-assisted analysis
        |
        v
Technology-independent requirements
        |
        +-----------------------------+
        |                             |
        v                             v
Clearly understood              Requires analysis
functionality                   / manual decision
        |
        v
Target architecture
```

Oracle Forms can be exported into structured XML, providing machine-readable input for automated analysis. The extracted metadata can be used to identify fields and properties, LOVs, validations, master-detail relationships, triggers, database dependencies, and PL/SQL logic.
The goal is not to preserve every legacy property. Forms-specific workarounds should not automatically become requirements of the new system. Instead, the analysis should produce a **technology-independent functional model** describing expected business behavior.
AI can accelerate metadata and PL/SQL analysis, but ambiguous or undocumented behavior must not be guessed. Such cases should be explicitly flagged:

```text
status: requires-analysis
```

and resolved by a software engineer or business domain expert.

## Target Architecture

```text
+----------------------------+
|        Web Frontend        |
|    Angular / TypeScript    |
|                            |
|   UI / Field Validation    |
+-------------+--------------+
              |
              | REST API
              v
+----------------------------+
|        Java Backend        |
|                            |
| API / Security /           |
| Integration / Orchestration|
+-------------+--------------+
              |
              | Data Access /
              | PL/SQL Calls
              v
+----------------------------+
|         Oracle DB          |
|        SQL / PL/SQL        |
|                            |
|  Business and Data Logic   |
+----------------------------+
```

The frontend handles presentation, user interaction, and field-level validation. These checks improve usability but must not be treated as business controls.
The Java backend provides the API boundary and handles security, integrations, and application orchestration.
Stable, well-understood, and data-intensive business logic should remain in Oracle PL/SQL rather than being rewritten without a clear benefit.

| Legacy functionality | Target |
|---|---|
| Forms presentation logic | Web frontend |
| Field-level / UX validation | Web frontend |
| Business validation and rules | Oracle PL/SQL |
| Data-intensive logic | Oracle PL/SQL |
| API, security and integrations | Java backend |
| Application orchestration | Java backend |
| Forms-specific technical behavior | Remove or redesign |
| Ambiguous legacy logic | Manual analysis |

## Incremental Migration

For a large production system, incremental modernization is preferable to a high-risk "Big Bang" rewrite.

```text
Select module
      |
      v
Analyse legacy functionality
      |
      v
Create functional model
      |
      v
Classify and implement
      |
      v
Validate against legacy behaviour
      |
      v
Release migrated module
      |
      v
Retire corresponding Forms module
```

Modules or functional areas are migrated independently while the remaining Oracle Forms application continues to support daily operations.
During this coexistence period, both systems may use a common identity solution such as Single Sign-On (SSO) and may initially continue to use the same Oracle data and PL/SQL business layer.
A migrated module or functional area should replace its legacy equivalent only after its behaviour has been verified and accepted. The corresponding Oracle Forms functionality can then be retired independently while the remaining legacy modules continue to operate.

## Key Principles

- **Understand before rewriting.** Recover functional intent before selecting its target implementation.
- **Do not translate technology limitations into requirements.** Preserve Forms-specific behavior only when it represents a genuine business requirement.
- **Keep business logic out of the frontend.** Client-side validation improves usability; business controls remain in the backend.
- **Preserve valuable PL/SQL logic.** Do not rewrite stable and data-intensive business logic without a clear benefit.
- **Automate analysis, not decisions.** AI can accelerate repeatable analysis, while ambiguous cases and architectural decisions remain subject to human review.
- **Migrate incrementally.** Replace and retire legacy functionality module by module after validation.
