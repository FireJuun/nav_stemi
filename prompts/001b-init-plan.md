/plan
Generate a detailed technical plan based on the provided specification. It is CRITICAL that you adhere to the existing architecture, data models, and services described below. Do not invent new models if existing ones fit.

The plan should detail:
1.  **Architecture:** How the UI will interact with services to fetch data from both the Google Maps API and our Firebase `EmergencyDepartments` collection.
2.  **Data Flow:** Describe the sequence of API calls. For example: first, get `CurrentLocation`, then query `EmergencyDepartments` in Firebase to find PCI centers, then pass those coordinates to the Google Maps API to get `AvailableRoutes`.
3.  **State Management:** Explain which local data models (`AvailableRoutes`, `Route`, etc.) will be populated and how the app's state will be updated and exposed to the UI, according to our `constitution.md`.
4.  **Service Layer:** Define the functions needed in our repository or service classes to handle the API calls.
5.  **UI Components:** List the key Flutter widgets required to display the routes on a map and in a list view.

**Here is the mandatory architectural context for the navSTEMI application:**

**Architectural Context for the navSTEMI Application:**

The application has a clear separation between local data models and remote data sources.

**1. Local Data Models (On-Device):**
These are the primary Dart classes used to manage state within the app.
* **`CurrentLocation`**: Tracks the device's GPS location, updates, and settings.
* **`AvailableRoutes`**: A container for multiple route options.
    * Holds a list of `Route` objects.
* **`Route`**: Represents a single path from an origin to a destination.
    * Properties: `origin`, `destination`, `requestedTimestamp`, `markers`, `polylineString`.
    * Contains a list of `RouteLegStep` objects.
* **`RouteLegStep`**: A single step or maneuver within a `Route`.
    * Properties: `stepInfo`, `stopInfo`, `polylineString`.
* **`ActiveRoute`**: The route currently selected and being navigated by the user.
    * Properties: `activeRouteID`, `activeStepID`, `routeOption`, `totalDistance`.
* **`EDInfo` (Emergency Department Info)**: A model for a single hospital.
    * Properties: `name`, `shortName`, `marker (LatLng)`.
* **`NearbyEDs`**: A model to hold a list of up to 10 nearby EDs.
    * Contains a list of `EDInfo` objects, each with its `routeTime` and `routeDistance`.
* **`NearestED` / `NearestPCICenter`**: Simple models holding a reference to a hospital and the `routeTime`.

**2. Remote Data Sources & APIs:**

**Auth NOT Required (Public Data):**
* **Google Maps/Routes API**: Used to fetch `RemoteMaps` and `RemoteRoutes` data, including origin, destination, waypoints, polylines, and turn-by-turn directions.
* **Firebase Firestore (or Realtime Database)**:
    * **`EmergencyDepartments` collection**: A public list of all EDs.
        * Fields: `name`, `shortName`, `address`, `region`, `isPCICenter`, `phone`.

**Auth Required (Protected Data):**
* **Firebase Authentication**: Manages user sign-in state (`AuthState`) via email/password and potentially biometrics.
* **Firebase Firestore (or Realtime Database)**:
    * **`EMSPersonnel` collection**: Stores EMS user data.
        * Fields: `licenseID`, `licenseCertLevel`, `firstName`, `lastName`.
* **Google FHIR API**: The primary source for sensitive, protected health information (PHI). All interactions require a valid auth token.
    * **`Patient` resource**: For `PatientData` (name, gender, age, etc.).
    * **`Practitioner` resource**: For `Crew` member data (ID, level, role).
    * **Custom FHIR resources or `Observation` resource**: Used for tracking `Call Times` (e.g., unit arrived, patient contact, destination arrival).