# Tasks for Rural STEMI Clinical Decision Support App

**Feature**: Rural STEMI Clinical Decision Support App
**Branch**: `001-rural-stemi-clinical`

This document outlines the tasks required to implement the Rural STEMI Clinical Decision Support App feature. The tasks are ordered by dependency.

## Phase 1: Setup and Configuration

- **T001**: [DONE] Set up a new Firebase project and configure it for both iOS and Android platforms.
- **T002**: Implement a new authentication method to allow the app to save data to the Google Cloud FHIR server. This method must not use a service account. The current phone authentication is for a demo version only and does not have the required permissions to write to the FHIR server. This task will serve as a placeholder for the new implementation.
- **T003**: [DONE] Configure `very_good_analysis` in the `analysis_options.yaml` file and ensure that all linting rules are enabled and passing.

## Phase 2: Data Modeling and Unit Tests [P]

These tasks can be executed in parallel.

- **T004**: [DONE] Create the `patient_info_model.dart` file.
- **T005**: [DONE] Create the `time_metrics_model.dart` file.
- **T006**: [DONE] Create the `hospital_model.dart` file.
- **T007**: [DONE] Create the `route_model.dart` file.
- **T008**: [DONE] Create the `survey_model.dart` file.
- **T009**: **[P]** Optimize unit tests for the `PatientInfo` model in `test/src/features/add_data/domain/patient_info_model_test.dart`.
- **T010**: **[P]** Optimize unit tests for the `TimeMetrics` model in `test/src/features/add_data/domain/time_metrics_model_test.dart`.
- **T011**: **[P]** Optimize unit tests for the `Hospital` model in `test/src/features/navigate/domain/hospital_model_test.dart`.
- **T012**: **[P]** Optimize unit tests for the `Route` model in `test/src/features/navigate/domain/route_model_test.dart`.
- **T013**: **[P]** Optimize unit tests for the `Survey` model in `test/src/features/survey/domain/survey_model_test.dart`.

## Phase 3: Implementation

### Feature: Login and Setup

- **T014**: Implement the UI for the Login and Setup screen in `lib/src/features/auth/presentation/login_setup_screen.dart`.
- **T015**: Implement the business logic in a Riverpod provider to check if the user has accepted the terms and conditions by reading a value from their user document in Firestore.
- **T016**: Implement the logic to write the user's acceptance of the terms and conditions to their document in Firestore.

### Feature: Add Data

- **T017**: Implement the UI for the Patient Info screen in `lib/src/features/add_data/presentation/patient_info_screen.dart`.
- **T018**: Implement the driver's license scanning functionality using the `mobile_scanner` package.
- **T019**: Implement the `drivers_license_to_patient_info.dart` extension to parse the scanned data and populate the `PatientInfo` model.
- **T020**: Implement a service to track time metrics throughout the encounter.

### Feature: Navigate

- **T021**: Implement the UI for the Hospital List screen in `lib/src/features/navigate/presentation/hospital_list_screen.dart`.
- **T022**: Implement the `RoutesService` in `lib/src/features/navigate/application/routes_service.dart` to fetch nearby hospitals from Firestore.
- **T023**: Implement the `GoogleNavigationService` in `lib/src/features/navigate/application/google_navigation_service.dart` to interact with the Google Navigation SDK.
- **T024**: Implement the turn-by-turn navigation UI, displaying the map and route information.

### Feature: Survey

- **T025**: Implement the UI for the Survey screen in `lib/src/features/survey/presentation/survey_screen.dart`.
- **T026**: Implement the logic to submit the survey results to Firestore.

### Feature: FHIR Sync

- **T027**: Implement the `patient_info_fhir.dart` extension to convert the `PatientInfo` model to a FHIR Patient resource.
- **T028**: Implement the `time_metrics_fhir.dart` extension to convert the `TimeMetrics` model to FHIR Observation resources.
- **T029**: Implement a service to sync all encounter data to the Google Healthcare API FHIR server.

### Feature: Data Analysis

- **T042**: Create a placeholder screen for data analysis for authorized personnel in `lib/src/features/analysis/presentation/analysis_screen.dart`. The screen should display a message indicating that the feature is under development.

## Phase 4: Integration and Testing

- **T030**: [DONE] Integrate Firebase Authentication for user login.
- **T031**: Write integration tests for the login and setup flow.
- **T032**: Write integration tests for the data adding feature, including driver's license scanning.
- **T033**: Write integration tests for the navigation feature, mocking the Google Navigation SDK.
- **T034**: Write integration tests for the survey feature, using `fake_cloud_firestore`.
- **T035**: Write integration tests for the FHIR sync feature, mocking the Google Healthcare API.

## Phase 5: Polish [P]

These tasks can be executed in parallel.

- **T036**: **[P]** Add comprehensive documentation to all public APIs and widgets.
- **T037**: **[P]** Conduct performance testing to identify and address any bottlenecks.
- **T038**: **[P]** Review and refactor the entire codebase for clarity, conciseness, and adherence to the constitution.

## Parallel Execution Example

```bash
# Execute all data modeling and unit testing tasks in parallel
/execute_task T009 &
/execute_task T010 &
/execute_task T011 &
/execute_task T012 &
/execute_task T013 &
```