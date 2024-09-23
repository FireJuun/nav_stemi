import 'package:collection/collection.dart';
import 'package:google_routes_flutter/google_routes_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

extension RouteX on Route {
  /// First check to see if route legs has one or multiple values
  /// Then, add each step in sequential order.
  ///
  /// This produces an expanded list of all RouteLegSteps
  /// for a given [Route]
  List<RouteLegStep> routeSteps() {
    if (legs == null) {
      return [];
    }

    final routeLegSteps = <RouteLegStep>[];

    for (final leg in legs!) {
      final legSteps = leg.steps;
      if (legSteps != null) {
        routeLegSteps.addAll(legSteps);
      }
    }
    return routeLegSteps;
  }

  /// Find the step based on the [ActiveStepId], which is an encoded polyline
  RouteLegStep? routeStepById(ActiveStepId routeStepId) {
    final routeLegSteps = routeSteps()
        .firstWhereOrNull((e) => e.polyline?.encodedPolyline == routeStepId);

    return routeLegSteps;
  }
}

/// Extension methods for a given route step
extension RouteLegStepX on RouteLegStep {
  /// Puts all values in one location, to make it easier to get info
  /// about a given step
  ({Maneuver maneuver, String instructions, String distance, String duration})
      relevantValues() {
    return (
      maneuver: navigationInstruction?.maneuver ?? Maneuver.maneuverUnspecified,
      instructions: navigationInstruction?.instructions ?? '--',
      distance: localizedValues?.distance?.text ?? '--',
      duration: localizedValues?.staticDuration?.text ?? '--'
    );
  }
}
