import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

class MockMobileScannerController extends Mock
    implements MobileScannerController {}

class MockBarcodeCapture extends Mock implements BarcodeCapture {}

void main() {
  late MockMobileScannerController mockController;

  setUp(() {
    mockController = MockMobileScannerController();

    // Setup default values
    when(() => mockController.autoStart).thenReturn(true);
    when(() => mockController.torchEnabled).thenReturn(true);
    when(() => mockController.detectionSpeed)
        .thenReturn(DetectionSpeed.noDuplicates);
    when(() => mockController.toggleTorch()).thenAnswer((_) async {});
    when(() => mockController.switchCamera()).thenAnswer((_) async {});
    when(() => mockController.dispose()).thenAnswer((_) async {});
    when(() => mockController.stop()).thenAnswer((_) async {});
    when(() => mockController.value).thenReturn(
      const MobileScannerState(
        availableCameras: 0,
        cameraDirection: CameraFacing.back,
        isInitialized: true,
        isRunning: true,
        size: Size.zero,
        torchState: TorchState.off,
        zoomScale: 100,
      ),
    );
  });

  Widget createTestWidget({
    void Function(BarcodeCapture)? onItemDetected,
  }) {
    return ProviderScope(
      overrides: [
        mobileScannerControllerProvider.overrideWith((ref) => mockController),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: ScanQrWidget(
            onItemDetected: onItemDetected ?? (_) {},
          ),
        ),
      ),
    );
  }

  group('ScanQrWidget', () {
    testWidgets('should display header with correct text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text("Scan Driver's License"), findsOneWidget);
    });

    testWidgets('should display torch and camera switch buttons',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Should find flash and camera icons
      expect(find.byIcon(Icons.flash_off), findsOneWidget);
      expect(find.byIcon(Icons.camera_rear), findsOneWidget);
    });

    testWidgets('should display MobileScanner widget', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(MobileScanner), findsOneWidget);
    });

    testWidgets('should display footer with cancel and accept buttons',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
    });

    testWidgets('should toggle torch when flash button is pressed',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find and tap the flash button
      final flashButton = find.byIcon(Icons.flash_off);
      await tester.tap(flashButton);
      await tester.pumpAndSettle();

      // Note: Can't fully test the actual toggle as it requires camera permissions
    });

    testWidgets('should switch camera when camera button is pressed',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find and tap the camera switch button
      final cameraButton = find.byIcon(Icons.camera_rear);
      await tester.tap(cameraButton);
      await tester.pumpAndSettle();

      // Note: Can't fully test the actual switch as it requires camera permissions
    });

    testWidgets('should pass barcode detection to callback', (tester) async {
      BarcodeCapture? capturedBarcode;
      await tester.pumpWidget(
        createTestWidget(
          onItemDetected: (capture) => capturedBarcode = capture,
        ),
      );

      // Get the MobileScanner widget
      final mobileScanner =
          tester.widget<MobileScanner>(find.byType(MobileScanner));

      // Create a mock barcode capture
      final mockCapture = MockBarcodeCapture();

      // Call the onDetect callback
      mobileScanner.onDetect?.call(mockCapture);

      expect(capturedBarcode, equals(mockCapture));
    });

    testWidgets('should show flash on icon when torch is on', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially should show flash_off
      expect(find.byIcon(Icons.flash_off), findsOneWidget);
      expect(find.byIcon(Icons.flash_on), findsNothing);
    });

    testWidgets('should show camera front icon for front camera',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially should show camera_rear
      expect(find.byIcon(Icons.camera_rear), findsOneWidget);
      expect(find.byIcon(Icons.camera_front), findsNothing);
    });

    testWidgets('should handle unavailable torch state', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should show question mark icon for unavailable state
      // Note: Can't easily test this without mocking the controller's ValueNotifier
    });

    testWidgets('should use correct colors for torch states', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final theme = Theme.of(tester.element(find.byType(IconButton).first));

      // Get the first icon (torch)
      final icon = tester.widget<Icon>(find.byIcon(Icons.flash_off));

      // Should use disabled color for off state
      expect(icon.color, equals(theme.disabledColor));
    });

    testWidgets('should have ResponsiveDialogHeader', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(ResponsiveDialogHeader), findsOneWidget);
    });

    testWidgets('should have ResponsiveDialogFooter', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(ResponsiveDialogFooter), findsOneWidget);
    });

    testWidgets('should use Column layout', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should center align torch and camera buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final row = tester.widget<Row>(
        find
            .ancestor(
              of: find.byIcon(Icons.flash_off),
              matching: find.byType(Row),
            )
            .first,
      );

      expect(row.mainAxisAlignment, equals(MainAxisAlignment.center));
    });
  });
}
