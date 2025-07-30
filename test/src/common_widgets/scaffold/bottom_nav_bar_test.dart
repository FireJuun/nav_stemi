import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';

void main() {
  group('BottomNavBar', () {
    Widget createTestWidget({
      required int selectedIndex,
      required ValueChanged<int> onDestinationSelected,
    }) {
      return MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BottomNavBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
          ),
        ),
      );
    }

    testWidgets('should display two navigation items', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      expect(find.text('Go'), findsOneWidget);
      expect(find.text('Add Data'), findsOneWidget);
      expect(find.byIcon(Icons.navigation), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('should highlight selected item', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedIndex: 1,
          onDestinationSelected: (_) {},
        ),
      );

      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.currentIndex, 1);
    });

    testWidgets('should call onDestinationSelected when item tapped',
        (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(
        createTestWidget(
          selectedIndex: 0,
          onDestinationSelected: (index) => tappedIndex = index,
        ),
      );

      await tester.tap(find.text('Add Data'));
      expect(tappedIndex, 1);

      await tester.tap(find.text('Go'));
      expect(tappedIndex, 0);
    });

    testWidgets('should use shifting type', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.type, BottomNavigationBarType.shifting);
    });

    testWidgets('should show unselected labels', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.showUnselectedLabels, isTrue);
    });

    testWidgets('should apply correct font sizes', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.selectedFontSize, 24);
      expect(bottomNav.unselectedFontSize, 16);
    });

    testWidgets('should apply theme colors', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      final theme = Theme.of(tester.element(find.byType(BottomNavigationBar)));
      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );

      expect(bottomNav.selectedItemColor, theme.colorScheme.onPrimary);

      // Check background colors for items
      expect(bottomNav.items[0].backgroundColor, theme.colorScheme.primary);
      expect(bottomNav.items[1].backgroundColor, theme.colorScheme.secondary);
    });

    testWidgets('should have correct number of items', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.items.length, 2);
    });

    testWidgets('should handle tap on already selected item', (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        createTestWidget(
          selectedIndex: 0,
          onDestinationSelected: (_) => tapCount++,
        ),
      );

      // Tap the already selected item
      await tester.tap(find.text('Go'));
      expect(tapCount, 1);
    });
  });
}
