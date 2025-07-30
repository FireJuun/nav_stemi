import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';

void main() {
  group('PriorEncountersDialog', () {
    testWidgets('displays dialog with correct structure', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PriorEncountersDialog(),
            ),
          ),
        ),
      );

      expect(find.byType(ResponsiveDialogWidget), findsOneWidget);
      expect(find.byType(ResponsiveDialogHeader), findsOneWidget);
      expect(find.byType(ResponsiveDialogFooter), findsOneWidget);
      expect(find.text('Prior Encounters'), findsOneWidget);
    });

    testWidgets('displays sync share session', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PriorEncountersDialog(),
            ),
          ),
        ),
      );

      expect(find.byType(SyncNotifyShareSession), findsOneWidget);
    });

    testWidgets('displays placeholder encounter items', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PriorEncountersDialog(),
            ),
          ),
        ),
      );

      // Check for encounter items
      expect(find.text('Prior STEMI Event 1'), findsOneWidget);
      expect(find.text('Prior STEMI Event 2'), findsOneWidget);
      expect(find.text('Prior STEMI Event 3'), findsOneWidget);

      // Check for IDs
      expect(find.text('ID: STEMI-10000'), findsOneWidget);
      expect(find.text('ID: STEMI-10001'), findsOneWidget);
      expect(find.text('ID: STEMI-10002'), findsOneWidget);
    });

    testWidgets('displays EHR icon and text', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PriorEncountersDialog(),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.folder_shared), findsNWidgets(3));
      expect(find.text('EHR'), findsNWidgets(3));
    });
  });

  group('PriorEncountersDialog interactions', () {
    testWidgets('displays ListTiles for encounters', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PriorEncountersDialog(),
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsNWidgets(3));
    });

    testWidgets('ListTiles have correct styling', (tester) async {
      final theme = ThemeData();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: theme,
            home: const Scaffold(
              body: PriorEncountersDialog(),
            ),
          ),
        ),
      );

      final listTile = tester.widget<ListTile>(find.byType(ListTile).first);
      expect(listTile.tileColor, theme.colorScheme.secondaryContainer);
      expect(listTile.textColor, theme.colorScheme.onSecondaryContainer);
    });

    testWidgets('ListTiles have rounded corners', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PriorEncountersDialog(),
            ),
          ),
        ),
      );

      final listTile = tester.widget<ListTile>(find.byType(ListTile).first);
      final shape = listTile.shape! as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(8));
    });

    testWidgets('displays time ago with correct pluralization', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PriorEncountersDialog(),
            ),
          ),
        ),
      );

      expect(find.text('1 week ago'), findsOneWidget);
      expect(find.text('2 weeks ago'), findsOneWidget);
      expect(find.text('3 weeks ago'), findsOneWidget);
    });

    testWidgets('time ago text has italic style', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PriorEncountersDialog(),
            ),
          ),
        ),
      );

      final timeAgoText = tester.widget<Text>(find.text('1 week ago'));
      expect(timeAgoText.style?.fontStyle, FontStyle.italic);
      expect(timeAgoText.textAlign, TextAlign.end);
    });

    testWidgets('has colored box with primary container color', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PriorEncountersDialog(),
            ),
          ),
        ),
      );

      // ColoredBox might be within other widgets
      final coloredBoxes =
          tester.widgetList<ColoredBox>(find.byType(ColoredBox));
      expect(coloredBoxes, isNotEmpty);

      // Check if any ColoredBox has primary container color
      final theme =
          Theme.of(tester.element(find.byType(PriorEncountersDialog)));
      final hasExpectedColor = coloredBoxes.any(
        (box) => box.color == theme.colorScheme.primaryContainer,
      );
      expect(hasExpectedColor, isTrue);
    });

    testWidgets('sync widget uses primary color', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PriorEncountersDialog(),
            ),
          ),
        ),
      );

      final syncWidget = tester.widget<SyncNotifyShareSession>(
        find.byType(SyncNotifyShareSession),
      );
      expect(syncWidget.usePrimaryColor, true);
    });

    testWidgets('encounter item can be tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PriorEncountersDialog(),
            ),
          ),
        ),
      );

      // Verify encounter items are tappable
      final firstEncounter = find.byType(ListTile).first;
      expect(firstEncounter, findsOneWidget);

      // Tap should not throw
      await tester.tap(firstEncounter);
      await tester.pump();
    });
  });
}
