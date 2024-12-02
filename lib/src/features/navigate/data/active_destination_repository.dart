import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_destination_repository.g.dart';

/// Tracks if a destination has been set by the user.
/// Ties this destination to [EdInfo] metadata.
/// If a destination is set, the user can navigate to it.
class ActiveDestinationRepository {
  final _store = InMemoryStore<ActiveDestination?>(null);
  ActiveDestination? get activeDestination => _store.value;
  set activeDestination(ActiveDestination? value) => _store.value = value;

  Stream<ActiveDestination?> watchDestinations() => _store.stream;
}

@Riverpod(keepAlive: true)
ActiveDestinationRepository activeDestinationRepository(
  ActiveDestinationRepositoryRef ref,
) {
  return ActiveDestinationRepository();
}

@Riverpod(keepAlive: true)
Stream<ActiveDestination?> activeDestination(ActiveDestinationRef ref) {
  return ref.watch(activeDestinationRepositoryProvider).watchDestinations();
}
