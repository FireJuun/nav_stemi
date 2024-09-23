import 'package:flutter/material.dart';
import 'package:google_routes_flutter/google_routes_flutter.dart';

class NavIconByManeuver extends StatelessWidget {
  const NavIconByManeuver(this.maneuver, {super.key});

  final Maneuver maneuver;

  @override
  Widget build(BuildContext context) {
    switch (maneuver) {
      /// Left turns
      case Maneuver.turnLeft:
        return const Icon(Icons.turn_left);
      case Maneuver.rampLeft:
        return const Icon(Icons.ramp_left);
      case Maneuver.forkLeft:
        return const Icon(Icons.fork_left);
      case Maneuver.roundaboutLeft:
        return const Icon(Icons.roundabout_left);
      case Maneuver.turnSlightLeft:
        return const Icon(Icons.turn_slight_left);
      case Maneuver.turnSharpLeft:
        return const Icon(Icons.turn_sharp_left);
      case Maneuver.uTurnLeft:
        return const Icon(Icons.u_turn_left);

      /// Right turns
      case Maneuver.turnRight:
        return const Icon(Icons.turn_right);
      case Maneuver.rampRight:
        return const Icon(Icons.ramp_right);
      case Maneuver.forkRight:
        return const Icon(Icons.fork_right);
      case Maneuver.roundaboutRight:
        return const Icon(Icons.roundabout_right);
      case Maneuver.turnSlightRight:
        return const Icon(Icons.turn_slight_right);
      case Maneuver.turnSharpRight:
        return const Icon(Icons.turn_sharp_right);
      case Maneuver.uTurnRight:
        return const Icon(Icons.u_turn_right);

      /// Other maneuvers
      case Maneuver.merge:
        return const Icon(Icons.merge);
      case Maneuver.straight:
        return const Icon(Icons.straight);
      case Maneuver.ferry:
        return const Icon(Icons.directions_boat);
      case Maneuver.ferryTrain:
        return const Icon(Icons.directions_train);
      case Maneuver.depart:
        return const Icon(Icons.directions_car);
      case Maneuver.nameChange:
        return const Icon(Icons.signpost);

      /// Unknown maneuvers
      case Maneuver.maneuverUnspecified:
        return const Icon(Icons.question_mark);
    }
  }
}
