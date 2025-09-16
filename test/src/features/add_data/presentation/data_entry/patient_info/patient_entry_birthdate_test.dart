import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Mock classes
class MockPatientInfoController extends AutoDisposeAsyncNotifier<void>
    with Mock
    implements PatientInfoController {
  @override
  FutureOr<void> build() => Future<void>.value();
}

void main() {
  late MockPatientInfoController mockController;

  setUp(() {
    mockController = MockPatientInfoController();
  });

  Widget createTestWidget({
    DateTime? initialBirthDate,
  }) {
    return ProviderScope(
      overrides: [
        patientInfoControllerProvider.overrideWith(() => mockController),
        patientInfoModelProvider
            .overrideWith((ref) => Stream.value(const PatientInfoModel())),
        if (initialBirthDate != null)
          patientBirthDateProvider.overrideWithValue(initialBirthDate),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: Center(
            child: PatientEntryBirthdate(),
          ),
        ),
      ),
    );
  }

  group('PatientEntryBirthdate Widget Tests', () {
    testWidgets('should display empty date field initially', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.byIcon(Icons.date_range), findsOneWidget);

      // Check that the text field is empty initially
      final textField =
          tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('should display initial birth date when provided',
        (tester) async {
      final initialDate = DateTime(1990, 5, 15);

      await tester.pumpWidget(
        createTestWidget(initialBirthDate: initialDate),
      );
      await tester.pumpAndSettle();

      // Check that the text field contains the formatted date
      final textField =
          tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.controller?.text, equals('05/15/1990'));

      // Should show age
      expect(find.textContaining('Age:'), findsOneWidget);
    });

    testWidgets('should format date input as MM/DD/YYYY', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '01152000');
      await tester.pumpAndSettle();

      final textField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(textField.controller?.text, equals('01/15/2000'));
    });

    testWidgets('should call setBirthDate when valid date is entered',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter a complete date with slashes (10 characters total)
      await tester.enterText(find.byType(TextFormField), '01/15/2000');
      await tester.pumpAndSettle();

      // Should call setBirthDate with the parsed date
      final captured = verify(() => mockController.setBirthDate(captureAny()))
          .captured
          .where((arg) => arg != null)
          .toList();

      expect(captured, isNotEmpty);
      final lastDate = captured.last;
      expect(lastDate, isA<DateTime>());
      if (lastDate is DateTime) {
        expect(lastDate.year, equals(2000));
        expect(lastDate.month, equals(1));
        expect(lastDate.day, equals(15));
      }
    });

    testWidgets('should call setBirthDate(null) when field is cleared',
        (tester) async {
      final initialDate = DateTime(1990, 5, 15);

      await tester.pumpWidget(
        createTestWidget(initialBirthDate: initialDate),
      );
      await tester.pumpAndSettle();

      // Clear the field
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pumpAndSettle();

      verify(() => mockController.setBirthDate(null)).called(1);
    });

    testWidgets('should open date picker when calendar icon is tapped',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.date_range));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarDatePicker), findsOneWidget);
    });

    testWidgets('should not update when date picker is cancelled',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.date_range));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Should not have called setBirthDate
      verifyNever(() => mockController.setBirthDate(any()));
    });

    testWidgets('should not call setBirthDate for incomplete date',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter incomplete date - the formatter will add slashes
      // '0115' becomes '01/15/' which is 7 characters
      await tester.enterText(find.byType(TextFormField), '0115');
      await tester.pumpAndSettle();

      // Since birthDate is already null and the input is incomplete,
      // the early return in onChanged prevents setBirthDate from being called
      verifyNever(() => mockController.setBirthDate(any()));
    });

    testWidgets('should handle partial date entry correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textField = find.byType(TextFormField);

      // Test that incomplete dates don't call setBirthDate
      // (since birthDate is already null)
      await tester.enterText(textField, '01');
      await tester.pumpAndSettle();

      // Should not call setBirthDate since birthDate is already null
      verifyNever(() => mockController.setBirthDate(any()));
    });

    testWidgets('should handle complete date entry with different formats',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textField = find.byType(TextFormField);

      // Complete date should set a valid DateTime
      await tester.enterText(textField, '01/15/2000');
      await tester.pumpAndSettle();

      // Verify a DateTime was passed
      final captures =
          verify(() => mockController.setBirthDate(captureAny())).captured;
      expect(captures, isNotEmpty);

      final dateCapture = captures.last;
      expect(dateCapture, isA<DateTime>());
      if (dateCapture is DateTime) {
        expect(dateCapture.year, equals(2000));
        expect(dateCapture.month, equals(1));
        expect(dateCapture.day, equals(15));
      }
    });

    testWidgets('should unfocus when tapping outside', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            patientInfoControllerProvider.overrideWith(() => mockController),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: GestureDetector(
                onTap: () {
                  // Unfocus when tapping outside
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: const Center(
                  child: PatientEntryBirthdate(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Focus the text field
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      // Verify it's focused (check if any widget has focus)
      expect(FocusManager.instance.primaryFocus, isNotNull);

      // Tap outside the text field (on the GestureDetector)
      // Use a point that's definitely outside the centered widget
      final size = tester.getSize(find.byType(Scaffold));
      await tester.tapAt(Offset(size.width - 10, 10));
      await tester.pumpAndSettle();

      // Should lose focus - the GestureDetector should have unfocused everything
      // Check that no text field has focus
      final editableTextState = tester.state<EditableTextState>(
        find.byType(EditableText).first,
      );
      expect(editableTextState.widget.focusNode.hasFocus, isFalse);
    });
  });
}
