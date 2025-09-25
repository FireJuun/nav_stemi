<!--
---
Sync Impact Report
---
Version: 0.0.0 → 1.0.0
Modified Principles:
- PRINCIPLE_1_NAME → I. Clean Architecture
- PRINCIPLE_2_NAME → II. State Management
- PRINCIPLE_3_NAME → III. Testing Philosophy
- PRINCIPLE_4_NAME → IV. Coding Style & Quality
- PRINCIPLE_5_NAME → V. Navigation
Added Sections:
- Asynchronous Operations
- Immutability & Data Modeling
- Governance
Templates requiring updates:
- ✅ .specify/templates/plan-template.md
- ✅ .specify/templates/spec-template.md
- ✅ .specify/templates/tasks-template.md
- ✅ .specify/templates/commands/clarify.toml
- ✅ .specify/templates/commands/implement.toml
- ✅ .specify/templates/commands/plan.toml
- ✅ .specify/templates/commands/specify.toml
- ✅ .specify/templates/commands/tasks.toml
- ✅ README.md
Follow-up TODOs:
- TODO(RATIFICATION_DATE): Determine the original adoption date of these principles.
-->
# Nav STEMI Constitution

This document outlines the non-negotiable principles and standards for the Nav STEMI Flutter application. It serves as the source of truth for architectural decisions, coding practices, and quality assurance.

## Core Principles

### I. Clean Architecture
All features MUST be structured using a layered architecture, strictly separating concerns into four distinct layers:
- **Domain:** Contains the core business logic, entities (plain Dart objects with `equatable`), and abstract repository interfaces. It must have no dependencies on any other layer.
- **Application:** Orchestrates data flow from the data layer to the domain and presentation layers. It contains application-specific business logic and services. It depends only on the Domain layer.
- **Data:** Implements the repository interfaces defined in the Domain layer. It is responsible for all data retrieval and storage, whether from remote sources (Firebase, APIs) or local sources (device storage). It depends on the Domain layer.
- **Presentation:** Contains all UI components (Widgets) and state management logic (Riverpod providers). It depends on the Application and Domain layers.

### II. State Management
State management MUST be implemented using the **Riverpod** package with its code generation capabilities (`riverpod_generator`). This ensures that state is managed in a predictable, testable, and scalable manner. Providers should be scoped as narrowly as possible and defined within the feature's presentation or application layer.

### III. Testing Philosophy
A comprehensive testing strategy is NON-NEGOTIABLE. The project MUST maintain a high level of test coverage, following a Test-Driven Development (TDD) or Behavior-Driven Development (BDD) approach where practical.
- **Unit Tests:** Every function, class, and Riverpod provider in the domain and application layers MUST have corresponding unit tests.
- **Widget Tests:** All UI components (widgets) in the presentation layer MUST be verified with widget tests to ensure they render correctly under various states.
- **Integration Tests:** End-to-end user flows and interactions with services like Firebase MUST be covered by integration tests. Mocks (`mockito`, `mocktail`) and fakes (`fake_cloud_firestore`) are required to isolate dependencies.

### IV. Coding Style & Quality
The project MUST adhere to the strict linting rules defined in the `very_good_analysis` package. All code must be formatted using `dart format`. No exceptions to these rules are permitted without a formal amendment to this constitution. Public APIs should be documented, but boilerplate `public_member_api_docs` are disabled to encourage meaningful documentation where it matters.

### V. Navigation
Navigation throughout the application MUST be handled declaratively using the **GoRouter** package. All routes must be defined in a centralized routing configuration, ensuring a single source of truth for navigation logic and deep linking.

## Additional Standards

### Asynchronous Operations
Asynchronous operations MUST be handled using `Future` and `Stream` from the Dart standard library. For more complex reactive programming scenarios, **RxDart** should be utilized to manage and compose streams of data, particularly for real-time data feeds.

### Immutability & Data Modeling
All data models and entities MUST be immutable. The **Equatable** package MUST be used to override `==` and `hashCode` for value-based equality, preventing common bugs related to object comparison.

## Governance

This Constitution is the supreme governing document for the Nav STEMI project. It supersedes all other conventions, practices, or individual preferences.
- **Amendment Process:** Any proposed changes to this constitution require a formal review and approval process. A pull request must be submitted with the proposed amendments and a clear rationale.
- **Compliance:** All code reviews MUST verify that contributions are in full compliance with the principles outlined in this document. Any deviation must be justified and may require a constitutional amendment.

**Version**: 1.0.0 | **Ratified**: TODO(RATIFICATION_DATE) | **Last Amended**: 2025-09-25
