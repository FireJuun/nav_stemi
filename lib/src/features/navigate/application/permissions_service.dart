import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permissions_service.g.dart';

typedef LocationsPermitted = bool;
typedef NotificationsPermitted = bool;

class PermissionsService {
  const PermissionsService(this.ref);

  final Ref ref;

  GeolocatorRepository get geolocatorRepository =>
      ref.read(geolocatorRepositoryProvider);
  GoogleNavigationService get googleNavigationService =>
      ref.read(googleNavigationServiceProvider);
  PermissionsRepository get permissionsRepository =>
      ref.read(permissionsRepositoryProvider);

  Future<void> initialize() async {
    await checkPermissionsOnAppStart();
    await geolocatorRepository.checkLocationEnabled();
    await geolocatorRepository.getLastKnownPosition();
  }

  Future<
      ({
        LocationsPermitted areLocationsPermitted,
        NotificationsPermitted areNotificationsPermitted
      })> checkPermissionsOnAppStart() async {
    final statuses = await permissionsRepository.checkAppPermissions();

    await googleNavigationService.checkTermsAccepted();

    final locationsPermitted =
        statuses[Permission.locationWhenInUse]!.isGranted;
    final notificationsPermitted = statuses[Permission.notification]!.isGranted;

    return (
      areLocationsPermitted: locationsPermitted,
      areNotificationsPermitted: notificationsPermitted
    );
  }

  Future<void> openAppSettingsPage() async {
    await permissionsRepository.openAppSettingsPage();
  }
}

@riverpod
PermissionsService permissionsService(Ref ref) {
  return PermissionsService(ref);
}
