import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  void build() {
    /// nothing to do
    return;
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
