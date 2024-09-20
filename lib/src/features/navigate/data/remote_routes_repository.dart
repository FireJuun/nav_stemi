// ignore_for_file: lines_longer_than_80_chars

import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remote_routes_repository.g.dart';

abstract class RemoteRoutesRepository {
  /// When provided a list of emergency departments that are near
  /// the current geolocation, get the distance and route duration for each.
  ///
  /// Note that distanceBetween is the direct distance between the two points,
  /// whereas routeDistance is the distance of the route considering roads.
  ///
  /// This is a batch request, so only one API call is made.
  Future<NearbyEds> getDistanceInfoFromEdList({
    required maps.LatLng origin,
    required Map<EdInfo, double> edListAndDistances,
  }) async =>
      throw UnimplementedError();

  /// Get available routes for a single emergency department
  /// This includes alternate routes, so only one API call is made
  Future<AvailableRoutes> getAvailableRoutesForSingleED({
    required maps.LatLng origin,
    required maps.LatLng destination,
    required EdInfo destinationInfo,
  }) async =>
      throw UnimplementedError();
}

@Riverpod(keepAlive: true)
RemoteRoutesRepository remoteRoutesRepository(RemoteRoutesRepositoryRef ref) =>
    throw UnimplementedError();
