import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
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

    // Setup default behaviors
    when(() => mockController.setBirthDate(any())).thenAnswer((_) async {});
  });

  Widget createTestWidget({
    DateTime? initialBirthDate,
  }) {
    return ProviderScope(
      overrides: [
        patientInfoControllerProvider.overrideWith(() => mockController),
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

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.text('MM/DD/YYYY'), findsOneWidget);
      expect(find.byIcon(Icons.date_range), findsOneWidget);
    });

    testWidgets('should display initial birth date when provided',
        (tester) async {
      final initialDate = DateTime(1990, 5, 15);

      await tester.pumpWidget(
        createTestWidget(initialBirthDate: initialDate),
      );

      expect(find.text('05/15/1990'), findsOneWidget);
      
      // Should show age
      final age = DateTime.now().year - 1990;
      expect(find.textContaining('Age:'), findsOneWidget);
      expect(find.textContaining(age.toString()), findsOneWidget);
    });

    testWidgets('should format date input as MM/DD/YYYY', (tester) async {
      await tester.pumpWidget(createTestWidget());

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

      // Clear the field
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pumpAndSettle();

      verify(() => mockController.setBirthDate(null)).called(1);
    });

    testWidgets('should open date picker when calendar icon is tapped',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byIcon(Icons.date_range));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarDatePicker), findsOneWidget);
    });

    testWidgets('should update date when picker date is selected',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byIcon(Icons.date_range));
      await tester.pumpAndSettle();

      // Select a date (find the "15" day)
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      // Tap OK to confirm
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Should have called setBirthDate
      verify(() => mockController.setBirthDate(any())).called(1);
      
      // Should update text field
      final textField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(textField.controller?.text, contains('/15/'));
    });

    testWidgets('should not update when date picker is cancelled',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byIcon(Icons.date_range));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Should not have called setBirthDate
      verifyNever(() => mockController.setBirthDate(any()));
    });

    testWidgets('should show validation error for invalid date format',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Invalid month
      await tester.enterText(find.byType(TextFormField), '13152000');
      await tester.pumpAndSettle();

      // Trigger validation by finding the form and calling validate
      tester.state<FormState>(find.byType(Form)).validate();
      await tester.pumpAndSettle();

      expect(find.text('Invalid date format'), findsOneWidget);
    });

    testWidgets('should show validation error for future date',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      final futureDate = DateTime.now().add(const Duration(days: 1));
      final dateStr = DateFormat('MMddyyyy').format(futureDate);

      await tester.enterText(find.byType(TextFormField), dateStr);
      await tester.pumpAndSettle();

      // Trigger validation by finding the form and calling validate
      tester.state<FormState>(find.byType(Form)).validate();
      await tester.pumpAndSettle();

      expect(find.text("Can't be in the future"), findsOneWidget);
    });

    testWidgets('should show validation error for age too old',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField), '01011850'); // Too old
      await tester.pumpAndSettle();

      // Trigger validation by finding the form and calling validate
      tester.state<FormState>(find.byType(Form)).validate();
      await tester.pumpAndSettle();

      expect(find.text('Age too old'), findsOneWidget);
    });

    testWidgets('should not call setBirthDate for incomplete date',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

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

      final textField = find.byType(TextFormField);
      
      // Complete date should set a valid DateTime
      await tester.enterText(textField, '01/15/2000');
      await tester.pumpAndSettle();
      
      // Verify a DateTime was passed
      final captures = verify(() => mockController.setBirthDate(captureAny()))
          .captured;
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

  group('BirthDateEntryText Widget Tests', () {
    testWidgets('should display in read-only mode', (tester) async {
      final controller = TextEditingController(text: '01/15/2000');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BirthDateEntryText(
              birthDateController: controller,
              onChanged: (_) {},
              readOnly: true,
            ),
          ),
        ),
      );

      final textFieldFinder = find.byType(TextFormField);
      // The readOnly property affects behavior, not the widget itself
      // Try to enter text and verify it doesn't change
      const initialText = '01/15/2000';
      
      // Try to enter text
      await tester.enterText(textFieldFinder, 'test');
      // In read-only mode, the text should not change
      expect(controller.text, equals(initialText));
    });

    testWidgets('should show custom prefix icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BirthDateEntryText(
              birthDateController: TextEditingController(),
              onChanged: (_) {},
              prefixIcon: const Icon(Icons.person),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should validate empty field as valid', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: BirthDateEntryText(
                birthDateController: TextEditingController(),
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      final isValid = formKey.currentState?.validate() ?? false;
      expect(isValid, isTrue);
    });

    testWidgets('should call onChanged with parsed date', (tester) async {
      String? capturedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BirthDateEntryText(
              birthDateController: TextEditingController(),
              onChanged: (value) => capturedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '01152000');
      await tester.pumpAndSettle();

      expect(capturedValue, isNotNull);
      expect(capturedValue, contains('2000-01-15'));
    });

    testWidgets('should call onChanged with null for empty field',
        (tester) async {
      String? capturedValue = 'initial';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BirthDateEntryText(
              birthDateController: TextEditingController(text: '01/15/2000'),
              onChanged: (value) => capturedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '');
      await tester.pumpAndSettle();

      expect(capturedValue, isNull);
    });
  });
}
