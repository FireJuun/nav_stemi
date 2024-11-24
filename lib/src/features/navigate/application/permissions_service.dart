import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
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
    await checkLocationPermissions();
    await checkNotificationPermissions();
    await geolocatorRepository.checkLocationEnabled();
    await geolocatorRepository.getLastKnownPosition();
  }

  Future<
      ({
        LocationsPermitted areLocationsPermitted,
        NotificationsPermitted areNotificationsPermitted
      })> checkPermissionsOnAppStart() async {
    final locationsPermitted = await checkLocationPermissions();
    final notificationsPermitted = await checkNotificationPermissions();
    await googleNavigationService.checkTermsAccepted();

    return (
      areLocationsPermitted: locationsPermitted,
      areNotificationsPermitted: notificationsPermitted
    );
  }

  @visibleForTesting
  Future<LocationsPermitted> checkLocationPermissions() async {
    final areLocationsPermitted =
        await permissionsRepository.areLocationsPermitted();
    if (areLocationsPermitted) {
      return true;
    } else {
      final granted = await permissionsRepository.requestLocationPermission();
      return granted;
    }
  }

  @visibleForTesting
  Future<NotificationsPermitted> checkNotificationPermissions() async {
    final areNotificationsPermitted =
        await permissionsRepository.areNotificationsPermitted();

    if (areNotificationsPermitted) {
      return true;
    } else {
      final granted =
          await permissionsRepository.requestNotificationPermission();
      return granted;
    }
  }
}

@Riverpod(keepAlive: true)
PermissionsService permissionsService(PermissionsServiceRef ref) {
  return PermissionsService(ref);
}
