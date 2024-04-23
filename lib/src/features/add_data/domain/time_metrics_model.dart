// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class TimeMetricsModel extends Equatable {
  const TimeMetricsModel({
    this.timeArrivedAtPatient,
    this.timeOfEkgs = const {},
    this.timeUnitLeftScene,
    this.timePatientArrivedAtDestination,
  });

  /// KEY start time of first medical contact
  /// The time the unit arrived at the patient's side
  /// spec: https://nemsis.org/media/nemsis_v3/release-3.5.0/DataDictionary/PDFHTML/EMSDEMSTATE/sections/elements/eTimes.07.xml
  final DateTime? timeArrivedAtPatient;

  /// For now, the timestamps when EKGs are performed
  /// It is possible to expand this data model to include more values
  /// from the eVitals.CardiacRhythmGroup section of the NEMSIS data dictionary
  /// spec: https://nemsis.org/media/nemsis_v3/release-3.5.0/DataDictionary/PDFHTML/EMSDEMSTATE/sections/eVitals.002.xml
  final Set<DateTime?> timeOfEkgs;

  /// The time the unit left the scene
  /// spec: https://nemsis.org/media/nemsis_v3/release-3.5.0/DataDictionary/PDFHTML/EMSDEMSTATE/sections/elements/eTimes.08.xml
  final DateTime? timeUnitLeftScene;

  /// The time the patient arrived at the destination, such as a hospital
  /// https://nemsis.org/media/nemsis_v3/release-3.5.0/DataDictionary/PDFHTML/EMSDEMSTATE/sections/elements/eTimes.11.xml
  final DateTime? timePatientArrivedAtDestination;

  TimeMetricsModel copyWith({
    ValueGetter<DateTime?>? timeArrivedAtPatient,
    ValueGetter<Set<DateTime?>>? timeOfEkgs,
    ValueGetter<DateTime?>? timeUnitLeftScene,
    ValueGetter<DateTime?>? timePatientArrivedAtDestination,
  }) {
    return TimeMetricsModel(
      timeArrivedAtPatient: timeArrivedAtPatient != null
          ? timeArrivedAtPatient()
          : this.timeArrivedAtPatient,
      timeOfEkgs: timeOfEkgs != null ? timeOfEkgs() : this.timeOfEkgs,
      timeUnitLeftScene: timeUnitLeftScene != null
          ? timeUnitLeftScene()
          : this.timeUnitLeftScene,
      timePatientArrivedAtDestination: timePatientArrivedAtDestination != null
          ? timePatientArrivedAtDestination()
          : this.timePatientArrivedAtDestination,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'timeArrivedAtPatient': timeArrivedAtPatient?.millisecondsSinceEpoch,
      'timeOfEkgs': timeOfEkgs.map((x) => x?.millisecondsSinceEpoch).toList(),
      'timeUnitLeftScene': timeUnitLeftScene?.millisecondsSinceEpoch,
      'timePatientArrivedAtDestination':
          timePatientArrivedAtDestination?.millisecondsSinceEpoch,
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
      timeUnitLeftScene: map['timeUnitLeftScene'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timeUnitLeftScene'] as int)
          : null,
      timePatientArrivedAtDestination:
          map['timePatientArrivedAtDestination'] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  map['timePatientArrivedAtDestination'] as int,
                )
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TimeMetricsModel.fromJson(String source) =>
      TimeMetricsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
        timeArrivedAtPatient,
        timeOfEkgs,
        timeUnitLeftScene,
        timePatientArrivedAtDestination,
      ];
}
