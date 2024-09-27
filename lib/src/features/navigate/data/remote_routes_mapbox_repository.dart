import 'package:nav_stemi/nav_stemi.dart';

class RemoteRoutesMapboxRepository implements RemoteRoutesRepository {
  @override
  Future<AvailableRoutes> getAvailableRoutesForSingleED(
      {required AppWaypoint origin,
      required AppWaypoint destination,
      required EdInfo destinationInfo}) {
    // TODO: implement getAvailableRoutesForSingleED
    throw UnimplementedError();
  }

  @override
  Future<NearbyEds> getDistanceInfoFromEdList(
      {required AppWaypoint origin,
      required Map<EdInfo, double> edListAndDistances}) {
    // TODO: implement getDistanceInfoFromEdList
    throw UnimplementedError();
  }
}
