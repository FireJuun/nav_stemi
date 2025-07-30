import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';

void main() {
  group('EmptyPlaceholderWidget', () {
    Widget createTestWidget({
      required String message,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: EmptyPlaceholderWidget(
            message: message,
          ),
        ),
      );
    }

    testWidgets('should display the provided message', (tester) async {
      const testMessage = 'No items found';
      await tester.pumpWidget(createTestWidget(message: testMessage));

      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('should display Go Home button', (tester) async {
      await tester.pumpWidget(createTestWidget(message: 'Test message'));

      expect(find.text('Go Home'), findsOneWidget);
      expect(find.byType(PrimaryLoadingButton), findsOneWidget);
    });

    testWidgets('should apply correct text style to message', (tester) async {
      await tester.pumpWidget(createTestWidget(message: 'Test message'));

      final text = tester.widget<Text>(find.text('Test message'));
      final theme = Theme.of(tester.element(find.text('Test message')));
      expect(text.style, theme.textTheme.headlineMedium);
    });

    testWidgets('should center align the message text', (tester) async {
      await tester.pumpWidget(createTestWidget(message: 'Test message'));

      final text = tester.widget<Text>(find.text('Test message'));
      expect(text.textAlign, TextAlign.center);
    });

    testWidgets('should have correct padding', (tester) async {
      await tester.pumpWidget(createTestWidget(message: 'Test message'));

      final padding = tester.widget<Padding>(
        find.ancestor(
          of: find.byType(Center),
          matching: find.byType(Padding),
        ),
      );
      expect(padding.padding, const EdgeInsets.all(Sizes.p16));
    });

    testWidgets('should have column with min main axis size', (tester) async {
      await tester.pumpWidget(createTestWidget(message: 'Test message'));

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisSize, MainAxisSize.min);
    });

    testWidgets('should have gap between message and button', (tester) async {
      await tester.pumpWidget(createTestWidget(message: 'Test message'));

      // Check that gapH32 is present between message and button
      final column = tester.widget<Column>(find.byType(Column));
      expect(column.children.length, 3); // message, gap, button
      expect(column.children[1], isA<SizedBox>());

      final gap = column.children[1] as SizedBox;
      expect(gap.height, Sizes.p32);
    });

    testWidgets('should handle long messages correctly', (tester) async {
      const longMessage = 'This is a very long message that might need to wrap '
          'across multiple lines when displayed on smaller screens';
      await tester.pumpWidget(createTestWidget(message: longMessage));

      expect(find.text(longMessage), findsOneWidget);

      // Verify the text widget can handle multiline
      final text = tester.widget<Text>(find.text(longMessage));
      expect(text.maxLines, isNull); // No max lines limit
    });

    testWidgets('button onPressed callback is defined', (tester) async {
      await tester.pumpWidget(createTestWidget(message: 'Test message'));

      final button = tester.widget<PrimaryLoadingButton>(
        find.byType(PrimaryLoadingButton),
      );

      // The button should have an onPressed callback defined
      expect(button.onPressed, isNotNull);
    });

    testWidgets('should render correctly with different screen sizes',
        (tester) async {
      // Test with small screen
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget(message: 'Test message'));

      expect(find.text('Test message'), findsOneWidget);
      expect(find.text('Go Home'), findsOneWidget);

      // Test with large screen
      tester.view.physicalSize = const Size(768, 1024);

      await tester.pumpWidget(createTestWidget(message: 'Test message'));

      expect(find.text('Test message'), findsOneWidget);
      expect(find.text('Go Home'), findsOneWidget);

      // Reset to default
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
