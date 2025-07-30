import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';

void main() {
  group('PrimaryLoadingButton', () {
    Widget createTestWidget({
      required String text,
      bool isLoading = false,
      VoidCallback? onPressed,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: PrimaryLoadingButton(
              text: text,
              isLoading: isLoading,
              onPressed: onPressed,
            ),
          ),
        ),
      );
    }

    testWidgets('should display text when not loading', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          text: 'Click Me',
          onPressed: () {},
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should display loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          text: 'Click Me',
          isLoading: true,
          onPressed: () {},
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Click Me'), findsNothing);
    });

    testWidgets('should be disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          text: 'Click Me',
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should be enabled when onPressed is provided', (tester) async {
      var wasPressed = false;
      await tester.pumpWidget(
        createTestWidget(
          text: 'Click Me',
          onPressed: () => wasPressed = true,
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);

      await tester.tap(find.byType(ElevatedButton));
      expect(wasPressed, isTrue);
    });

    testWidgets('should center align text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          text: 'Click Me',
          onPressed: () {},
        ),
      );

      final text = tester.widget<Text>(find.text('Click Me'));
      expect(text.textAlign, TextAlign.center);
    });

    testWidgets('should be able to tap when not loading', (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        createTestWidget(
          text: 'Click Me',
          onPressed: () => tapCount++,
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(tapCount, 1);

      await tester.tap(find.byType(ElevatedButton));
      expect(tapCount, 2);
    });

    testWidgets('should still be tappable when loading if onPressed is set',
        (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        createTestWidget(
          text: 'Click Me',
          isLoading: true,
          onPressed: () => tapCount++,
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(tapCount, 1);
    });

    testWidgets('should handle long text correctly', (tester) async {
      const longText = 'This is a very long button text that might wrap';
      await tester.pumpWidget(
        createTestWidget(
          text: longText,
          onPressed: () {},
        ),
      );

      expect(find.text(longText), findsOneWidget);
    });

    testWidgets('should be of type ElevatedButton', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          text: 'Click Me',
          onPressed: () {},
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('loading indicator should be a child of button',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          text: 'Click Me',
          isLoading: true,
          onPressed: () {},
        ),
      );

      // Verify CircularProgressIndicator is a descendant of ElevatedButton
      expect(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
    });
  });
}
