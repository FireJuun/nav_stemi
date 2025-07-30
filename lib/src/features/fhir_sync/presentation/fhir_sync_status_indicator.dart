import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// A widget that displays the current FHIR synchronization status
/// This can be placed in the app bar or other prominent location
class FhirSyncStatusIndicator extends ConsumerWidget {
  const FhirSyncStatusIndicator({
    super.key,
    this.showLabel = false,
    this.size = 24,
  });

  /// Whether to show a text label alongside the icon
  final bool showLabel;

  /// Size of the icon
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(overallSyncStatusProvider);
    final errorMessage = ref.watch(syncLastErrorMessageProvider);
    final isSyncPaused = ref.watch(fhirSyncServiceProvider).isSyncPaused;

    return Tooltip(
      message: _getTooltipMessage(syncStatus, errorMessage, isSyncPaused),
      child: InkWell(
        onTap: () => _handleTap(context, ref, syncStatus),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    _getIconData(syncStatus, isSyncPaused),
                    color: _getIconColor(context, syncStatus, isSyncPaused),
                    size: size,
                  ),
                  if (isSyncPaused)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        child: Icon(
                          Icons.pause,
                          color: Theme.of(context).colorScheme.error,
                          size: size / 2,
                        ),
                      ),
                    ),
                ],
              ),
              if (showLabel) ...[
                const SizedBox(width: 8),
                Text(
                  _getStatusLabel(syncStatus, isSyncPaused),
                  style: TextStyle(
                    color: _getIconColor(context, syncStatus, isSyncPaused),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Returns the appropriate icon for the current sync status
  IconData _getIconData(FhirSyncStatus status, bool isSyncPaused) {
    if (isSyncPaused) {
      return Icons.cloud_off;
    }

    switch (status) {
      case FhirSyncStatus.synced:
        return Icons.cloud_done;
      case FhirSyncStatus.dirty:
        return Icons.cloud_upload;
      case FhirSyncStatus.syncing:
        return Icons.sync;
      case FhirSyncStatus.offline:
        return Icons.cloud_off;
      case FhirSyncStatus.error:
        return Icons.error_outline;
    }
  }

  /// Returns the appropriate color for the current sync status
  Color _getIconColor(
      BuildContext context, FhirSyncStatus status, bool isSyncPaused,) {
    if (isSyncPaused) {
      return Colors.grey;
    }

    final colorScheme = Theme.of(context).colorScheme;

    switch (status) {
      case FhirSyncStatus.synced:
        return colorScheme.primary;
      case FhirSyncStatus.dirty:
        return Colors.orange;
      case FhirSyncStatus.syncing:
        return colorScheme.primary;
      case FhirSyncStatus.offline:
        return Colors.grey;
      case FhirSyncStatus.error:
        return colorScheme.error;
    }
  }

  /// Returns a user-friendly label for the current sync status
  String _getStatusLabel(FhirSyncStatus status, bool isSyncPaused) {
    if (isSyncPaused) {
      return 'Sync Paused';
    }

    switch (status) {
      case FhirSyncStatus.synced:
        return 'Synced';
      case FhirSyncStatus.dirty:
        return 'Sync Pending';
      case FhirSyncStatus.syncing:
        return 'Syncing...';
      case FhirSyncStatus.offline:
        return 'Offline';
      case FhirSyncStatus.error:
        return 'Sync Error';
    }
  }

  /// Returns an appropriate tooltip message for the current sync status
  String _getTooltipMessage(
      FhirSyncStatus status, String? errorMessage, bool isSyncPaused,) {
    if (isSyncPaused) {
      return 'Synchronization is paused. Click to resume or manage sync.';
    }

    final baseMessage = switch (status) {
      FhirSyncStatus.synced => 'All data is synced with the FHIR server',
      FhirSyncStatus.dirty => 'You have unsaved changes that need to be synced',
      FhirSyncStatus.syncing => 'Currently syncing data with the FHIR server',
      FhirSyncStatus.offline =>
        'You are currently offline. Changes will be synced when online',
      FhirSyncStatus.error => 'Error syncing with FHIR server',
    };

    if (status == FhirSyncStatus.error && errorMessage != null) {
      return '$baseMessage: $errorMessage';
    }
    return baseMessage;
  }

  /// Handles tap on the indicator
  void _handleTap(BuildContext context, WidgetRef ref, FhirSyncStatus status) {
    final syncService = ref.read(fhirSyncServiceProvider);
    final isSyncPaused = syncService.isSyncPaused;

    // Show dialog with sync options
    showDialog<void>(
      context: context,
      builder: (context) =>
          _buildSyncDialog(context, ref, status, isSyncPaused),
    );
  }

  /// Builds a dialog with sync management options
  Widget _buildSyncDialog(BuildContext context, WidgetRef ref,
      FhirSyncStatus status, bool isSyncPaused,) {
    final syncService = ref.read(fhirSyncServiceProvider);
    final errorMessage = ref.read(syncLastErrorMessageProvider);

    return AlertDialog(
      title: Text(isSyncPaused ? 'Sync Paused' : 'Sync Management'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSyncPaused
                ? 'FHIR synchronization is currently paused.'
                : 'Current status: ${_getStatusLabel(status, false)}',
          ),
          const SizedBox(height: 8),
          if (status == FhirSyncStatus.error && errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              'Error: $errorMessage',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('DISMISS'),
        ),
        if (status == FhirSyncStatus.error || status == FhirSyncStatus.dirty)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              syncService.manuallySyncAllData();
            },
            child: const Text('RETRY SYNC'),
          ),
        if (isSyncPaused)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              syncService.resumeSyncing();
            },
            child: const Text('RESUME SYNC'),
          )
        else
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              syncService.pauseSyncing();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('PAUSE SYNC'),
          ),
      ],
    );
  }
}
