import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_destination_repository.g.dart';

/// Tracks if a destination has been set by the user.
/// Ties this destination to [Hospital] metadata.
/// If a destination is set, the user can navigate to it.
class ActiveDestinationRepository {
  final _store = InMemoryStore<ActiveDestination?>(null);
  ActiveDestination? get activeDestination => _store.value;
  set activeDestination(ActiveDestination? value) => _store.value = value;

  Stream<ActiveDestination?> watchDestinations() => _store.stream;
}

@riverpod
ActiveDestinationRepository activeDestinationRepository(Ref ref) {
  return ActiveDestinationRepository();
}

@riverpod
Stream<ActiveDestination?> activeDestination(Ref ref) {
  return ref.watch(activeDestinationRepositoryProvider).watchDestinations();
}
