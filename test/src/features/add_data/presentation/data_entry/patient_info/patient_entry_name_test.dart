import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

class MockPatientInfoController extends AutoDisposeAsyncNotifier<void>
    with Mock
    implements PatientInfoController {}

void main() {
  late MockPatientInfoController mockController;

  setUp(() {
    mockController = MockPatientInfoController();

    // Setup default mocks
    when(() => mockController.setFirstName(any())).thenReturn(null);
    when(() => mockController.setMiddleName(any())).thenReturn(null);
    when(() => mockController.setLastName(any())).thenReturn(null);
  });

  Widget createTestWidget({
    AsyncValue<PatientInfoModel?>? patientInfoValue,
  }) {
    return ProviderScope(
      overrides: [
        patientInfoControllerProvider.overrideWith(() => mockController),
        patientInfoModelProvider.overrideWith((ref) {
          final value = patientInfoValue ?? const AsyncValue.data(null);
          if (value.isLoading) {
            return const Stream.empty();
          } else if (value.hasError) {
            return Stream.error(value.error!, value.stackTrace);
          } else {
            return Stream.value(value.value);
          }
        }),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: PatientEntryName(),
        ),
      ),
    );
  }

  group('PatientEntryName', () {
    testWidgets('should display loading state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          patientInfoValue: const AsyncValue.loading(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          patientInfoValue: AsyncValue.error(
            Exception('Test error'),
            StackTrace.current,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Exception: Test error'), findsOneWidget);
    });

    testWidgets('should display three text fields when data is null',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          patientInfoValue: const AsyncValue.data(null),
        ),
      );
      await tester.pump();

      expect(find.byType(PatientEntryText), findsNWidgets(3));
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Middle Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
    });

    testWidgets('should display patient data when available', (tester) async {
      const patient = PatientInfoModel(
        firstName: 'John',
        middleName: 'Michael',
        lastName: 'Doe',
      );

      await tester.pumpWidget(
        createTestWidget(
          patientInfoValue: const AsyncValue.data(patient),
        ),
      );
      await tester.pump();

      // Find text fields with initial values
      final firstNameField = tester.widget<PatientEntryText>(
        find.widgetWithText(PatientEntryText, 'First Name'),
      );
      final middleNameField = tester.widget<PatientEntryText>(
        find.widgetWithText(PatientEntryText, 'Middle Name'),
      );
      final lastNameField = tester.widget<PatientEntryText>(
        find.widgetWithText(PatientEntryText, 'Last Name'),
      );

      expect(firstNameField.initialValue, 'John');
      expect(middleNameField.initialValue, 'Michael');
      expect(lastNameField.initialValue, 'Doe');
    });

    testWidgets('should call setFirstName when first name changes',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          patientInfoValue: const AsyncValue.data(null),
        ),
      );
      await tester.pump();

      final firstNameField = tester.widget<PatientEntryText>(
        find.widgetWithText(PatientEntryText, 'First Name'),
      );

      // Call the onChanged callback
      firstNameField.onChanged?.call('Jane');

      verify(() => mockController.setFirstName('Jane')).called(1);
    });

    testWidgets('should call setMiddleName when middle name changes',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          patientInfoValue: const AsyncValue.data(null),
        ),
      );
      await tester.pump();

      final middleNameField = tester.widget<PatientEntryText>(
        find.widgetWithText(PatientEntryText, 'Middle Name'),
      );

      // Call the onChanged callback
      middleNameField.onChanged?.call('Ann');

      verify(() => mockController.setMiddleName('Ann')).called(1);
    });

    testWidgets('should call setLastName when last name changes',
        (tester) async {
      when(() => mockController.setLastName(any())).thenAnswer((_) {});

      await tester.pumpWidget(
        createTestWidget(
          patientInfoValue: const AsyncValue.data(null),
        ),
      );
      await tester.pump();

      final lastNameField = tester.widget<PatientEntryText>(
        find.widgetWithText(PatientEntryText, 'Last Name'),
      );

      // Call the onChanged callback
      lastNameField.onChanged?.call('Smith');

      verify(() => mockController.setLastName('Smith')).called(1);
    });

    testWidgets('should layout fields in two rows', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          patientInfoValue: const AsyncValue.data(null),
        ),
      );
      await tester.pump();

      // Should have 2 Row widgets inside the Column
      expect(find.byType(Row), findsNWidgets(2));
    });

    testWidgets('should have padding on last name field', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          patientInfoValue: const AsyncValue.data(null),
        ),
      );
      await tester.pump();

      // Find the Padding widget that contains the last name field
      final paddingWidget = find.ancestor(
        of: find.widgetWithText(PatientEntryText, 'Last Name'),
        matching: find.byType(Padding),
      );

      expect(paddingWidget, findsOneWidget);

      final padding = tester.widget<Padding>(paddingWidget);
      expect(padding.padding, const EdgeInsets.symmetric(horizontal: 24));
    });

    testWidgets('should use Column layout', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          patientInfoValue: const AsyncValue.data(null),
        ),
      );
      await tester.pump();

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should use Expanded widgets for layout', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          patientInfoValue: const AsyncValue.data(null),
        ),
      );
      await tester.pump();

      // Should have 3 Expanded widgets (one for each text field)
      expect(find.byType(Expanded), findsNWidgets(3));
    });

    testWidgets('should handle partial patient data', (tester) async {
      const patient = PatientInfoModel(
        firstName: 'John',
        lastName: 'Doe',
        // middleName is null
      );

      await tester.pumpWidget(
        createTestWidget(
          patientInfoValue: const AsyncValue.data(patient),
        ),
      );
      await tester.pump();

      final firstNameField = tester.widget<PatientEntryText>(
        find.widgetWithText(PatientEntryText, 'First Name'),
      );
      final middleNameField = tester.widget<PatientEntryText>(
        find.widgetWithText(PatientEntryText, 'Middle Name'),
      );
      final lastNameField = tester.widget<PatientEntryText>(
        find.widgetWithText(PatientEntryText, 'Last Name'),
      );

      expect(firstNameField.initialValue, 'John');
      expect(middleNameField.initialValue, isNull);
      expect(lastNameField.initialValue, 'Doe');
    });
  });
}
