import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:nav_stemi/src/features/add_data/data/sync_notify_controller.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:shrink/shrink.dart';

class SyncNotify extends ConsumerStatefulWidget {
  const SyncNotify({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SyncNotifyState();
}

class _SyncNotifyState extends ConsumerState<SyncNotify> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(SyncNotifyController.provider);

    return stateAsync.when(
      data: (state) => SyncNotifyData(state: state),
      error: (error, stackTrace) => const SyncNotifyError(),
      loading: () => const SyncNotifierLoading(),
    );
  }
}

class SyncNotifyData extends ConsumerWidget {
  const SyncNotifyData({required this.state, super.key});

  final SyncNotifyState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverMainAxisGroup(
      slivers: [
        // SliverList.builder(
        //   itemBuilder: (context, index) {
        //     return ListTile(
        //       title: Text(state.connectedPeers[index].displayName),
        //       trailing: IconButton(
        //         onPressed: () => ref
        //             .read(SyncNotifyController.provider.notifier)
        //             .onHandleSync(state.connectedPeers[index].syncId),
        //         icon: const Icon(Icons.sync),
        //       ),
        //     );
        //   },
        //   itemCount: state.connectedPeers.length,
        // ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList.list(
            children: [
              const SyncNotifyShareSession(),
              gapH8,
              Center(
                child: Consumer(
                  builder: (context, ref, child) {
                    final destinationValue = ref.watch(
                      activeDestinationProvider,
                    );

                    return AsyncValueWidget<ActiveDestination?>(
                      value: destinationValue,
                      data: (activeDestination) {
                        if (activeDestination == null) {
                          return Text('--'.hardcoded);
                        }

                        final edDestinationInfo =
                            activeDestination.destinationInfo;

                        return Column(
                          children: [
                            const Divider(thickness: 2),
                            Text(
                              'Notify Destination'.hardcoded,
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const Divider(thickness: 2),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 32,
                              children: [
                                DestinationPhoneItem(
                                  phoneNumber: edDestinationInfo.facilityPhone1,
                                  phoneNote:
                                      edDestinationInfo.facilityPhone1Note,
                                ),
                                if (edDestinationInfo.facilityPhone2 != null)
                                  DestinationPhoneItem(
                                    phoneNumber:
                                        edDestinationInfo.facilityPhone2!,
                                    phoneNote:
                                        edDestinationInfo.facilityPhone2Note,
                                  ),
                                if (edDestinationInfo.facilityPhone3 != null)
                                  DestinationPhoneItem(
                                    phoneNumber:
                                        edDestinationInfo.facilityPhone3!,
                                    phoneNote:
                                        edDestinationInfo.facilityPhone3Note,
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SyncNotifyError extends StatelessWidget {
  const SyncNotifyError({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(child: Placeholder());
  }
}

class SyncNotifierLoading extends StatelessWidget {
  const SyncNotifierLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(child: Placeholder());
  }
}

class SyncNotifyShareSession extends ConsumerWidget {
  const SyncNotifyShareSession({this.usePrimaryColor = false, super.key});

  final bool usePrimaryColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch patient info and time metrics for QR code generation
    final patientInfoAsync = ref.watch(patientInfoModelProvider);
    final timeMetricsAsync = ref.watch(timeMetricsModelProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          _SessionQrCode(
            patientInfoAsync: patientInfoAsync,
            timeMetricsAsync: timeMetricsAsync,
            usePrimaryColor: usePrimaryColor,
          ),
          Column(
            children: [
              Text(
                'Sync with others:'.hardcoded,
                textAlign: TextAlign.center,
              ),
              gapH8,
              FilledButton(
                onPressed: () => _showQrScannerBottomSheet(context, ref),
                child: Text(
                  'Scan Session'.hardcoded,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Shows the QR code scanner bottom sheet.
  void _showQrScannerBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _QrScannerBottomSheet(ref: ref),
    );
  }
}

/// Private widget for displaying session data as a QR code.
///
/// Handles loading, error, and empty states, and generates a QR code
/// from patient info and time metrics data.
class _SessionQrCode extends StatelessWidget {
  const _SessionQrCode({
    required this.patientInfoAsync,
    required this.timeMetricsAsync,
    required this.usePrimaryColor,
  });

  final AsyncValue<PatientInfoModel?> patientInfoAsync;
  final AsyncValue<TimeMetricsModel?> timeMetricsAsync;
  final bool usePrimaryColor;

  @override
  Widget build(BuildContext context) {
    // Handle loading state
    if (patientInfoAsync.isLoading || timeMetricsAsync.isLoading) {
      return const SizedBox(
        width: 150,
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Handle error state
    if (patientInfoAsync.hasError || timeMetricsAsync.hasError) {
      return SizedBox(
        width: 150,
        height: 150,
        child: Center(
          child: Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    // Get the data values
    final patientInfo = patientInfoAsync.value;
    final timeMetrics = timeMetricsAsync.value;

    // Create session data
    final sessionData = SessionShareData(
      patientInfo: patientInfo,
      timeMetrics: timeMetrics,
    );

    // If no data exists, show placeholder
    if (!sessionData.hasData) {
      return SizedBox(
        width: 150,
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_2,
                size: 48,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
              ),
              gapH4,
              Text(
                'No data'.hardcoded,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // Generate QR code from session data
    try {
      final data = sessionData.toJson();
      final compressedData = data.shrink();

      debugPrint(
        'Compressed data from ${data.length} to ${compressedData.length} bytes',
      );

      final qrCode = QrCode.fromData(
        data: base64Encode(compressedData),
        errorCorrectLevel: QrErrorCorrectLevel.M,
      );

      final qrImage = QrImage(qrCode);

      return Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: usePrimaryColor
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Center(
          child: PrettyQrView(
            qrImage: qrImage,
          ),
        ),
      );
    } catch (e) {
      // Handle QR code generation errors (e.g., data too large)
      return SizedBox(
        width: 150,
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              gapH4,
              Text(
                'Data too large'.hardcoded,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}

/// Private widget for the QR code scanner bottom sheet.
///
/// Displays a mobile scanner to scan QR codes containing session data.
/// When a valid QR code is detected, it deserializes the data and loads
/// it into the current session.
class _QrScannerBottomSheet extends StatefulWidget {
  const _QrScannerBottomSheet({required this.ref});

  final WidgetRef ref;

  @override
  State<_QrScannerBottomSheet> createState() => _QrScannerBottomSheetState();
}

class _QrScannerBottomSheetState extends State<_QrScannerBottomSheet> {
  static const int _qrScannerDetectionTimeoutMs = 10000;
  final MobileScannerController _scannerController = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionTimeoutMs: _qrScannerDetectionTimeoutMs,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header with title and close button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Scan Session QR Code'.hardcoded,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Instructions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Point your camera at a session QR code to load the data'
                  .hardcoded,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),

          // Scanner view
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _handleBarcodeDetect,
                ),
                if (_isProcessing)
                  const ColoredBox(
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom padding
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Handles barcode detection from the scanner.
  Future<void> _handleBarcodeDetect(BarcodeCapture capture) async {
    debugPrint('Barcode detected: ${capture.barcodes.length}');

    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _isProcessing = true);

    try {
      // Deserialize the session data from JSON
      final compressedData = base64Decode(barcode.rawValue!).restoreText();
      final sessionData = SessionShareData.fromJson(compressedData);

      // Check version compatibility (optional)
      if (sessionData.version > 1) {
        throw Exception(
          'Incompatible QR code version: ${sessionData.version}. '
          'Please update the app.',
        );
      }

      // Load patient info if available
      if (sessionData.patientInfo != null) {
        widget.ref
            .read(patientInfoControllerProvider.notifier)
            .setPatientInfoModel(sessionData.patientInfo!);
      }

      // Load time metrics if available
      if (sessionData.timeMetrics != null) {
        widget.ref
            .read(timeMetricsControllerProvider.notifier)
            .setTimeMetrics(sessionData.timeMetrics!);
      }

      // Close the bottom sheet
      if (mounted) {
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Session data loaded successfully!'.hardcoded),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error processing QR code: $e');
      debugPrintStack(stackTrace: stackTrace);
      // Close the bottom sheet
      if (mounted) {
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load session data: $e'.hardcoded),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
