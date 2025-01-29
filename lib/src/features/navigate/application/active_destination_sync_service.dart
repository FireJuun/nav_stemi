import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_destination_sync_service.g.dart';

/// Listens for changes in the destination provider
/// When that occurs, it will use the Google Navigation SDK
/// to calculate a route to the destination and update the
/// route provider with the new route.
class ActiveDestinationSyncService {
  ActiveDestinationSyncService(this.ref) {
    _init();
  }

  final Ref ref;

  PermissionsRepository get _permissionsRepository =>
      ref.read(permissionsRepositoryProvider);
  GoogleNavigationService get _googleNavigationService =>
      ref.read(googleNavigationServiceProvider);

  void _init() {
    ref
      ..listen<AsyncValue<bool?>>(mapSessionReadyProvider,
          (previous, next) async {
        /// This typically happens first in the workflow.
        /// MapSessionReady is set to true by the viewController.
        /// If the map is ready and a destination is set, start navigation.

        final isMapReady = next.value ?? false;
        final destination = ref.read(activeDestinationProvider).value;
        if (isMapReady && destination != null) {
          await startNavigationIfInitialized();
        }
      })
      ..listen<AsyncValue<ActiveDestination?>>(activeDestinationProvider,
          (previous, next) async {
        /// If the destination changes (while the map is still open),
        /// start navigating to this new destination instead.
        final destination = next.value;

        if (destination == null || destination == previous?.value) {
          return;
        }

        await startNavigationIfInitialized();
      });
  }

  @visibleForTesting
  Future<void> startNavigationIfInitialized() async {
    final isLocationAvailable =
        await _permissionsRepository.isLocationServiceEnabled();
    final isInitialized = await _googleNavigationService.isInitialized();

    if (isInitialized && isLocationAvailable) {
      await _googleNavigationService.calculateDestinationRoutes();
      await _googleNavigationService.startDrivingDirections();
    }
  }
}

@Riverpod(keepAlive: true)
ActiveDestinationSyncService activeDestinationSyncService(Ref ref) {
  return ActiveDestinationSyncService(ref);
}
