import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Simple test implementation without complex mocking
void main() {
  Widget createTestWidget({
    required Widget child,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('GoToDialog', () {
    testWidgets('displays dialog structure correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GoToDialog(),
        ),
      );

      expect(find.byType(ResponsiveDialogWidget), findsOneWidget);
      expect(find.byType(ResponsiveDialogHeader), findsOneWidget);
      expect(find.text('Go'), findsOneWidget);
      expect(find.byType(ListEDOptions), findsOneWidget);
      expect(find.byType(ResponsiveDialogFooter), findsOneWidget);
    });

    testWidgets('GoToDialog renders with all components', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GoToDialog(),
        ),
      );

      // Check dialog structure - there may be multiple Centers in the widget tree
      expect(find.byType(Center), findsWidgets);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Expanded), findsOneWidget);
    });
  });

  group('ListEDOptions', () {
    testWidgets('ListEDOptions widget exists', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const ListEDOptions(),
        ),
      );

      expect(find.byType(ListEDOptions), findsOneWidget);
    });

    testWidgets('ListEDOptions is a ConsumerWidget', (tester) async {
      expect(const ListEDOptions(), isA<ConsumerWidget>());
    });
  });

  group('Hospital Domain Objects', () {
    test('NearbyHospital can be created', () {
      const hospital = NearbyHospital(
        distanceBetween: 5000, // 5km
        routeDistance: 5000,
        routeDuration: '10 min',
        hospitalInfo: Hospital(
          facilityBrandedName: 'Test Hospital',
          facilityAddress: '123 Test St',
          facilityCity: 'Test City',
          facilityState: 'TS',
          facilityZip: 12345,
          latitude: 0,
          longitude: 0,
          county: 'Test County',
          source: 'Test',
          facilityPhone1: '123-456-7890',
          distanceToAsheboro: 10,
          pciCenter: 0,
        ),
      );

      expect(hospital.distanceBetween, 5000);
      expect(hospital.routeDuration, '10 min');
      expect(hospital.hospitalInfo.facilityBrandedName, 'Test Hospital');
    });

    test('Hospital isPci method works correctly', () {
      const pciHospital = Hospital(
        facilityBrandedName: 'PCI Hospital',
        facilityAddress: '123 Test St',
        facilityCity: 'Test City',
        facilityState: 'TS',
        facilityZip: 12345,
        latitude: 0,
        longitude: 0,
        county: 'Test County',
        source: 'Test',
        facilityPhone1: '123-456-7890',
        distanceToAsheboro: 10,
        pciCenter: 1,
      );

      const regularHospital = Hospital(
        facilityBrandedName: 'Regular Hospital',
        facilityAddress: '123 Test St',
        facilityCity: 'Test City',
        facilityState: 'TS',
        facilityZip: 12345,
        latitude: 0,
        longitude: 0,
        county: 'Test County',
        source: 'Test',
        facilityPhone1: '123-456-7890',
        distanceToAsheboro: 10,
        pciCenter: 0,
      );

      expect(pciHospital.isPci(), true);
      expect(regularHospital.isPci(), false);
    });

    test('NearbyHospitals can hold multiple hospitals', () {
      const waypoint1 = AppWaypoint(latitude: 0, longitude: 0);
      const waypoint2 = AppWaypoint(latitude: 1, longitude: 1);

      const hospital1 = NearbyHospital(
        distanceBetween: 5000,
        routeDistance: 5000,
        routeDuration: '10 min',
        hospitalInfo: Hospital(
          facilityBrandedName: 'Hospital 1',
          facilityAddress: '123 Test St',
          facilityCity: 'Test City',
          facilityState: 'TS',
          facilityZip: 12345,
          latitude: 0,
          longitude: 0,
          county: 'Test County',
          source: 'Test',
          facilityPhone1: '123-456-7890',
          distanceToAsheboro: 10,
          pciCenter: 0,
        ),
      );

      final nearbyHospitals = NearbyHospitals(
        items: {
          waypoint1: hospital1,
        },
      );

      expect(nearbyHospitals.items.length, 1);
      expect(nearbyHospitals.items[waypoint1], hospital1);
    });
  });

  group('Widget Integration', () {
    testWidgets('GoToDialog integrates with ListEDOptions', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GoToDialog(),
        ),
      );

      // Verify the hierarchy
      expect(
        find.descendant(
          of: find.byType(GoToDialog),
          matching: find.byType(ListEDOptions),
        ),
        findsOneWidget,
      );
    });

    testWidgets('ResponsiveDialogWidget contains expected structure',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GoToDialog(),
        ),
      );

      // Check responsive dialog contains header, content, and footer
      final dialogWidget = find.byType(ResponsiveDialogWidget);
      expect(dialogWidget, findsOneWidget);

      expect(
        find.descendant(
          of: dialogWidget,
          matching: find.byType(ResponsiveDialogHeader),
        ),
        findsOneWidget,
      );

      expect(
        find.descendant(
          of: dialogWidget,
          matching: find.byType(ResponsiveDialogFooter),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Dialog displays Go text in header', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GoToDialog(),
        ),
      );

      // Find Go text within the header
      expect(
        find.descendant(
          of: find.byType(ResponsiveDialogHeader),
          matching: find.text('Go'),
        ),
        findsOneWidget,
      );
    });
  });

  group('Edge Cases', () {
    testWidgets('handles empty NearbyHospitals', (tester) async {
      // Create empty hospitals list
      final Widget testWidget = ProviderScope(
        overrides: [
          nearbyHospitalsProvider.overrideWith(
            (ref) async => const NearbyHospitals(items: {}),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ListEDOptions(),
          ),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump(); // Let the future complete

      // Should render without crashing
      expect(find.byType(ListEDOptions), findsOneWidget);
    });
  });

  group('UI Components', () {
    testWidgets('Dialog has proper layout structure', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GoToDialog(),
        ),
      );

      // Verify there are Center widgets
      final centers = find.byType(Center);
      expect(centers, findsWidgets);

      // Find the specific column inside GoToDialog
      final column = find
          .descendant(
            of: find.byType(GoToDialog),
            matching: find.byType(Column),
          )
          .first;

      // Verify Column has 3 children: header, expanded list, footer
      final columnWidget = tester.widget<Column>(column);
      expect(columnWidget.children.length, 3);
      expect(columnWidget.children[0], isA<ResponsiveDialogHeader>());
      expect(columnWidget.children[1], isA<Expanded>());
      expect(columnWidget.children[2], isA<ResponsiveDialogFooter>());
    });
  });
}
