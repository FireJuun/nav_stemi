import 'package:equatable/equatable.dart';
import 'package:google_routes_flutter/google_routes_flutter.dart';

typedef ActiveRouteId = Polyline;
typedef ActiveStepId = Polyline;

/// Determines which point of interest is nearest to the
/// user's current location.
enum RouteOption { pciCenter, ed, other, none }

class ActiveRoute extends Equatable {
  const ActiveRoute({
    required this.activeRouteId,
    required this.activeStepId,
    this.routeOption = RouteOption.none,
  });

  final ActiveRouteId activeRouteId;
  final ActiveStepId activeStepId;
  final RouteOption routeOption;

  ActiveRoute copyWith({
    ActiveRouteId? activeRouteId,
    ActiveStepId? activeStepId,
    RouteOption? routeOption,
  }) {
    return ActiveRoute(
      activeRouteId: activeRouteId ?? this.activeRouteId,
      activeStepId: activeStepId ?? this.activeStepId,
      routeOption: routeOption ?? this.routeOption,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [activeRouteId, activeStepId, routeOption];
}
