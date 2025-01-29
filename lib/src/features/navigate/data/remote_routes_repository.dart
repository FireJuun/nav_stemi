import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    required AppWaypoint origin,
    required Map<EdInfo, double> edListAndDistances,
  }) async =>
      throw UnimplementedError();

  /// Get available routes for a single emergency department
  /// This includes alternate routes, so only one API call is made
  Future<AvailableRoutes> getAvailableRoutesForSingleED({
    required AppWaypoint origin,
    required AppWaypoint destination,
    required EdInfo destinationInfo,
  }) async =>
      throw UnimplementedError();
}

@Riverpod(keepAlive: true)
RemoteRoutesRepository remoteRoutesRepository(Ref ref) =>
    throw UnimplementedError();
