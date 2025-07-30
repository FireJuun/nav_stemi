import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';

void main() {
  group('ResponsiveDialogWidget', () {
    Widget createTestWidget({
      required Widget child,
      bool denseHeight = false,
      Size? screenSize,
    }) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: screenSize ?? const Size(400, 800),
          ),
          child: Scaffold(
            body: Center(
              child: ResponsiveDialogWidget(
                denseHeight: denseHeight,
                child: child,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('should render with rounded corners', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const Text('Test Content'),
        ),
      );

      final dialog = tester.widget<Dialog>(find.byType(Dialog));
      final roundedShape = dialog.shape! as RoundedRectangleBorder;
      expect(roundedShape.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('should apply background color', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const Text('Test Content'),
        ),
      );

      final dialog = tester.widget<Dialog>(find.byType(Dialog));
      expect(dialog.backgroundColor, const Color(0xFFFFEBE7));
    });
  });

  group('ResponsiveDialogHeader', () {
    Widget createTestWidget(String label) {
      return MaterialApp(
        home: Scaffold(
          body: ResponsiveDialogHeader(label: label),
        ),
      );
    }

    testWidgets('should display label', (tester) async {
      await tester.pumpWidget(createTestWidget('Test Header'));

      expect(find.text('Test Header'), findsOneWidget);
    });

    testWidgets('should display close button', (tester) async {
      await tester.pumpWidget(createTestWidget('Test Header'));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should apply header background color', (tester) async {
      await tester.pumpWidget(createTestWidget('Test Header'));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ResponsiveDialogHeader),
          matching: find.byType(Container).first,
        ),
      );
      expect(container.color, const Color(0xFFB8B8D1));
    });

    testWidgets('should pop navigation when close pressed', (tester) async {
      var popped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                        body: PopScope(
                          onPopInvokedWithResult: (_, __) async {
                            popped = true;
                          },
                          child: const ResponsiveDialogHeader(label: 'Test'),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });
  });

  group('ResponsiveDialogFooter', () {
    Widget createTestWidget({
      String? label,
      bool includeAccept = false,
      VoidCallback? onAccept,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ResponsiveDialogFooter(
            label: label,
            includeAccept: includeAccept,
            onAccept: onAccept,
          ),
        ),
      );
    }

    testWidgets('should display default cancel label', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should display custom label', (tester) async {
      await tester.pumpWidget(createTestWidget(label: 'Close'));

      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('should show accept button when included', (tester) async {
      await tester.pumpWidget(createTestWidget(includeAccept: true));

      expect(find.text('Accept'), findsOneWidget);
    });

    testWidgets('should not show accept button when not included',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Accept'), findsNothing);
    });

    testWidgets('should call onAccept when accept button pressed',
        (tester) async {
      var acceptCalled = false;
      await tester.pumpWidget(
        createTestWidget(
          includeAccept: true,
          onAccept: () => acceptCalled = true,
        ),
      );

      await tester.tap(find.text('Accept'));
      await tester.pump();

      expect(acceptCalled, isTrue);
    });

    testWidgets('should disable accept button when onAccept is null',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          includeAccept: true,
        ),
      );

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Accept'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('should pop navigation when cancel pressed', (tester) async {
      var popped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                        body: PopScope(
                          onPopInvokedWithResult: (_, __) async {
                            popped = true;
                          },
                          child: const ResponsiveDialogFooter(),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });

    testWidgets('should apply secondary color background', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final theme = Theme.of(
        tester.element(find.byType(ResponsiveDialogFooter)),
      );
      final coloredBox = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(ResponsiveDialogFooter),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(coloredBox.color, theme.colorScheme.secondary);
    });

    testWidgets('should display divider', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Divider), findsOneWidget);
      final divider = tester.widget<Divider>(find.byType(Divider));
      expect(divider.thickness, 2);
    });
  });
}
