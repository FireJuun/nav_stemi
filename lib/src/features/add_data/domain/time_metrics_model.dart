// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class TimeMetricsModel extends Equatable {
  const TimeMetricsModel({
    /// Locks for each time metric to prevent editing
    this.timeArrivedAtPatient,
    this.lockTimeArrivedAtPatient = false,
    this.timeOfEkgs = const {},
    this.lockTimeOfEkgs = false,
    this.timeOfStemiActivationDecision,
    this.wasStemiActivated,
    this.lockTimeOfStemiActivationDecision = false,
    this.timeUnitLeftScene,
    this.lockTimeUnitLeftScene = false,
    this.timeOfAspirinGivenDecision,
    this.wasAspirinGiven,
    this.lockTimeOfAspirinGivenDecision = false,
    this.timeCathLabNotifiedDecision,
    this.wasCathLabNotified,
    this.lockTimeCathLabNotifiedDecision = false,
    this.timePatientArrivedAtDestination,
    this.lockTimePatientArrivedAtDestination = false,
    this.isDirty = true, // Default to true, so new data is marked for syncing
  });

  /// KEY start time of first medical contact
  /// The time the unit arrived at the patient's side
  /// spec: https://nemsis.org/media/nemsis_v3/release-3.5.0/DataDictionary/PDFHTML/EMSDEMSTATE/sections/elements/eTimes.07.xml
  final DateTime? timeArrivedAtPatient;
  final bool lockTimeArrivedAtPatient;

  /// For now, the timestamps when EKGs are performed
  /// It is possible to expand this data model to include more values
  /// from the eVitals.CardiacRhythmGroup section of the NEMSIS data dictionary
  /// spec: https://nemsis.org/media/nemsis_v3/release-3.5.0/DataDictionary/PDFHTML/EMSDEMSTATE/sections/eVitals.002.xml
  final Set<DateTime?> timeOfEkgs;
  final bool lockTimeOfEkgs;

  /// The time the STEMI was activated
  /// Tri-state boolean that logs if the STEMI was activated
  /// true -> STEMI was activated
  /// false -> STEMI was not activated
  /// null -> STEMI activation decision not made
  /// This is not part of the NEMSIS data dictionary
  // TODO(FireJuun): find NEMSIS link for this (or equivalent)
  final DateTime? timeOfStemiActivationDecision;
  final bool? wasStemiActivated;
  final bool lockTimeOfStemiActivationDecision;

  /// The time the unit left the scene
  /// spec: https://nemsis.org/media/nemsis_v3/release-3.5.0/DataDictionary/PDFHTML/EMSDEMSTATE/sections/elements/eTimes.08.xml
  final DateTime? timeUnitLeftScene;
  final bool lockTimeUnitLeftScene;

  /// Custom times, requested by end-users
  /// These are not part of the NEMSIS data dictionary

  /// Tri-state boolean that logs if aspirin was given
  /// true -> aspirin was given
  /// false -> aspirin was not given
  /// null -> aspirin decision not made
  /// This is not part of the NEMSIS data dictionary
  // TODO(FireJuun): find NEMSIS link for this (or equivalent)
  final DateTime? timeOfAspirinGivenDecision;
  final bool? wasAspirinGiven;
  final bool lockTimeOfAspirinGivenDecision;

  /// Tri-state boolean that logs if the cath lab was notified
  /// true -> cath lab was notified
  /// false -> cath lab declined or unavailable
  /// null -> cath lab notification decision not made
  final DateTime? timeCathLabNotifiedDecision;
  final bool? wasCathLabNotified;
  final bool lockTimeCathLabNotifiedDecision;

  /// The time the patient arrived at the destination, such as a hospital
  /// https://nemsis.org/media/nemsis_v3/release-3.5.0/DataDictionary/PDFHTML/EMSDEMSTATE/sections/elements/eTimes.11.xml
  final DateTime? timePatientArrivedAtDestination;
  final bool lockTimePatientArrivedAtDestination;

  /// Indicates whether this model has changes that need to be synced to FHIR
  /// - true: local changes need to be synced to FHIR
  /// - false: model is in sync with FHIR resources
  final bool isDirty;

  TimeMetricsModel copyWith({
    ValueGetter<DateTime?>? timeArrivedAtPatient,
    ValueGetter<bool>? lockTimeArrivedAtPatient,
    ValueGetter<Set<DateTime?>?>? timeOfEkgs,
    ValueGetter<bool>? lockTimeOfEkgs,
    ValueGetter<DateTime?>? timeOfStemiActivationDecision,
    ValueGetter<bool?>? wasStemiActivated,
    ValueGetter<bool>? lockTimeOfStemiActivationDecision,
    ValueGetter<DateTime?>? timeUnitLeftScene,
    ValueGetter<bool>? lockTimeUnitLeftScene,
    ValueGetter<DateTime?>? timeOfAspirinGivenDecision,
    ValueGetter<bool?>? wasAspirinGiven,
    ValueGetter<bool>? lockTimeOfAspirinGivenDecision,
    ValueGetter<DateTime?>? timeCathLabNotifiedDecision,
    ValueGetter<bool?>? wasCathLabNotified,
    ValueGetter<bool>? lockTimeCathLabNotifiedDecision,
    ValueGetter<DateTime?>? timePatientArrivedAtDestination,
    ValueGetter<bool>? lockTimePatientArrivedAtDestination,
    ValueGetter<bool>? isDirty,
  }) {
    /// Sort EKGs by time they were performed.
    /// This is preferred when updating EKG info.
    final ekgs = timeOfEkgs != null ? timeOfEkgs() : this.timeOfEkgs;

    return TimeMetricsModel(
      timeArrivedAtPatient: timeArrivedAtPatient != null
          ? timeArrivedAtPatient()
          : this.timeArrivedAtPatient,
      lockTimeArrivedAtPatient: lockTimeArrivedAtPatient != null
          ? lockTimeArrivedAtPatient()
          : this.lockTimeArrivedAtPatient,
      timeOfEkgs: sortedEkgsByDateTime(ekgs),
      lockTimeOfEkgs:
          lockTimeOfEkgs != null ? lockTimeOfEkgs() : this.lockTimeOfEkgs,
      timeOfStemiActivationDecision: timeOfStemiActivationDecision != null
          ? timeOfStemiActivationDecision()
          : this.timeOfStemiActivationDecision,
      wasStemiActivated: wasStemiActivated != null
          ? wasStemiActivated()
          : this.wasStemiActivated,
      lockTimeOfStemiActivationDecision:
          lockTimeOfStemiActivationDecision != null
              ? lockTimeOfStemiActivationDecision()
              : this.lockTimeOfStemiActivationDecision,
      timeUnitLeftScene: timeUnitLeftScene != null
          ? timeUnitLeftScene()
          : this.timeUnitLeftScene,
      lockTimeUnitLeftScene: lockTimeUnitLeftScene != null
          ? lockTimeUnitLeftScene()
          : this.lockTimeUnitLeftScene,
      timeOfAspirinGivenDecision: timeOfAspirinGivenDecision != null
          ? timeOfAspirinGivenDecision()
          : this.timeOfAspirinGivenDecision,
      wasAspirinGiven:
          wasAspirinGiven != null ? wasAspirinGiven() : this.wasAspirinGiven,
      lockTimeOfAspirinGivenDecision: lockTimeOfAspirinGivenDecision != null
          ? lockTimeOfAspirinGivenDecision()
          : this.lockTimeOfAspirinGivenDecision,
      timeCathLabNotifiedDecision: timeCathLabNotifiedDecision != null
          ? timeCathLabNotifiedDecision()
          : this.timeCathLabNotifiedDecision,
      wasCathLabNotified: wasCathLabNotified != null
          ? wasCathLabNotified()
          : this.wasCathLabNotified,
      lockTimeCathLabNotifiedDecision: lockTimeCathLabNotifiedDecision != null
          ? lockTimeCathLabNotifiedDecision()
          : this.lockTimeCathLabNotifiedDecision,
      timePatientArrivedAtDestination: timePatientArrivedAtDestination != null
          ? timePatientArrivedAtDestination()
          : this.timePatientArrivedAtDestination,
      lockTimePatientArrivedAtDestination:
          lockTimePatientArrivedAtDestination != null
              ? lockTimePatientArrivedAtDestination()
              : this.lockTimePatientArrivedAtDestination,
      isDirty:
          !(isDirty != null) || isDirty(), // Default to dirty on changes
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'timeArrivedAtPatient': timeArrivedAtPatient?.millisecondsSinceEpoch,
      'lockTimeArrivedAtPatient': lockTimeArrivedAtPatient,
      'timeOfEkgs': timeOfEkgs.map((x) => x?.millisecondsSinceEpoch).toList(),
      'lockTimeOfEkgs': lockTimeOfEkgs,
      'timeOfStemiActivationDecision':
          timeOfStemiActivationDecision?.millisecondsSinceEpoch,
      'wasStemiActivated': wasStemiActivated,
      'lockTimeOfStemiActivationDecision': lockTimeOfStemiActivationDecision,
      'timeUnitLeftScene': timeUnitLeftScene?.millisecondsSinceEpoch,
      'lockTimeUnitLeftScene': lockTimeUnitLeftScene,
      'timeOfAspirinGivenDecision':
          timeOfAspirinGivenDecision?.millisecondsSinceEpoch,
      'wasAspirinGiven': wasAspirinGiven,
      'lockTimeOfAspirinGivenDecision': lockTimeOfAspirinGivenDecision,
      'timeCathLabNotifiedDecision':
          timeCathLabNotifiedDecision?.millisecondsSinceEpoch,
      'wasCathLabNotified': wasCathLabNotified,
      'lockTimeCathLabNotifiedDecision': lockTimeCathLabNotifiedDecision,
      'timePatientArrivedAtDestination':
          timePatientArrivedAtDestination?.millisecondsSinceEpoch,
      'lockTimePatientArrivedAtDestination':
          lockTimePatientArrivedAtDestination,
      'isDirty': isDirty,
    };
  }

  factory TimeMetricsModel.fromMap(Map<String, dynamic> map) {
    return TimeMetricsModel(
      timeArrivedAtPatient: map['timeArrivedAtPatient'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['timeArrivedAtPatient'] as int,
            )
          : null,
      lockTimeArrivedAtPatient: map['lockTimeArrivedAtPatient'] as bool,
      timeOfEkgs: Set<DateTime?>.from(
        (map['timeOfEkgs'] as List<int>).map<DateTime?>(
          DateTime.fromMillisecondsSinceEpoch,
        ),
      ),
      lockTimeOfEkgs: map['lockTimeOfEkgs'] as bool,
      timeOfStemiActivationDecision:
          map['timeOfStemiActivationDecision'] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  map['timeOfStemiActivationDecision'] as int,
                )
              : null,
      wasStemiActivated: map['wasStemiActivated'] != null
          ? map['wasStemiActivated'] as bool
          : null,
      lockTimeOfStemiActivationDecision:
          map['lockTimeOfStemiActivationDecision'] as bool,
      timeUnitLeftScene: map['timeUnitLeftScene'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timeUnitLeftScene'] as int)
          : null,
      lockTimeUnitLeftScene: map['lockTimeUnitLeftScene'] as bool,
      timeOfAspirinGivenDecision: map['timeOfAspirinGivenDecision'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['timeOfAspirinGivenDecision'] as int,
            )
          : null,
      wasAspirinGiven: map['wasAspirinGiven'] != null
          ? map['wasAspirinGiven'] as bool
          : null,
      lockTimeOfAspirinGivenDecision:
          map['lockTimeOfAspirinGivenDecision'] as bool,
      timeCathLabNotifiedDecision: map['timeCathLabNotifiedDecision'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['timeCathLabNotifiedDecision'] as int,
            )
          : null,
      wasCathLabNotified: map['wasCathLabNotified'] != null
          ? map['wasCathLabNotified'] as bool
          : null,
      lockTimeCathLabNotifiedDecision:
          map['lockTimeCathLabNotifiedDecision'] as bool,
      timePatientArrivedAtDestination:
          map['timePatientArrivedAtDestination'] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  map['timePatientArrivedAtDestination'] as int,
                )
              : null,
      lockTimePatientArrivedAtDestination:
          map['lockTimePatientArrivedAtDestination'] as bool,
      isDirty: !(map['isDirty'] != null) || map['isDirty'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory TimeMetricsModel.fromJson(String source) =>
      TimeMetricsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      timeArrivedAtPatient,
      lockTimeArrivedAtPatient,
      timeOfEkgs,
      lockTimeOfEkgs,
      timeOfStemiActivationDecision,
      wasStemiActivated,
      lockTimeOfStemiActivationDecision,
      timeUnitLeftScene,
      lockTimeUnitLeftScene,
      timeOfAspirinGivenDecision,
      wasAspirinGiven,
      lockTimeOfAspirinGivenDecision,
      timeCathLabNotifiedDecision,
      wasCathLabNotified,
      lockTimeCathLabNotifiedDecision,
      timePatientArrivedAtDestination,
      lockTimePatientArrivedAtDestination,
      isDirty,
    ];
  }

  /// Sorts the EKGs by the time they were performed
  /// Defaults to using data stored in [timeOfEkgs] in this model,
  /// but can also be passed a separate set of EKGs to sort.
  Set<DateTime?> sortedEkgsByDateTime([Set<DateTime?>? ekgs]) {
    final sortedEkgs = (ekgs ?? timeOfEkgs).sorted((aDate, bDate) {
      if (aDate == null) {
        return -1;
      }
      if (bDate == null) {
        return 1;
      }
      return aDate.compareTo(bDate);
    });
    return sortedEkgs.toSet();
  }

  /// Returns the time of the first EKG, if avialable
  DateTime? timeOfFirstEkg() => timeOfEkgs.firstOrNull;

  /// Tri-state boolean that checks for all data to be present,
  /// then checks to see if the time metric has been met.
  ///
  /// true -> data present and meets the 5 minute requirement
  /// null -> data present, but failed to meet the 5 minute requirement
  /// false -> no data present
  bool? hasEkgByFiveMin() {
    final timeArrived = timeArrivedAtPatient;
    final firstEkg = timeOfFirstEkg();

    if (timeArrived == null || firstEkg == null) {
      /// No data present
      return false;
    }

    if (firstEkg.isAfter(timeArrived) &&
        firstEkg.difference(timeArrived).inSeconds <= 300) {
      /// Data present and meets the 5 minute requirement
      return true;
    } else {
      /// Data present, but failed to meet the 5 minute requirement
      return null;
    }
  }

  /// Tri-state boolean that checks for all data to be present,
  /// then checks to see if the time metric has been met.
  ///
  /// true -> data present and meets the 10 minute requirement
  /// null -> data present, but failed to meet the 10 minute requirement
  /// false -> no data present
  bool? hasLeftByTenMin() {
    final timeArrived = timeArrivedAtPatient;
    final timeLeftScene = timeUnitLeftScene;

    if (timeArrived == null || timeLeftScene == null) {
      /// No data present
      return false;
    }

    if (timeLeftScene.isAfter(timeArrived) &&
        timeLeftScene.difference(timeArrived).inSeconds <= 600) {
      /// Data present and meets the 10 minute requirement
      return true;
    } else {
      /// Data present, but failed to meet the 10 minute requirement
      return null;
    }
  }

  /// Tri-state boolean that checks for all data to be present,
  /// then checks to see if the time metric has been met.
  ///
  /// true -> data present and meets the 60 minute requirement
  /// null -> data present, but failed to meet the 10 minute requirement
  /// false -> no data present
  bool? hasArrivedBySixtyMin() {
    final timeArrived = timeArrivedAtPatient;
    final timeAtDestination = timePatientArrivedAtDestination;

    if (timeArrived == null || timeAtDestination == null) {
      /// No data present
      return false;
    }

    if (timeAtDestination.isAfter(timeArrived) &&
        timeAtDestination.difference(timeArrived).inSeconds <= 3600) {
      /// Data present and meets the 60 minute requirement
      return true;
    } else {
      /// Data present, but failed to meet the 60 minute requirement
      return null;
    }
  }

  /// Creates a copy of this model with [isDirty] set to false,
  /// indicating it has been synced with FHIR
  TimeMetricsModel markSynced() {
    return copyWith(isDirty: () => false);
  }

  /// Creates a copy of this model with [isDirty] set to true,
  /// indicating it has changes that need to be synced with FHIR
  TimeMetricsModel markDirty() {
    return copyWith(isDirty: () => true);
  }
}
