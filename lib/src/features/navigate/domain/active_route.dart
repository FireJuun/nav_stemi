import 'package:equatable/equatable.dart';
import 'package:google_routes_flutter/google_routes_flutter.dart';

typedef EncodedPolyline = String;
typedef ActiveRouteId = EncodedPolyline;
typedef ActiveStepId = EncodedPolyline;

class ActiveRoute extends Equatable {
  const ActiveRoute({
    required this.route,
    required this.activeStepId,
  });

  final Route route;
  final ActiveStepId activeStepId;

  ActiveRoute copyWith({
    ActiveRouteId? activeRouteId,
    ActiveStepId? activeStepId,
  }) {
    return ActiveRoute(
      route: route,
      activeStepId: activeStepId ?? this.activeStepId,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [route, activeStepId];
}
