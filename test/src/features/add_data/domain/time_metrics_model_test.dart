import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/src/features/add_data/domain/time_metrics_model.dart';

void main() {
  group('TimeMetricsModel', () {
    final testDateTime = DateTime(2024, 1, 15, 10, 30);
    final ekgTime1 = testDateTime.add(const Duration(minutes: 5));
    final ekgTime2 = testDateTime.add(const Duration(minutes: 10));
    final testEkgTimes = {ekgTime1, ekgTime2};

    test('should create model with valid data', () {
      final model = TimeMetricsModel(
        timeArrivedAtPatient: testDateTime,
        lockTimeArrivedAtPatient: true,
        timeOfEkgs: testEkgTimes,
        timeOfStemiActivationDecision:
            testDateTime.add(const Duration(minutes: 15)),
        wasStemiActivated: true,
        isDirty: false,
      );

      expect(model.timeArrivedAtPatient, equals(testDateTime));
      expect(model.lockTimeArrivedAtPatient, isTrue);
      expect(model.timeOfEkgs, equals(testEkgTimes));
      expect(model.lockTimeOfEkgs, isFalse);
      expect(
        model.timeOfStemiActivationDecision,
        equals(testDateTime.add(const Duration(minutes: 15))),
      );
      expect(model.wasStemiActivated, isTrue);
      expect(model.isDirty, isFalse);
    });

    test('should create model with default values', () {
      const model = TimeMetricsModel();

      expect(model.timeArrivedAtPatient, isNull);
      expect(model.lockTimeArrivedAtPatient, isFalse);
      expect(model.timeOfEkgs, isEmpty);
      expect(model.lockTimeOfEkgs, isFalse);
      expect(model.timeOfStemiActivationDecision, isNull);
      expect(model.wasStemiActivated, isNull);
      expect(model.isDirty, isTrue); // Defaults to true
    });

    group('copyWith', () {
      test('should copy with new values', () {
        const original = TimeMetricsModel();

        final copied = original.copyWith(
          timeArrivedAtPatient: () => testDateTime,
          wasStemiActivated: () => true,
          timeOfEkgs: () => testEkgTimes,
        );

        expect(copied.timeArrivedAtPatient, equals(testDateTime));
        expect(copied.wasStemiActivated, isTrue);
        expect(copied.timeOfEkgs, equals(testEkgTimes));
        expect(copied.isDirty, isTrue); // Should be dirty after changes
      });

      test('should handle null values in copyWith', () {
        final original = TimeMetricsModel(
          timeArrivedAtPatient: testDateTime,
          wasStemiActivated: true,
          timeOfEkgs: testEkgTimes,
        );

        final copied = original.copyWith(
          timeArrivedAtPatient: () => null,
          wasStemiActivated: () => null,
        );

        expect(copied.timeArrivedAtPatient, isNull);
        expect(copied.wasStemiActivated, isNull);
        expect(copied.timeOfEkgs, equals(testEkgTimes));
      });
    });

    group('EKG sorting', () {
      test('should sort EKGs by time', () {
        final unsortedEkgs = {
          testDateTime.add(const Duration(minutes: 10)),
          testDateTime.add(const Duration(minutes: 5)),
          testDateTime.add(const Duration(minutes: 15)),
        };

        final model = TimeMetricsModel(
          timeOfEkgs: unsortedEkgs,
        );

        final sorted = model.sortedEkgsByDateTime();
        final sortedList = sorted.toList();

        expect(
          sortedList[0],
          equals(testDateTime.add(const Duration(minutes: 5))),
        );
        expect(
          sortedList[1],
          equals(testDateTime.add(const Duration(minutes: 10))),
        );
        expect(
          sortedList[2],
          equals(testDateTime.add(const Duration(minutes: 15))),
        );
      });

      test('should handle null values in EKG sorting', () {
        final ekgsWithNull = {
          null,
          testDateTime.add(const Duration(minutes: 10)),
          testDateTime.add(const Duration(minutes: 5)),
        };

        final model = TimeMetricsModel(
          timeOfEkgs: ekgsWithNull,
        );

        final sorted = model.sortedEkgsByDateTime();
        final sortedList = sorted.toList();

        expect(sortedList[0], isNull);
        expect(
          sortedList[1],
          equals(testDateTime.add(const Duration(minutes: 5))),
        );
        expect(
          sortedList[2],
          equals(testDateTime.add(const Duration(minutes: 10))),
        );
      });
    });

    group('Time metrics calculations', () {
      test('should return first EKG time', () {
        final model = TimeMetricsModel(
          timeOfEkgs: testEkgTimes,
        );

        expect(model.timeOfFirstEkg(), equals(ekgTime1));
      });

      test('should return null when no EKGs', () {
        const model = TimeMetricsModel();

        expect(model.timeOfFirstEkg(), isNull);
      });

      test('hasEkgByFiveMin should return true when within 5 minutes', () {
        final model = TimeMetricsModel(
          timeArrivedAtPatient: testDateTime,
          timeOfEkgs: {testDateTime.add(const Duration(minutes: 4))},
        );

        expect(model.hasEkgByFiveMin(), isTrue);
      });

      test('hasEkgByFiveMin should return null when exceeds 5 minutes', () {
        final model = TimeMetricsModel(
          timeArrivedAtPatient: testDateTime,
          timeOfEkgs: {testDateTime.add(const Duration(minutes: 6))},
        );

        expect(model.hasEkgByFiveMin(), isNull);
      });

      test('hasEkgByFiveMin should return false when data missing', () {
        const model = TimeMetricsModel();

        expect(model.hasEkgByFiveMin(), isFalse);
      });

      test('hasLeftByTenMin should return true when within 10 minutes', () {
        final model = TimeMetricsModel(
          timeArrivedAtPatient: testDateTime,
          timeUnitLeftScene: testDateTime.add(const Duration(minutes: 9)),
        );

        expect(model.hasLeftByTenMin(), isTrue);
      });

      test('hasLeftByTenMin should return null when exceeds 10 minutes', () {
        final model = TimeMetricsModel(
          timeArrivedAtPatient: testDateTime,
          timeUnitLeftScene: testDateTime.add(const Duration(minutes: 11)),
        );

        expect(model.hasLeftByTenMin(), isNull);
      });

      test('hasArrivedBySixtyMin should return true when within 60 minutes',
          () {
        final model = TimeMetricsModel(
          timeArrivedAtPatient: testDateTime,
          timePatientArrivedAtDestination:
              testDateTime.add(const Duration(minutes: 55)),
        );

        expect(model.hasArrivedBySixtyMin(), isTrue);
      });

      test('hasArrivedBySixtyMin should return null when exceeds 60 minutes',
          () {
        final model = TimeMetricsModel(
          timeArrivedAtPatient: testDateTime,
          timePatientArrivedAtDestination:
              testDateTime.add(const Duration(minutes: 65)),
        );

        expect(model.hasArrivedBySixtyMin(), isNull);
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final model = TimeMetricsModel(
          timeArrivedAtPatient: testDateTime,
          lockTimeArrivedAtPatient: true,
          timeOfEkgs: testEkgTimes,
          timeOfStemiActivationDecision:
              testDateTime.add(const Duration(minutes: 15)),
          wasStemiActivated: true,
          isDirty: false,
        );

        final map = model.toMap();

        expect(
          map['timeArrivedAtPatient'],
          equals(testDateTime.millisecondsSinceEpoch),
        );
        expect(map['lockTimeArrivedAtPatient'], isTrue);
        expect(
          map['timeOfEkgs'],
          equals(
            testEkgTimes.map((e) => e.millisecondsSinceEpoch).toList(),
          ),
        );
        expect(map['wasStemiActivated'], isTrue);
        expect(map['isDirty'], isFalse);
      });

      test('should handle null values in JSON', () {
        const model = TimeMetricsModel();

        final map = model.toMap();

        expect(map['timeArrivedAtPatient'], isNull);
        expect(map['timeOfEkgs'], isEmpty);
        expect(map['wasStemiActivated'], isNull);
        expect(map['isDirty'], isTrue);
      });
    });

    group('sync status', () {
      test('should mark as synced', () {
        const model = TimeMetricsModel();

        final synced = model.markSynced();

        expect(synced.isDirty, isFalse);
      });

      test('should mark as dirty', () {
        const model = TimeMetricsModel(
          isDirty: false,
        );

        final dirty = model.markDirty();

        expect(dirty.isDirty, isTrue);
      });
    });

    group('equality', () {
      test('should be equal when all fields are the same', () {
        final model1 = TimeMetricsModel(
          timeArrivedAtPatient: testDateTime,
          timeOfEkgs: testEkgTimes,
          wasStemiActivated: true,
        );

        final model2 = TimeMetricsModel(
          timeArrivedAtPatient: testDateTime,
          timeOfEkgs: testEkgTimes,
          wasStemiActivated: true,
        );

        expect(model1, equals(model2));
      });

      test('should not be equal when fields differ', () {
        final model1 = TimeMetricsModel(
          timeArrivedAtPatient: testDateTime,
          wasStemiActivated: true,
        );

        final model2 = TimeMetricsModel(
          timeArrivedAtPatient: testDateTime,
          wasStemiActivated: false,
        );

        expect(model1, isNot(equals(model2)));
      });
    });
  });
}
