# Feature Specification: Rural STEMI Clinical Decision Support App

**Feature Branch**: `001-rural-stemi-clinical`
**Created**: 2025-09-25
**Status**: Draft
**Input**: User description: "Reverse engineer what we are trying to buid based on the Updated Research Plan..."

---

## ⚡ Quick Guidelines
- ✅ Focus on WHAT users need and WHY
- ❌ Avoid HOW to implement (no tech stack, APIs, code structure)
- 👥 Written for business stakeholders, not developers

---
## Clarifications
### Session 2025-09-25
- Q: What should the data retention and ownership policy be for the STEMI encounter data? → A: This should be drafted using boilerplate text in a manner that is HIPAA compliant. PHI data will be stored on a Google Healthcare API FHIR server. PII data (such as EMS personnell) will be stored on FHIR and on a Firebase server. Users may request to delete their PII from Firebase at anytime. Data deletion per FHIR should follow common healthcare data standards
- Q: How should the app behave if the user denies location permissions? → A: The app should not be usable and display a message explaining why location is required.
- Q: FR-010 mentions generalizing the app for other conditions like stroke and sepsis. Should the initial data model be generic, or should it be specific to STEMI for this first version? → B: Keep the data model specific to STEMI for now and refactor later when adding new conditions.

## User Scenarios & Testing *(mandatory)*

### Primary User Story
As a rural paramedic responding to a potential heart attack, I need a reliable, all-in-one digital tool that helps me quickly follow best practices, make critical transport decisions, and reduce the time to treatment, so that I can improve my patient's chances of survival.

### Acceptance Scenarios
1.  **Given** a paramedic is on-scene with a patient suspected of STEMI, **When** the paramedic launches the app, **Then** they are presented with a clear checklist of critical tasks and a visible on-scene timer starts automatically.
2.  **Given** a patient's location is known, **When** the paramedic needs to decide on a destination, **Then** the app displays a list of PCI-capable and thrombolytic-capable hospitals within a 100-mile radius, including real-time travel estimates.
3.  **Given** the app predicts transport time to the nearest PCI center will exceed 120 minutes, **When** the paramedic reviews the destination options, **Then** the app provides a clear decision support recommendation to consider a closer hospital for thrombolytic therapy.
4.  **Given** a destination is selected, **When** the paramedic begins transport, **Then** the app provides turn-by-turn navigation that adapts to current traffic conditions.
5.  **Given** an EMS administrator needs to review performance, **When** they access the system's data, **Then** they can see usage statistics, time metrics for each encounter, and survey feedback to identify areas for improvement.

### Edge Cases
- What happens if the device loses GPS signal or network connectivity during navigation? The app should cache the route and continue navigation, and clearly indicate the loss of real-time traffic data.
- How does the system handle a scenario where no hospitals are within the 100-mile radius? It should inform the paramedic and potentially suggest alternative protocols like air transport if available.
- What happens if the paramedic disagrees with the app's recommendation? The paramedic must have the final say and the ability to override any suggestion, and the app should log this action.
- What happens if the user denies location permissions? The app MUST NOT be usable and MUST display a message explaining that location permissions are essential for its core functionality.

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: The system MUST provide a clinical decision support tool for rural paramedics at the point-of-care for patients with STEMI.
- **FR-002**: The app MUST include a checklist of key EMS tasks for timely STEMI care.
- **FR-003**: The app MUST display a visible, automatically starting on-scene timer to track critical time metrics.
- **FR-004**: The app MUST provide turn-by-turn directions to hospitals within a 100-mile radius of the patient’s location.
- **FR-005**: The navigation MUST incorporate real-time EMS unit location and route guidance responsive to current road conditions.
- **FR-006**: The system MUST provide destination decision support to guide transport for PCI vs. thrombolytic reperfusion strategies based on predicted travel times and ACC/AHA guidelines.
- **FR-007**: The system MUST include an integrated survey for paramedics to provide real-time feedback on the app's usability and effectiveness.
- **FR-008**: The system MUST collect and store data for each STEMI encounter (including timers, user actions, location data) in a HIPAA-compliant manner.
- **FR-009**: The system MUST allow authorized personnel (e.g., EMS administrators, researchers) to access and analyze collected data to measure outcomes like feasibility, effectiveness, and adoption.
- **FR-010**: The system MUST be designed to be generalizable for other time-dependent conditions such as stroke, sepsis, and trauma. For the initial version, the data model will be specific to STEMI and will be refactored in the future to support other conditions. Common data points include time of EMS arrival to patient, time of condition identification, time of critical intervention, time of arrival to hospital. 
- **FR-011**: The system MUST allow for the exclusion of specific patient populations (prisoners, pregnant patients, interfacility transfers) from data collection and analysis.
- **FR-012**: Data Governance and Retention:
    - Protected Health Information (PHI) MUST be stored on a Google Cloud FHIR server and managed according to HIPAA and common healthcare data standards.
    - Personally Identifiable Information (PII) for EMS personnel may be stored in Firebase.
    - Users MUST have the ability to request the deletion of their PII from Firebase at any time.

### Key Entities *(include if feature involves data)*
- **STEMI Encounter**: Represents a single emergency event. Includes patient information (name, date of birth, sex), timestamps (911 call, first medical contact, ECG, reperfusion), locations, selected destination, and all associated app interactions.
- **Paramedic User**: Represents the EMS clinician using the app. Includes their agency affiliation and an identifier for tracking adoption and feedback.
- **Hospital**: Represents a destination facility. Includes its location, capabilities (PCI-capable, thrombolytic-capable), and contact information.
- **Route**: Represents a calculated travel plan. Includes start/end points, turn-by-turn directions, and estimated travel time based on real-time traffic.
- **Feedback Survey**: Represents a user's responses to the in-app survey. Linked to a specific STEMI Encounter and Paramedic User.

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [X] No implementation details (languages, frameworks, APIs)
- [X] Focused on user value and business needs
- [X] Written for non-technical stakeholders
- [X] All mandatory sections completed

### Requirement Completeness
- [X] No [NEEDS CLARIFICATION] markers remain
- [X] Requirements are testable and unambiguous
- [X] Success criteria are measurable
- [X] Scope is clearly bounded
- [X] Dependencies and assumptions identified

---