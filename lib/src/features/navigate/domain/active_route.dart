import 'package:equatable/equatable.dart';
import 'package:google_routes_flutter/google_routes_flutter.dart';

typedef ActiveRouteId = Polyline;
typedef ActiveStepId = Polyline;

/// Determines which point of interest is nearest to the
/// user's current location.
enum ActiveOption { pciCenter, ed, other, none }

class ActiveRoute extends Equatable {
  const ActiveRoute({
    required this.activeRouteId,
    required this.activeStepId,
    this.nearestOption = ActiveOption.none,
  });

  final ActiveRouteId activeRouteId;
  final ActiveStepId activeStepId;
  final ActiveOption nearestOption;

  ActiveRoute copyWith({
    ActiveRouteId? activeRouteId,
    ActiveStepId? activeStepId,
    ActiveOption? nearestOption,
  }) {
    return ActiveRoute(
      activeRouteId: activeRouteId ?? this.activeRouteId,
      activeStepId: activeStepId ?? this.activeStepId,
      nearestOption: nearestOption ?? this.nearestOption,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [activeRouteId, activeStepId, nearestOption];
}
