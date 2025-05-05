import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remote_routes_repository.g.dart';

abstract class RemoteRoutesRepository {
  /// When provided a list of hospitals that are near
  /// the current geolocation, get the distance and route duration for each.
  ///
  /// Note that distanceBetween is the direct distance between the two points,
  /// whereas routeDistance is the distance of the route considering roads.
  ///
  /// This is a batch request, so only one API call is made.
  Future<NearbyHospitals> getDistanceInfoFromHospitalList({
    required AppWaypoint origin,
    required Map<Hospital, double> hospitalListAndDistances,
  }) async =>
      throw UnimplementedError();

  /// Get available routes for a single hospital
  /// This includes alternate routes, so only one API call is made
  Future<AvailableRoutes> getAvailableRoutesForSingleHospital({
    required AppWaypoint origin,
    required AppWaypoint destination,
    required Hospital destinationInfo,
  }) async =>
      throw UnimplementedError();
}

@riverpod
RemoteRoutesRepository remoteRoutesRepository(Ref ref) =>
    throw UnimplementedError();
