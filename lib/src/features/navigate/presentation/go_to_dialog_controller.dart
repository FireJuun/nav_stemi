import 'dart:async';

import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'go_to_dialog_controller.g.dart';

@riverpod
class GoToDialogController extends _$GoToDialogController with NotifierMounted {
  @override
  FutureOr<void> build() {
    // nothing to do
    state = const AsyncData(null);
    ref.onDispose(setUnmounted);
  }

  Future<void> goToEd({
    required NearbyEd activeEd,
    required NearbyEds nearbyEds,
  }) async {
    // nothing to do
    state = const AsyncLoading();
    try {
      unawaited(
        ref
            .read(routeServiceProvider)
            .goToEd(activeEd: activeEd, nearbyEds: nearbyEds)
            .then(
              (_) => ref.read(googleNavigationServiceProvider).startGuidance(),
            ),
      );

      ref.read(goRouterProvider).goNamed(AppRoute.nav.name);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
