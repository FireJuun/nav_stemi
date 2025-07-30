import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';

void main() {
  group('PrimaryToggleButton', () {
    Widget createTestWidget({
      required String text,
      bool isActive = false,
      VoidCallback? onPressed,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: PrimaryToggleButton(
              text: text,
              isActive: isActive,
              onPressed: onPressed,
            ),
          ),
        ),
      );
    }

    testWidgets('should display OutlinedButton when inactive', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          text: 'Toggle Me',
          onPressed: () {},
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
      expect(find.text('Toggle Me'), findsOneWidget);
    });

    testWidgets('should display FilledButton when active', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          text: 'Toggle Me',
          isActive: true,
          onPressed: () {},
        ),
      );

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.text('Toggle Me'), findsOneWidget);
    });

    testWidgets('should animate between states', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          text: 'Toggle Me',
          onPressed: () {},
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);

      // Change to active state
      await tester.pumpWidget(
        createTestWidget(
          text: 'Toggle Me',
          isActive: true,
          onPressed: () {},
        ),
      );

      // During animation both widgets exist
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(AnimatedSwitcher), findsOneWidget);

      // After animation completes
      await tester.pumpAndSettle();
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('should be disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          text: 'Toggle Me',
        ),
      );

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should handle tap when enabled', (tester) async {
      var wasTapped = false;
      await tester.pumpWidget(
        createTestWidget(
          text: 'Toggle Me',
          onPressed: () => wasTapped = true,
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      expect(wasTapped, isTrue);
    });
  });
}
