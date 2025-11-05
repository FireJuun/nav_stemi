# Research Findings for Rural STEMI Clinical Decision Support App

**Branch**: `001-rural-stemi-clinical` | **Date**: 2025-09-25 | **Spec**: [specs/001-rural-stemi-clinical/spec.md]

This document summarizes the research findings for the initial implementation plan.

## 1. Flutter & Google Maps API Integration for Real-Time Navigation

*   **Decision**: Use the `google_maps_flutter` package for map rendering and the `geolocator` package for location tracking. The Google Directions API will be called to get the initial route, and the app will track user progress along the polyline, only refetching the route if the user deviates significantly.
*   **Rationale**: This approach is the standard and most efficient way to implement real-time navigation in Flutter. It minimizes API calls to the Directions API, which is cost-effective and performant.
*   **Alternatives Considered**: Calling the Directions API on every location update was rejected as it is inefficient and costly.

## 2. HIPAA-Compliant Data Handling

*   **Decision**:
    *   Sign a Business Associate Agreement (BAA) with Google Cloud.
    *   Use Firebase Firestore for PII (EMS personnel data) and the Google Cloud FHIR API for PHI (patient data).
    *   Implement strict Firestore Security Rules for role-based access control.
    *   Use Google Cloud IAM for server-side permissions.
    *   Encrypt all data in transit (using TLS) and at rest (default on GCP).
    *   In the Flutter app, use `flutter_secure_storage` for sensitive data like auth tokens.
    *   Never include PHI in push notifications or logs.
*   **Rationale**: This layered approach ensures compliance with HIPAA regulations by using services covered by Google's BAA for sensitive data and implementing strict access controls at every layer of the application.
*   **Alternatives Considered**: Storing all data in Firestore was rejected because not all Firebase services are covered by the BAA, and the FHIR API is specifically designed for healthcare data.

## 3. Offline-First Caching with Riverpod

*   **Decision**:
    *   Adopt an offline-first approach where the app primarily reads from and writes to a local cache.
    *   Use the `riverpod_offline` package with Hive for local caching of non-relational data like user settings and checklists.
    *   For the route information, the fetched route from Google Maps will be cached in memory for the duration of the navigation.
    *   Use the `connectivity_plus` package to monitor network status and trigger data synchronization.
    *   Implement optimistic UI updates for a responsive user experience.
*   **Rationale**: This strategy ensures the app remains functional in low-connectivity environments, which is critical for rural EMS. Hive is chosen for its performance and ease of use with Riverpod. Caching the route in memory is sufficient for the navigation use case.
*   **Alternatives Considered**: Using SQFlite was considered but deemed overly complex for the current caching needs, which are primarily key-value based.