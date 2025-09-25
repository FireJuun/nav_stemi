# Implementation Plan: Rural STEMI Clinical Decision Support App

**Branch**: `001-rural-stemi-clinical` | **Date**: 2025-09-25 | **Spec**: [./spec.md](./spec.md)
**Input**: Feature specification from `specs/001-rural-stemi-clinical/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Fill the Constitution Check section based on the content of the constitution document.
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, `GEMINI.md` for Gemini CLI, `QWEN.md` for Qwen Code or `AGENTS.md` for opencode).
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
The primary goal is to build a clinical decision support app for rural paramedics to improve STEMI care. The app will provide a checklist of tasks, a timer, navigation to appropriate hospitals, and decision support for transport. The technical approach will be a Flutter-based mobile app using Firebase for backend services and the Google Healthcare API for FHIR data storage.

## Technical Context
**Language/Version**: Dart 3.3.0
**Primary Dependencies**: Flutter, Riverpod, GoRouter, Firebase (Auth, Firestore), Google Maps SDK, FHIR
**Storage**: Firebase Firestore for user data and surveys, Google Cloud FHIR server for PHI.
**Testing**: flutter_test, mockito, mocktail, fake_cloud_firestore
**Target Platform**: iOS, Android
**Project Type**: Mobile
**Performance Goals**: Real-time navigation and data synchronization with minimal latency.
**Constraints**: HIPAA compliance for all patient data, offline capability for navigation and core features.
**Scale/Scope**: Initial rollout to rural EMS agencies in a specific region, with the potential to expand to other regions and conditions.

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Clean Architecture**: Compliant. The project follows a clear domain, application, data, and presentation layer structure.
- **State Management**: Compliant. The project uses Riverpod for state management.
- **Testing Philosophy**: Compliant. The project includes dependencies for unit, widget, and integration testing.
- **Coding Style & Quality**: Compliant. The project uses `very_good_analysis` for linting.
- **Navigation**: Compliant. The project uses GoRouter for navigation.
- **Asynchronous Operations**: Compliant. The project uses `rxdart` for reactive programming.
- **Immutability & Data Modeling**: Compliant. The project uses `equatable` for immutable data models.

## Project Structure

### Documentation (this feature)
```
specs/001-rural-stemi-clinical/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
# Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure]
```

**Structure Decision**: Option 3: Mobile + API

## Phase 0: Outline & Research
No major research is required as the user has provided detailed information about the existing codebase and desired features. The technical context is well-defined.

**Output**: research.md (skipped)

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1.  **Extract entities from feature spec** → `data-model.md`:
    -   Entities: `PatientInfo`, `TimeMetrics`, `Hospital`, `Route`, `Survey`
    -   Relationships: Defined by interactions between features.
    -   Validation rules: To be defined based on clinical guidelines.
2.  **Generate API contracts** from functional requirements:
    -   FHIR server interactions for `Encounter`, `Condition`, `Observation`, `Patient`, `Practitioner`, `QuestionnaireResponse`.
    -   Firebase Firestore interactions for `Survey` and user profile data.
3.  **Generate contract tests** from contracts:
    -   Tests for FHIR resource creation and retrieval.
    -   Tests for Firestore data writing and reading.
4.  **Extract test scenarios** from user stories:
    -   Integration tests for the entire user flow, from login to survey submission.
5.  **Update agent file incrementally** (O(1) operation):
    -   Run `.specify/scripts/bash/update-agent-context.sh gemini`
    -   **IMPORTANT**: Execute it exactly as specified above. Do not add or remove any arguments.
    -   If exists: Add only NEW tech from current plan
    -   Preserve manual additions between markers
    -   Update recent changes (keep last 3)
    -   Keep under 150 lines for token efficiency
    -   Output to repository root

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, agent-specific file

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.specify/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- Each contract → contract test task [P]
- Each entity → model creation task [P]
- Each user story → integration test task
- Implementation tasks to make tests pass

**Ordering Strategy**:
- TDD order: Tests before implementation
- Dependency order: Models before services before UI
- Mark [P] for parallel execution (independent files)

**Estimated Output**: 25-30 numbered, ordered tasks in tasks.md

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)
**Phase 4**: Implementation (execute tasks.md following constitutional principles)
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A       | N/A        | N/A                                 |


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [X] Phase 0: Research complete (/plan command)
- [X] Phase 1: Design complete (/plan command)
- [X] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [X] Initial Constitution Check: PASS
- [X] Post-Design Constitution Check: PASS
- [X] All NEEDS CLARIFICATION resolved
- [ ] Complexity deviations documented

---
*Based on Constitution v1.0.0 - See `/.specify/memory/constitution.md`*