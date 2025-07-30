import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Mock classes
class MockActiveDestination extends Mock implements ActiveDestination {}

class MockHospital extends Mock implements Hospital {}

void main() {
  group('SyncNotify', () {
    testWidgets('displays SyncNotifyShareSession widget', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [SyncNotify()],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SyncNotifyShareSession), findsOneWidget);
    });

    testWidgets('displays "--" when no active destination', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeDestinationProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [SyncNotify()],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('--'), findsOneWidget);
    });

    testWidgets('displays destination info when active destination exists',
        (tester) async {
      final mockHospital = MockHospital();
      final mockActiveDestination = MockActiveDestination();

      when(() => mockActiveDestination.destinationInfo)
          .thenReturn(mockHospital);
      when(() => mockHospital.facilityPhone1).thenReturn('123-456-7890');
      when(() => mockHospital.facilityPhone1Note).thenReturn('Main Line');
      when(() => mockHospital.facilityPhone2).thenReturn(null);
      when(() => mockHospital.facilityPhone3).thenReturn(null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeDestinationProvider.overrideWith(
              (ref) => Stream.value(mockActiveDestination),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [SyncNotify()],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Notify Destination'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
      expect(find.byType(DestinationPhoneItem), findsOneWidget);
    });

    testWidgets('displays multiple phone numbers when available',
        (tester) async {
      final mockHospital = MockHospital();
      final mockActiveDestination = MockActiveDestination();

      when(() => mockActiveDestination.destinationInfo)
          .thenReturn(mockHospital);
      when(() => mockHospital.facilityPhone1).thenReturn('123-456-7890');
      when(() => mockHospital.facilityPhone1Note).thenReturn('Main Line');
      when(() => mockHospital.facilityPhone2).thenReturn('098-765-4321');
      when(() => mockHospital.facilityPhone2Note).thenReturn('Emergency');
      when(() => mockHospital.facilityPhone3).thenReturn('555-555-5555');
      when(() => mockHospital.facilityPhone3Note).thenReturn('Admin');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeDestinationProvider.overrideWith(
              (ref) => Stream.value(mockActiveDestination),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [SyncNotify()],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(DestinationPhoneItem), findsNWidgets(3));
    });

    testWidgets('shows loading state when data is loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeDestinationProvider
                .overrideWith((ref) => const Stream.empty()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [SyncNotify()],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when data fails to load', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeDestinationProvider.overrideWith(
              (ref) => Stream.error(Exception('Failed to load destination')),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [SyncNotify()],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.textContaining('Failed to load destination'), findsOneWidget);
    });

    testWidgets('uses correct sliver structure', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [SyncNotify()],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SliverMainAxisGroup), findsOneWidget);
      expect(find.byType(SliverPadding), findsOneWidget);
      expect(find.byType(SliverList), findsOneWidget);
    });

    testWidgets('has correct padding values', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [SyncNotify()],
              ),
            ),
          ),
        ),
      );

      final sliverPadding =
          tester.widget<SliverPadding>(find.byType(SliverPadding));
      expect(
        sliverPadding.padding,
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
    });
  });

  group('SyncNotifyShareSession', () {
    testWidgets('displays sync text and button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncNotifyShareSession(),
          ),
        ),
      );

      expect(find.text('Sync with others:'), findsOneWidget);
      expect(find.text('Scan Session'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('displays default QR placeholder image', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncNotifyShareSession(),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as AssetImage).assetName,
        'assets/placeholder_share_qr.png',
      );
      expect(image.width, 132);
      expect(image.height, 132);
    });

    testWidgets(
        'displays primary color QR placeholder when usePrimaryColor is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncNotifyShareSession(usePrimaryColor: true),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as AssetImage).assetName,
        'assets/placeholder_share_qr_primary.png',
      );
    });

    testWidgets('has correct layout structure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncNotifyShareSession(),
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Expanded), findsNWidgets(2));
    });

    testWidgets('button has onPressed handler', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncNotifyShareSession(),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('has correct padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncNotifyShareSession(),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, const EdgeInsets.symmetric(horizontal: 12));
    });

    testWidgets('text is centered', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncNotifyShareSession(),
          ),
        ),
      );

      final syncText = tester.widget<Text>(find.text('Sync with others:'));
      expect(syncText.textAlign, TextAlign.center);

      final buttonText = tester.widget<Text>(find.text('Scan Session'));
      expect(buttonText.textAlign, TextAlign.center);
    });
  });
}
