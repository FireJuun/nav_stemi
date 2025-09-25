# Quickstart

This guide provides a high-level overview of the Nav STEMI application's functionality.

## 1. Login and Setup
- Upon first login, the user is prompted to enter their last name and first name.
- The user must accept the Google Maps terms and conditions.
- This setup screen is only shown if the user's name is not set or if they have not accepted the terms and conditions.

## 2. Start Encounter
- When an encounter begins, a timer starts automatically.
- The user is presented with a checklist of tasks.

## 3. Add Patient Data
- The user can manually enter patient information.
- Alternatively, they can scan a driver's license to populate the patient's information.
- Time metrics, such as on-scene time and ECG time, are tracked.

## 4. Navigate to Hospital
- The app displays a list of nearby hospitals, indicating whether they are PCI-capable or thrombolytic-capable.
- The app provides real-time travel estimates and recommends a destination based on transport time.
- Once a destination is selected, the app provides turn-by-turn navigation.

## 5. Complete Encounter
- When the encounter is complete, the user is presented with a survey.
- The survey results are submitted to Firestore.

## 6. Data Sync
- All encounter data is converted to FHIR resources and synced with a Google Healthcare API FHIR server.