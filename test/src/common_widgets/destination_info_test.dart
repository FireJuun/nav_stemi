import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

class MockGoRouter extends Mock implements GoRouter {}

class MockActiveDestinationRepository extends Mock
    implements ActiveDestinationRepository {}

class FakeHospital extends Fake implements Hospital {}

class MockDestinations extends Mock implements Destinations {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeHospital());
  });

  group('DestinationInfo', () {
    late MockGoRouter mockGoRouter;
    late MockActiveDestinationRepository mockActiveDestinationRepository;

    setUp(() {
      mockGoRouter = MockGoRouter();
      mockActiveDestinationRepository = MockActiveDestinationRepository();

      // Default to empty stream
      when(() => mockActiveDestinationRepository.watchDestinations())
          .thenAnswer((_) => Stream.value(null));
    });

    Widget createTestWidget(Widget child) {
      return ProviderScope(
        overrides: [
          goRouterProvider.overrideWithValue(mockGoRouter),
          activeDestinationRepositoryProvider.overrideWithValue(
            mockActiveDestinationRepository,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: child),
        ),
      );
    }

    testWidgets('should display empty SizedBox when no active destination',
        (tester) async {
      when(() => mockActiveDestinationRepository.watchDestinations())
          .thenAnswer((_) => Stream.value(null));

      await tester.pumpWidget(createTestWidget(const DestinationInfo()));
      await tester.pump();

      // AsyncValueWidget wraps the content, so we need to check for its content
      expect(find.text('Destination:'), findsNothing);
    });

    testWidgets(
        'should display destination info when active destination exists',
        (tester) async {
      const hospital = Hospital(
        facilityBrandedName: 'Test Hospital',
        facilityAddress: '123 Test St',
        facilityCity: 'Test City',
        facilityState: 'NC',
        facilityZip: 12345,
        latitude: 35,
        longitude: -80,
        county: 'Test County',
        source: 'Test',
        facilityPhone1: '555-1234',
        distanceToAsheboro: 10,
        pciCenter: 1,
      );

      final mockDestinations = MockDestinations();
      final activeDestination = ActiveDestination(
        destination: mockDestinations,
        destinationInfo: hospital,
      );

      when(() => mockActiveDestinationRepository.watchDestinations())
          .thenAnswer((_) => Stream.value(activeDestination));

      await tester.pumpWidget(createTestWidget(const DestinationInfo()));
      await tester.pump();

      expect(find.text('Destination:'), findsOneWidget);
      expect(find.text('Test Hospital'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('should navigate to info dialog when info button pressed',
        (tester) async {
      const hospital = Hospital(
        facilityBrandedName: 'Test Hospital',
        facilityAddress: '123 Test St',
        facilityCity: 'Test City',
        facilityState: 'NC',
        facilityZip: 12345,
        latitude: 35,
        longitude: -80,
        county: 'Test County',
        source: 'Test',
        facilityPhone1: '555-1234',
        distanceToAsheboro: 10,
        pciCenter: 1,
      );

      final mockDestinations = MockDestinations();
      final activeDestination = ActiveDestination(
        destination: mockDestinations,
        destinationInfo: hospital,
      );

      when(() => mockActiveDestinationRepository.watchDestinations())
          .thenAnswer((_) => Stream.value(activeDestination));
      when(() => mockGoRouter.goNamed(
            any(),
            pathParameters: any(named: 'pathParameters'),
            queryParameters: any(named: 'queryParameters'),
            extra: any(named: 'extra'),
          ),).thenReturn(null);

      await tester.pumpWidget(createTestWidget(const DestinationInfo()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();

      verify(() => mockGoRouter.goNamed(
            AppRoute.navInfo.name,
            extra: hospital,
          ),).called(1);
    });

    testWidgets('should handle long hospital names with ellipsis',
        (tester) async {
      const hospital = Hospital(
        facilityBrandedName: 'Very Long Hospital Name That Should Be Truncated',
        facilityAddress: '123 Test St',
        facilityCity: 'Test City',
        facilityState: 'NC',
        facilityZip: 12345,
        latitude: 35,
        longitude: -80,
        county: 'Test County',
        source: 'Test',
        facilityPhone1: '555-1234',
        distanceToAsheboro: 10,
        pciCenter: 1,
      );

      final mockDestinations = MockDestinations();
      final activeDestination = ActiveDestination(
        destination: mockDestinations,
        destinationInfo: hospital,
      );

      when(() => mockActiveDestinationRepository.watchDestinations())
          .thenAnswer((_) => Stream.value(activeDestination));

      await tester.pumpWidget(createTestWidget(const DestinationInfo()));
      await tester.pump();

      final textWidget = tester.widget<Text>(
        find.text('Very Long Hospital Name That Should Be Truncated'),
      );
      expect(textWidget.overflow, TextOverflow.ellipsis);
      expect(textWidget.maxLines, 2);
    });
  });

  group('DestinationInfoDialog', () {
    Widget createTestDialog(Hospital hospital) {
      return MaterialApp(
        home: Scaffold(
          body: DestinationInfoDialog(hospital),
        ),
      );
    }

    testWidgets('should display basic hospital information', (tester) async {
      const hospital = Hospital(
        facilityBrandedName: 'Test Hospital',
        facilityAddress: '123 Test St',
        facilityCity: 'Test City',
        facilityState: 'NC',
        facilityZip: 12345,
        latitude: 35,
        longitude: -80,
        county: 'Test County',
        source: 'Test',
        facilityPhone1: '555-1234',
        distanceToAsheboro: 10,
        pciCenter: 1,
      );

      await tester.pumpWidget(createTestDialog(hospital));

      expect(find.text('Destination Info'), findsOneWidget);
      expect(find.text('Test Hospital'), findsOneWidget);
      expect(find.text('123 Test St'), findsOneWidget);
      expect(find.text('Test City, NC 12345'), findsOneWidget);
      expect(find.text('555-1234'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('should display all three phone numbers when available',
        (tester) async {
      const hospital = Hospital(
        facilityBrandedName: 'Test Hospital',
        facilityAddress: '123 Test St',
        facilityCity: 'Test City',
        facilityState: 'NC',
        facilityZip: 12345,
        latitude: 35,
        longitude: -80,
        county: 'Test County',
        source: 'Test',
        facilityPhone1: '555-1234',
        facilityPhone1Note: 'Main',
        facilityPhone2: '555-5678',
        facilityPhone2Note: 'Emergency',
        facilityPhone3: '555-9012',
        facilityPhone3Note: 'Admin',
        distanceToAsheboro: 10,
        pciCenter: 1,
      );

      await tester.pumpWidget(createTestDialog(hospital));

      expect(find.text('555-1234'), findsOneWidget);
      expect(find.text('Main'), findsOneWidget);
      expect(find.text('555-5678'), findsOneWidget);
      expect(find.text('Emergency'), findsOneWidget);
      expect(find.text('555-9012'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
    });

    testWidgets('should only display phone 1 when others are null',
        (tester) async {
      const hospital = Hospital(
        facilityBrandedName: 'Test Hospital',
        facilityAddress: '123 Test St',
        facilityCity: 'Test City',
        facilityState: 'NC',
        facilityZip: 12345,
        latitude: 35,
        longitude: -80,
        county: 'Test County',
        source: 'Test',
        facilityPhone1: '555-1234',
        facilityPhone1Note: 'Main',
        distanceToAsheboro: 10,
        pciCenter: 1,
      );

      await tester.pumpWidget(createTestDialog(hospital));

      expect(find.text('555-1234'), findsOneWidget);
      expect(find.text('Main'), findsOneWidget);
      expect(find.text('555-5678'), findsNothing);
      expect(find.text('555-9012'), findsNothing);
    });
  });

  group('DestinationPhoneItem', () {
    Widget createTestWidget(String phoneNumber, String? phoneNote) {
      return MaterialApp(
        home: Scaffold(
          body: DestinationPhoneItem(
            phoneNumber: phoneNumber,
            phoneNote: phoneNote,
          ),
        ),
      );
    }

    testWidgets('should display phone number with underline', (tester) async {
      await tester.pumpWidget(createTestWidget('555-1234', null));

      expect(find.text('555-1234'), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text('555-1234'));
      expect(textWidget.style?.decoration, TextDecoration.underline);
    });

    testWidgets('should display phone note when provided', (tester) async {
      await tester.pumpWidget(createTestWidget('555-1234', 'Main Line'));

      expect(find.text('555-1234'), findsOneWidget);
      expect(find.text('Main Line'), findsOneWidget);
    });

    testWidgets('should not display phone note when null', (tester) async {
      await tester.pumpWidget(createTestWidget('555-1234', null));

      expect(find.text('555-1234'), findsOneWidget);
      expect(find.text('Main Line'), findsNothing);
    });

    testWidgets('should call callDestination when tapped', (tester) async {
      await tester.pumpWidget(createTestWidget('555-1234', null));

      await tester.tap(find.text('555-1234'));
      await tester.pumpAndSettle();

      // Note: We can't easily test the actual phone call functionality
      // as it requires platform channels. The tap gesture is registered though.
    });
  });
}
