import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permissions_repository.g.dart';

typedef LocationPermissionsAccepted = bool;
typedef NotificationPermissionsAccepted = bool;

class PermissionsRepository {
  Future<LocationPermissionsAccepted> areLocationsPermitted() async {
    final locationPermission = await Permission.location.status;
    return locationPermission == PermissionStatus.granted;
  }

  Future<LocationPermissionsAccepted> requestLocationPermission() async {
    final locationPermission = await Permission.locationWhenInUse.request();
    return locationPermission == PermissionStatus.granted;
  }

  Future<NotificationPermissionsAccepted> areNotificationsPermitted() async {
    final notificationPermission = await Permission.notification.status;
    return notificationPermission == PermissionStatus.granted;
  }

  Future<NotificationPermissionsAccepted>
      requestNotificationPermission() async {
    final notificationPermission = await Permission.notification.request();
    return notificationPermission == PermissionStatus.granted;
  }
}

@riverpod
PermissionsRepository permissionsRepository(PermissionsRepositoryRef ref) {
  return PermissionsRepository();
}
