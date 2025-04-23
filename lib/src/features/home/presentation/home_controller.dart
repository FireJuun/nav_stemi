import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController with NotifierMounted {
  @override
  FutureOr<void> build() {
    /// nothing to do
    state = const AsyncData(null);
    ref.onDispose(setUnmounted);
  }

  PermissionsService get _permissionsServiceProvider =>
      ref.read(permissionsServiceProvider);

  Future<
          ({
            LocationsPermitted areLocationsPermitted,
            NotificationsPermitted areNotificationsPermitted,
          })>
      checkPermissionsOnAppStart() =>
          _permissionsServiceProvider.checkPermissionsOnAppStart();

  Future<void> openAppSettingsPage() =>
      _permissionsServiceProvider.openAppSettingsPage();
}
