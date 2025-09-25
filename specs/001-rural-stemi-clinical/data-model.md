# Data Model

This document outlines the data models for the Nav STEMI application, based on the feature specification and existing codebase.

## Feature: Add Data

### PatientInfo
- Represents the patient's information.
- **Source:** `lib/src/features/add_data/domain/patient_info_model.dart`
- **Fields:**
    - `lastName`: String
    - `firstName`: String
    - `dateOfBirth`: DateTime
    - `gender`: String
    - `race`: String
    - `address`: String
    - `city`: String
    - `state`: String
    - `zip`: String

### TimeMetrics
- Represents the time metrics tracked during an encounter.
- **Source:** `lib/src/features/add_data/domain/time_metrics_model.dart`
- **Fields:**
    - `onSceneTime`: DateTime
    - `ecgTime`: DateTime
    - `doorTime`: DateTime
    - `stemiFoundTime`: DateTime

### Data Transfer Objects
- **`patient_info_fhir.dart`**: Extension to convert `PatientInfo` to a FHIR Patient resource.
- **`time_metrics_fhir.dart`**: Extension to convert `TimeMetrics` to FHIR Observation resources.
- **`drivers_license_to_patient_info.dart`**: Extension to parse a driver's license barcode and populate `PatientInfo`.

## Feature: FHIR Sync

- The app uses extensions to convert FHIR data to and from the local data model.
- **Source:** `lib/src/features/fhir_sync/domain/`
- **FHIR Resources:**
    - `Encounter`
    - `Condition`
    - `Observation`
    - `Patient`
    - `Practitioner`
    - `QuestionnaireResponse`

## Feature: Navigate

### Hospital
- Represents a hospital.
- **Source:** `lib/src/features/navigate/domain/hospital_model.dart` (assumed)
- **Fields:**
    - `name`: String
    - `address`: String
    - `latitude`: double
    - `longitude`: double
    - `isPciCapable`: bool
    - `isThrombolyticCapable`: bool

### Route
- Represents a route to a hospital.
- **Source:** `lib/src/features/navigate/domain/route_model.dart` (assumed)
- **Fields:**
    - `hospital`: Hospital
    - `duration`: Duration
    - `distance`: double
    - `polyline`: String

## Feature: Survey

### Survey
- Represents the post-encounter survey.
- **Source:** `lib/src/features/survey/domain/survey_model.dart`
- **Fields:**
    - `rating`: int
    - `feedback`: String