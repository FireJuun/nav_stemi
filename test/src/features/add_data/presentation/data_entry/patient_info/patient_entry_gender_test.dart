import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Mock classes
class MockPatientInfoModel extends Mock implements PatientInfoModel {}

class MockPatientInfoController extends Mock implements PatientInfoController {}

void main() {
  group('PatientEntryGender', () {
    testWidgets('displays sex at birth label', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            patientInfoModelProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PatientEntryGender(),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Sex at Birth'), findsOneWidget);
    });

    testWidgets('displays segmented button with all sex options',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            patientInfoModelProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PatientEntryGender(),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(SegmentedButton<SexAtBirth?>), findsOneWidget);
      expect(find.text('male'), findsOneWidget);
      expect(find.text('female'), findsOneWidget);
    });

    testWidgets('shows selected sex when model has value', (tester) async {
      final mockPatientInfoModel = MockPatientInfoModel();
      when(() => mockPatientInfoModel.sexAtBirth).thenReturn(SexAtBirth.female);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            patientInfoModelProvider.overrideWith(
              (ref) => Stream.value(mockPatientInfoModel),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PatientEntryGender(),
            ),
          ),
        ),
      );

      await tester.pump();

      final segmentedButton = tester.widget<SegmentedButton<SexAtBirth?>>(
        find.byType(SegmentedButton<SexAtBirth?>),
      );
      expect(segmentedButton.selected, contains(SexAtBirth.female));
    });

    testWidgets('allows empty selection', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            patientInfoModelProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PatientEntryGender(),
            ),
          ),
        ),
      );

      await tester.pump();
      final segmentedButton = tester.widget<SegmentedButton<SexAtBirth?>>(
        find.byType(SegmentedButton<SexAtBirth?>),
      );
      expect(segmentedButton.emptySelectionAllowed, true);
    });

    testWidgets('does not show selected icon', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            patientInfoModelProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PatientEntryGender(),
            ),
          ),
        ),
      );

      await tester.pump();
      final segmentedButton = tester.widget<SegmentedButton<SexAtBirth?>>(
        find.byType(SegmentedButton<SexAtBirth?>),
      );
      expect(segmentedButton.showSelectedIcon, false);
    });

    testWidgets('has correct layout structure', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            patientInfoModelProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PatientEntryGender(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify Column structure
      expect(find.byType(Column), findsOneWidget);

      // Verify gapH4 is present
      expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
    });
  });
}
