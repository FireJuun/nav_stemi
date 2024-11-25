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

  void _init() {
    ref.listen<AsyncValue<ActiveDestination?>>(activeDestinationProvider,
        (previous, next) {
      // TODO(FireJuun): handle new destination state
    });
  }
}

@Riverpod(keepAlive: true)
ActiveDestinationSyncService activeDestinationSyncService(
  ActiveDestinationSyncServiceRef ref,
) {
  return ActiveDestinationSyncService(ref);
}
