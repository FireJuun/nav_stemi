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
    final syncStatus = ref.watch(fhirOverallSyncStatusProvider);
    final errorMessage = ref.watch(fhirSyncLastErrorMessageProvider);
    
    return Tooltip(
      message: _getTooltipMessage(syncStatus, errorMessage),
      child: InkWell(
        onTap: () => _handleTap(context, ref, syncStatus),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIconData(syncStatus),
                color: _getIconColor(context, syncStatus),
                size: size,
              ),
              if (showLabel) ...[
                const SizedBox(width: 8),
                Text(
                  _getStatusLabel(syncStatus),
                  style: TextStyle(
                    color: _getIconColor(context, syncStatus),
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
  IconData _getIconData(FhirSyncStatus status) {
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
  Color _getIconColor(BuildContext context, FhirSyncStatus status) {
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
  String _getStatusLabel(FhirSyncStatus status) {
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
  String _getTooltipMessage(FhirSyncStatus status, String? errorMessage) {
    final baseMessage = switch (status) {
      FhirSyncStatus.synced => 'All data is synced with the FHIR server',
      FhirSyncStatus.dirty => 'You have unsaved changes that need to be synced',
      FhirSyncStatus.syncing => 'Currently syncing data with the FHIR server',
      FhirSyncStatus.offline => 'You are currently offline. Changes will be synced when online',
      FhirSyncStatus.error => 'Error syncing with FHIR server',
    };
    
    if (status == FhirSyncStatus.error && errorMessage != null) {
      return '$baseMessage: $errorMessage';
    }
    return baseMessage;
  }
  
  /// Handles tap on the indicator
  void _handleTap(BuildContext context, WidgetRef ref, FhirSyncStatus status) {
    switch (status) {
      case FhirSyncStatus.synced:
        // Already synced, nothing to do
        break;
      case FhirSyncStatus.dirty:
        // Manually trigger sync
        ref.read(fhirSyncServiceProvider).manuallySyncAllData();
        break;
      case FhirSyncStatus.syncing:
        // Show a message that sync is in progress
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync is already in progress'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case FhirSyncStatus.offline:
        // Show a message about being offline
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are offline. Please connect to the internet to sync'),
            duration: Duration(seconds: 3),
          ),
        );
        break;
      case FhirSyncStatus.error:
        // Show error details and retry option
        final errorMessage = ref.read(fhirSyncLastErrorMessageProvider);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sync Error'),
            content: Text(errorMessage ?? 'An unknown error occurred while syncing with the FHIR server'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('DISMISS'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(fhirSyncServiceProvider).manuallySyncAllData();
                },
                child: const Text('RETRY'),
              ),
            ],
          ),
        );
        break;
    }
  }
}