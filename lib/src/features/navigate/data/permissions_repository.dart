import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permissions_repository.g.dart';

class PermissionsRepository {
  Future<Map<Permission, PermissionStatus>> checkAppPermissions() async {
    final statuses =
        await [Permission.locationWhenInUse, Permission.notification].request();
    return statuses;
  }

  Future<bool> openAppSettingsPage() => openAppSettings();

  Future<bool> isLocationServiceEnabled() async =>
      Permission.location.serviceStatus.isEnabled;
}

@riverpod
PermissionsRepository permissionsRepository(Ref ref) {
  return PermissionsRepository();
}
