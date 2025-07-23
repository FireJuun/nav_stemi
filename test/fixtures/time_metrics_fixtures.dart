import 'package:nav_stemi/src/features/add_data/domain/time_metrics_model.dart';

// Test time metrics data
final testDateTime = DateTime(2024, 1, 15, 10, 30);
final testEkgTimes = {
  testDateTime.add(const Duration(minutes: 5)),
  testDateTime.add(const Duration(minutes: 10)),
};

final testTimeMetrics = TimeMetricsModel(
  timeArrivedAtPatient: testDateTime,
  timeOfEkgs: testEkgTimes,
  timeOfStemiActivationDecision: testDateTime.add(const Duration(minutes: 15)),
  wasStemiActivated: true,
  timeUnitLeftScene: testDateTime.add(const Duration(minutes: 20)),
  timeOfAspirinGivenDecision: testDateTime.add(const Duration(minutes: 8)),
  wasAspirinGiven: true,
  timeCathLabNotifiedDecision: testDateTime.add(const Duration(minutes: 12)),
  wasCathLabNotified: true,
  timePatientArrivedAtDestination:
      testDateTime.add(const Duration(minutes: 45)),
  isDirty: false,
);

const testTimeMetricsIncomplete = TimeMetricsModel();

// JSON test data
final testTimeMetricsJson = {
  'timeArrivedAtPatient': testDateTime.millisecondsSinceEpoch,
  'lockTimeArrivedAtPatient': false,
  'timeOfEkgs': testEkgTimes.map((e) => e.millisecondsSinceEpoch).toList(),
  'lockTimeOfEkgs': false,
  'timeOfStemiActivationDecision':
      testDateTime.add(const Duration(minutes: 15)).millisecondsSinceEpoch,
  'wasStemiActivated': true,
  'lockTimeOfStemiActivationDecision': false,
  'timeUnitLeftScene':
      testDateTime.add(const Duration(minutes: 20)).millisecondsSinceEpoch,
  'lockTimeUnitLeftScene': false,
  'timeOfAspirinGivenDecision':
      testDateTime.add(const Duration(minutes: 8)).millisecondsSinceEpoch,
  'wasAspirinGiven': true,
  'lockTimeOfAspirinGivenDecision': false,
  'timeCathLabNotifiedDecision':
      testDateTime.add(const Duration(minutes: 12)).millisecondsSinceEpoch,
  'wasCathLabNotified': true,
  'lockTimeCathLabNotifiedDecision': false,
  'timePatientArrivedAtDestination':
      testDateTime.add(const Duration(minutes: 45)).millisecondsSinceEpoch,
  'lockTimePatientArrivedAtDestination': false,
  'isDirty': false,
};
