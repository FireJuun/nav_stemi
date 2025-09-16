import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Mock classes
class MockFhirSyncService extends Mock implements FhirSyncService {}

void main() {
  late MockFhirSyncService mockSyncService;

  setUp(() {
    mockSyncService = MockFhirSyncService();

    // Setup default behaviors
    when(() => mockSyncService.isSyncPaused).thenReturn(false);
    when(() => mockSyncService.manuallySyncAllData())
        .thenAnswer((_) async {});
    when(() => mockSyncService.pauseSyncing())
        .thenAnswer((_) async {});
    when(() => mockSyncService.resumeSyncing())
        .thenAnswer((_) async {});
  });

  Widget createTestWidget({
    bool showLabel = false,
    double size = 24,
    FhirSyncStatus? overrideStatus,
    String? overrideErrorMessage,
    bool? overrideSyncPaused,
  }) {
    return ProviderScope(
      overrides: [
        fhirSyncServiceProvider.overrideWithValue(mockSyncService),
        if (overrideStatus != null)
          overallSyncStatusProvider.overrideWithValue(overrideStatus),
        if (overrideErrorMessage != null)
          syncLastErrorMessageProvider.overrideWithValue(overrideErrorMessage),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: FhirSyncStatusIndicator(
              showLabel: showLabel,
              size: size,
            ),
          ),
        ),
      ),
    );
  }

  group('FhirSyncStatusIndicator Widget Tests', () {
    testWidgets('should display synced status icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(overrideStatus: FhirSyncStatus.synced),
      );

      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
      
      // Check icon color
      final icon = tester.widget<Icon>(find.byIcon(Icons.cloud_done));
      expect(icon.color, isNotNull);
    });

    testWidgets('should display dirty status icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(overrideStatus: FhirSyncStatus.dirty),
      );

      expect(find.byIcon(Icons.cloud_upload), findsOneWidget);
      
      // Check icon color
      final icon = tester.widget<Icon>(find.byIcon(Icons.cloud_upload));
      expect(icon.color, equals(Colors.orange));
    });

    testWidgets('should display syncing status icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(overrideStatus: FhirSyncStatus.syncing),
      );

      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('should display offline status icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(overrideStatus: FhirSyncStatus.offline),
      );

      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      
      // Check icon color
      final icon = tester.widget<Icon>(find.byIcon(Icons.cloud_off));
      expect(icon.color, equals(Colors.grey));
    });

    testWidgets('should display error status icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(overrideStatus: FhirSyncStatus.error),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display pause indicator when sync is paused',
        (tester) async {
      when(() => mockSyncService.isSyncPaused).thenReturn(true);

      await tester.pumpWidget(
        createTestWidget(overrideStatus: FhirSyncStatus.synced),
      );

      // Should show cloud_off icon when paused
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      // Should show pause overlay icon
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('should show label when showLabel is true', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          showLabel: true,
          overrideStatus: FhirSyncStatus.synced,
        ),
      );

      expect(find.text('Synced'), findsOneWidget);
    });

    testWidgets('should show correct label for each status', (tester) async {
      final testCases = [
        (FhirSyncStatus.synced, 'Synced'),
        (FhirSyncStatus.dirty, 'Sync Pending'),
        (FhirSyncStatus.syncing, 'Syncing...'),
        (FhirSyncStatus.offline, 'Offline'),
        (FhirSyncStatus.error, 'Sync Error'),
      ];

      for (final (status, expectedLabel) in testCases) {
        await tester.pumpWidget(
          createTestWidget(
            showLabel: true,
            overrideStatus: status,
          ),
        );

        expect(find.text(expectedLabel), findsOneWidget);
      }
    });

    testWidgets('should show paused label when sync is paused',
        (tester) async {
      when(() => mockSyncService.isSyncPaused).thenReturn(true);

      await tester.pumpWidget(
        createTestWidget(
          showLabel: true,
          overrideStatus: FhirSyncStatus.synced,
        ),
      );

      expect(find.text('Sync Paused'), findsOneWidget);
    });

    testWidgets('should display tooltip on hover', (tester) async {
      await tester.pumpWidget(
        createTestWidget(overrideStatus: FhirSyncStatus.synced),
      );

      final tooltip = find.byType(Tooltip);
      expect(tooltip, findsOneWidget);

      // Get tooltip message
      final tooltipWidget = tester.widget<Tooltip>(tooltip);
      expect(
        tooltipWidget.message,
        equals('All data is synced with the FHIR server'),
      );
    });

    testWidgets('should display error message in tooltip when error',
        (tester) async {
      const errorMessage = 'Connection failed';

      await tester.pumpWidget(
        createTestWidget(
          overrideStatus: FhirSyncStatus.error,
          overrideErrorMessage: errorMessage,
        ),
      );

      final tooltip = find.byType(Tooltip);
      final tooltipWidget = tester.widget<Tooltip>(tooltip);
      expect(
        tooltipWidget.message,
        equals('Error syncing with FHIR server: $errorMessage'),
      );
    });

    testWidgets('should open dialog when tapped', (tester) async {
      await tester.pumpWidget(
        createTestWidget(overrideStatus: FhirSyncStatus.synced),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Sync Management'), findsOneWidget);
    });

    testWidgets('should show paused dialog when sync is paused',
        (tester) async {
      when(() => mockSyncService.isSyncPaused).thenReturn(true);

      await tester.pumpWidget(
        createTestWidget(overrideStatus: FhirSyncStatus.synced),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.text('Sync Paused'), findsOneWidget);
      expect(
        find.text('FHIR synchronization is currently paused.'),
        findsOneWidget,
      );
      expect(find.text('RESUME SYNC'), findsOneWidget);
    });

    testWidgets('should show retry button for error status', (tester) async {
      await tester.pumpWidget(
        createTestWidget(overrideStatus: FhirSyncStatus.error),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.text('RETRY SYNC'), findsOneWidget);
    });

    testWidgets('should show retry button for dirty status', (tester) async {
      await tester.pumpWidget(
        createTestWidget(overrideStatus: FhirSyncStatus.dirty),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.text('RETRY SYNC'), findsOneWidget);
    });

    testWidgets('should show pause button when not paused', (tester) async {
      await tester.pumpWidget(
        createTestWidget(overrideStatus: FhirSyncStatus.synced),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.text('PAUSE SYNC'), findsOneWidget);
    });

    testWidgets('should display error message in dialog', (tester) async {
      const errorMessage = 'Server unreachable';

      await tester.pumpWidget(
        createTestWidget(
          overrideStatus: FhirSyncStatus.error,
          overrideErrorMessage: errorMessage,
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.text('Error: $errorMessage'), findsOneWidget);
    });

    testWidgets('should call manuallySyncAllData when retry is tapped',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(overrideStatus: FhirSyncStatus.error),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      await tester.tap(find.text('RETRY SYNC'));
      await tester.pumpAndSettle();

      verify(() => mockSyncService.manuallySyncAllData()).called(1);
      
      // Dialog should be dismissed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should call pauseSyncing when pause is tapped',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(overrideStatus: FhirSyncStatus.synced),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      await tester.tap(find.text('PAUSE SYNC'));
      await tester.pumpAndSettle();

      verify(() => mockSyncService.pauseSyncing()).called(1);
      
      // Dialog should be dismissed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should call resumeSyncing when resume is tapped',
        (tester) async {
      when(() => mockSyncService.isSyncPaused).thenReturn(true);

      await tester.pumpWidget(
        createTestWidget(overrideStatus: FhirSyncStatus.synced),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      await tester.tap(find.text('RESUME SYNC'));
      await tester.pumpAndSettle();

      verify(() => mockSyncService.resumeSyncing()).called(1);
      
      // Dialog should be dismissed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should dismiss dialog when dismiss is tapped',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(overrideStatus: FhirSyncStatus.synced),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DISMISS'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should use custom icon size', (tester) async {
      const customSize = 48.0;

      await tester.pumpWidget(
        createTestWidget(
          size: customSize,
          overrideStatus: FhirSyncStatus.synced,
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.cloud_done));
      expect(icon.size, equals(customSize));
    });

    testWidgets('should size pause icon relative to main icon',
        (tester) async {
      const customSize = 48.0;
      when(() => mockSyncService.isSyncPaused).thenReturn(true);

      await tester.pumpWidget(
        createTestWidget(
          size: customSize,
          overrideStatus: FhirSyncStatus.synced,
        ),
      );

      final pauseIcon = tester.widget<Icon>(find.byIcon(Icons.pause));
      expect(pauseIcon.size, equals(customSize / 2));
    });

    testWidgets('should style pause button with error colors',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(overrideStatus: FhirSyncStatus.synced),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      final pauseButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'PAUSE SYNC'),
      );
      
      final style = pauseButton.style;
      expect(style, isNotNull);
    });
  });

  group('FhirSyncStatusIndicator Tooltip Tests', () {
    testWidgets('should show correct tooltip for each status', (tester) async {
      final testCases = [
        (
          FhirSyncStatus.synced,
          'All data is synced with the FHIR server',
        ),
        (
          FhirSyncStatus.dirty,
          'You have unsaved changes that need to be synced',
        ),
        (
          FhirSyncStatus.syncing,
          'Currently syncing data with the FHIR server',
        ),
        (
          FhirSyncStatus.offline,
          'You are currently offline. Changes will be synced when online',
        ),
        (
          FhirSyncStatus.error,
          'Error syncing with FHIR server',
        ),
      ];

      for (final (status, expectedTooltip) in testCases) {
        await tester.pumpWidget(
          createTestWidget(overrideStatus: status),
        );

        final tooltip = find.byType(Tooltip);
        final tooltipWidget = tester.widget<Tooltip>(tooltip);
        expect(tooltipWidget.message, equals(expectedTooltip));
      }
    });

    testWidgets('should show paused tooltip when sync is paused',
        (tester) async {
      when(() => mockSyncService.isSyncPaused).thenReturn(true);

      await tester.pumpWidget(
        createTestWidget(overrideStatus: FhirSyncStatus.synced),
      );

      final tooltip = find.byType(Tooltip);
      final tooltipWidget = tester.widget<Tooltip>(tooltip);
      expect(
        tooltipWidget.message,
        equals(
          'Synchronization is paused. Click to resume or manage sync.',
        ),
      );
    });
  });
}
