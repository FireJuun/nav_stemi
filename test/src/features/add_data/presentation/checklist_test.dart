import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Mock classes
class MockTimeMetricsModel extends Mock implements TimeMetricsModel {}

class MockPatientInfoModel extends Mock implements PatientInfoModel {}

void main() {
  group('Checklist', () {
    testWidgets('displays STEMI Checklist header', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Checklist(),
            ),
          ),
        ),
      );

      expect(find.text('STEMI Checklist'), findsOneWidget);
    });

    testWidgets('displays all checklist items when data is available',
        (tester) async {
      final mockTimeMetricsModel = MockTimeMetricsModel();
      final mockPatientInfoModel = MockPatientInfoModel();

      when(mockTimeMetricsModel.hasEkgByFiveMin).thenReturn(true);
      when(mockTimeMetricsModel.hasLeftByTenMin).thenReturn(false);
      when(mockPatientInfoModel.patientInfoChecklistState).thenReturn(true);
      when(mockPatientInfoModel.cardiologistInfoChecklistState)
          .thenReturn(false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timeMetricsModelProvider.overrideWith(
              (ref) => Stream.value(mockTimeMetricsModel),
            ),
            patientInfoModelProvider.overrideWith(
              (ref) => Stream.value(mockPatientInfoModel),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Checklist(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('EKG by 5 min'), findsOneWidget);
      expect(find.text('Leave by 10 min'), findsOneWidget);
      expect(find.text('Pt Info'), findsOneWidget);
      expect(find.text('Pt Cardiologist'), findsOneWidget);
    });

    testWidgets('shows loading state when data is loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timeMetricsModelProvider.overrideWith(
              (ref) => const Stream.empty(),
            ),
            patientInfoModelProvider.overrideWith(
              (ref) => const Stream.empty(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Checklist(),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('displays error message when data fails to load',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timeMetricsModelProvider.overrideWith(
              (ref) => Stream.error(Exception('Failed to load')),
            ),
            patientInfoModelProvider.overrideWith(
              (ref) => Stream.error(Exception('Failed to load')),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Checklist(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.textContaining('Failed to load'), findsAtLeastNWidgets(1));
    });

    testWidgets('handles null time metrics model', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timeMetricsModelProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
            patientInfoModelProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Checklist(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should display checklist items with null state
      expect(find.text('EKG by 5 min'), findsOneWidget);
      expect(find.text('Leave by 10 min'), findsOneWidget);
    });

    testWidgets('uses Card widget as container', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Checklist(),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('uses CustomScrollView with slivers', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Checklist(),
            ),
          ),
        ),
      );

      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(SliverPinnedHeader), findsOneWidget);
      expect(find.byType(SliverCrossAxisGroup), findsOneWidget);
    });
  });

  group('ChecklistItem', () {
    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChecklistItem(
              label: 'Test Item',
              isSelected: () => false,
            ),
          ),
        ),
      );

      expect(find.text('Test Item'), findsOneWidget);
    });

    testWidgets('shows checkbox with correct value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChecklistItem(
              label: 'Test Item',
              isSelected: () => true,
            ),
          ),
        ),
      );

      final checkbox =
          tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
      expect(checkbox.value, true);
    });

    testWidgets('applies strikethrough style when selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChecklistItem(
              label: 'Test Item',
              isSelected: () => true,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Test Item'));
      expect(text.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('applies different colors based on selection state',
        (tester) async {
      final theme = ThemeData();

      // Test selected (true) state
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: ChecklistItem(
              label: 'Test Item',
              isSelected: () => true,
            ),
          ),
        ),
      );

      var text = tester.widget<Text>(find.text('Test Item'));
      expect(text.style?.color, theme.colorScheme.outline);

      // Test unselected (false) state
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: ChecklistItem(
              label: 'Test Item',
              isSelected: () => false,
            ),
          ),
        ),
      );

      text = tester.widget<Text>(find.text('Test Item'));
      expect(text.style?.color, theme.colorScheme.onSurface);

      // Test null state
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: ChecklistItem(
              label: 'Test Item',
              isSelected: () => null,
            ),
          ),
        ),
      );

      text = tester.widget<Text>(find.text('Test Item'));
      expect(text.style?.color, theme.colorScheme.error);
    });

    testWidgets('calls onChanged when checkbox is tapped', (tester) async {
      bool? capturedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChecklistItem(
              label: 'Test Item',
              isSelected: () => false,
              onChanged: (value) => capturedValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CheckboxListTile));
      expect(capturedValue, true);
    });

    testWidgets('disables checkbox when onChanged is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChecklistItem(
              label: 'Test Item',
              isSelected: () => false,
            ),
          ),
        ),
      );

      final checkbox =
          tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
      expect(checkbox.enabled, false);
    });

    testWidgets('enables checkbox when onChanged is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChecklistItem(
              label: 'Test Item',
              isSelected: () => false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final checkbox =
          tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
      expect(checkbox.enabled, true);
    });

    testWidgets('uses tristate checkbox', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChecklistItem(
              label: 'Test Item',
              isSelected: () => null,
            ),
          ),
        ),
      );

      final checkbox =
          tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
      expect(checkbox.tristate, true);
      expect(checkbox.value, null);
    });

    testWidgets('handles null isSelected callback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChecklistItem(
              label: 'Test Item',
            ),
          ),
        ),
      );

      final checkbox =
          tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
      expect(checkbox.value, null);
    });

    testWidgets('uses compact visual density', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChecklistItem(
              label: 'Test Item',
              isSelected: () => false,
            ),
          ),
        ),
      );

      final checkbox =
          tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
      expect(checkbox.visualDensity, VisualDensity.compact);
    });

    testWidgets('positions checkbox as leading control', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChecklistItem(
              label: 'Test Item',
              isSelected: () => false,
            ),
          ),
        ),
      );

      final checkbox =
          tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
      expect(checkbox.controlAffinity, ListTileControlAffinity.leading);
    });
  });
}
