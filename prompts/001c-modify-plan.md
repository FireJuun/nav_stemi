/plan
As it stands, the `data-model.md` file is insufficient. Please do some more research on this project's data structure so that the data model in the plan matches what is in the app. Specifically...

## Feature: Add Data
`lib/src/features/add_data/domain/patient_info_model.dart` and `lib/src/features/add_data/domain/time_metrics_model.dart` show the patient info and time metrics that are being tracked, respectively.

Extensions exist to convert these data to FHIR elements in `lib/src/features/add_data/domain/data_transfer_objects/patient_info_fhir.dart` and `lib/src/features/add_data/domain/data_transfer_objects/time_metrics_fhir.dart`, with additional conversions when scanning a driver's license barcode into patient info (`lib/src/features/add_data/domain/data_transfer_objects/drivers_license_to_patient_info.dart`).

## Feature: FHIR Sync
Extensions also exist to convert FHIR data to/from the data model in this app, such as the Encounter, Condition, Observation, Patient, Practitioner, and QuestionnaireResponse references in `lib/src/features/fhir_sync/domain/`.

## Feature: Navigate
The data listed in `lib/src/features/navigate/domain` show the relevant navigation and route options, with a means to check firestore to find the nearest 10 hospitals within the region (see file `lib/src/features/navigate/application/routes_service.dart`, method `getNearbyHospitalsFromCurrentLocation()`). The way that permissions are handled in this could be optimized. A preferred example would be an intro screen after login that allows you to input last name / first name, and allows you to accept the google maps terms and conditions (`showTermsAndConditionsDialog()` from `lib/src/features/navigate/application/google_navigation_service.dart` is not optimal). This intro screen would only show up if terms and conditions haven't been accepted for the user OR if the last / fist name haven't been set up.

## Feature: Survey
See `lib/src/features/survey/domain/survey_model.dart` for more info. Should be a simple survey that's submitted to Firestore after completion. It appears only when you exit an encounter. Tagging that to an encounter is not currently in scope, since that could imply PHI (date/time), which we don't want on firestore.