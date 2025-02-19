// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class TimeMetricsModel extends Equatable {
  const TimeMetricsModel({
    this.timeArrivedAtPatient,
    this.timeOfEkgs = const {},
    this.timeOfStemiActivation,
    this.timeUnitLeftScene,
    this.timePatientArrivedAtDestination,

    /// Locks for each time metric to prevent editing
    this.lockTimeArrivedAtPatient = false,
    this.lockTimeOfEkgs = false,
    this.lockTimeOfStemiActivation = false,
    this.lockTimeUnitLeftScene = false,
    this.lockTimePatientArrivedAtDestination = false,
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
  // TODO(FireJuun): find NEMSIS link for this
  final DateTime? timeOfStemiActivation;
  final bool lockTimeOfStemiActivation;

  /// The time the unit left the scene
  /// spec: https://nemsis.org/media/nemsis_v3/release-3.5.0/DataDictionary/PDFHTML/EMSDEMSTATE/sections/elements/eTimes.08.xml
  final DateTime? timeUnitLeftScene;
  final bool lockTimeUnitLeftScene;

  /// The time the patient arrived at the destination, such as a hospital
  /// https://nemsis.org/media/nemsis_v3/release-3.5.0/DataDictionary/PDFHTML/EMSDEMSTATE/sections/elements/eTimes.11.xml
  final DateTime? timePatientArrivedAtDestination;
  final bool lockTimePatientArrivedAtDestination;

  TimeMetricsModel copyWith({
    ValueGetter<DateTime?>? timeArrivedAtPatient,
    ValueGetter<Set<DateTime?>?>? timeOfEkgs,
    ValueGetter<DateTime?>? timeOfStemiActivation,
    ValueGetter<DateTime?>? timeUnitLeftScene,
    ValueGetter<DateTime?>? timePatientArrivedAtDestination,
    ValueGetter<bool>? lockTimeArrivedAtPatient,
    ValueGetter<bool>? lockTimeOfEkgs,
    ValueGetter<bool>? lockTimeOfStemiActivation,
    ValueGetter<bool>? lockTimeUnitLeftScene,
    ValueGetter<bool>? lockTimePatientArrivedAtDestination,
  }) {
    /// Sort EKGs by time they were performed.
    /// This is preferred when updating EKG info.
    final ekgs = timeOfEkgs != null ? timeOfEkgs() : this.timeOfEkgs;

    return TimeMetricsModel(
      timeArrivedAtPatient: timeArrivedAtPatient != null
          ? timeArrivedAtPatient()
          : this.timeArrivedAtPatient,
      timeOfEkgs: sortedEkgsByDateTime(ekgs),
      timeOfStemiActivation: timeOfStemiActivation != null
          ? timeOfStemiActivation()
          : this.timeOfStemiActivation,
      timeUnitLeftScene: timeUnitLeftScene != null
          ? timeUnitLeftScene()
          : this.timeUnitLeftScene,
      timePatientArrivedAtDestination: timePatientArrivedAtDestination != null
          ? timePatientArrivedAtDestination()
          : this.timePatientArrivedAtDestination,
      lockTimeArrivedAtPatient: lockTimeArrivedAtPatient != null
          ? lockTimeArrivedAtPatient()
          : this.lockTimeArrivedAtPatient,
      lockTimeOfEkgs:
          lockTimeOfEkgs != null ? lockTimeOfEkgs() : this.lockTimeOfEkgs,
      lockTimeOfStemiActivation: lockTimeOfStemiActivation != null
          ? lockTimeOfStemiActivation()
          : this.lockTimeOfStemiActivation,
      lockTimeUnitLeftScene: lockTimeUnitLeftScene != null
          ? lockTimeUnitLeftScene()
          : this.lockTimeUnitLeftScene,
      lockTimePatientArrivedAtDestination:
          lockTimePatientArrivedAtDestination != null
              ? lockTimePatientArrivedAtDestination()
              : this.lockTimePatientArrivedAtDestination,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'timeArrivedAtPatient': timeArrivedAtPatient?.millisecondsSinceEpoch,
      'timeOfEkgs': timeOfEkgs.map((x) => x?.millisecondsSinceEpoch).toList(),
      'timeOfStemiActivation': timeOfStemiActivation?.millisecondsSinceEpoch,
      'timeUnitLeftScene': timeUnitLeftScene?.millisecondsSinceEpoch,
      'timePatientArrivedAtDestination':
          timePatientArrivedAtDestination?.millisecondsSinceEpoch,
      'lockTimeArrivedAtPatient': lockTimeArrivedAtPatient,
      'lockTimeOfEkgs': lockTimeOfEkgs,
      'lockTimeOfStemiActivation': lockTimeOfStemiActivation,
      'lockTimeUnitLeftScene': lockTimeUnitLeftScene,
      'lockTimePatientArrivedAtDestination':
          lockTimePatientArrivedAtDestination,
    };
  }

  factory TimeMetricsModel.fromMap(Map<String, dynamic> map) {
    return TimeMetricsModel(
      timeArrivedAtPatient: map['timeArrivedAtPatient'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['timeArrivedAtPatient'] as int,
            )
          : null,
      timeOfEkgs: Set<DateTime?>.from(
        (map['timeOfEkgs'] as List<int>).map<DateTime?>(
          DateTime.fromMillisecondsSinceEpoch,
        ),
      ),
      timeOfStemiActivation: map['timeOfStemiActivation'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['timeOfStemiActivation'] as int,
            )
          : null,
      timeUnitLeftScene: map['timeUnitLeftScene'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timeUnitLeftScene'] as int)
          : null,
      timePatientArrivedAtDestination:
          map['timePatientArrivedAtDestination'] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  map['timePatientArrivedAtDestination'] as int,
                )
              : null,
      lockTimeArrivedAtPatient: map['lockTimeArrivedAtPatient'] as bool,
      lockTimeOfEkgs: map['lockTimeOfEkgs'] as bool,
      lockTimeOfStemiActivation: map['lockTimeOfStemiActivation'] as bool,
      lockTimeUnitLeftScene: map['lockTimeUnitLeftScene'] as bool,
      lockTimePatientArrivedAtDestination:
          map['lockTimePatientArrivedAtDestination'] as bool,
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
      timeOfEkgs,
      timeOfStemiActivation,
      timeUnitLeftScene,
      timePatientArrivedAtDestination,
      lockTimeArrivedAtPatient,
      lockTimeOfEkgs,
      lockTimeOfStemiActivation,
      lockTimeUnitLeftScene,
      lockTimePatientArrivedAtDestination,
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

  /// Tri-state boolean that checks for all data to be present,
  /// then checks to see if the time metric has been met.
  ///
  /// true -> data present and meets the 5 minute requirement
  /// null -> data present, but failed to meet the 5 minute requirement
  /// false -> no data present
  bool? hasEkgByFiveMin() {
    final timeArrived = timeArrivedAtPatient;
    final firstEkg = timeOfEkgs.firstOrNull;

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
}
