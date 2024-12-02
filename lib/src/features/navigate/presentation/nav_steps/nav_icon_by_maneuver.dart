import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';

class NavIconByManeuver extends StatelessWidget {
  const NavIconByManeuver(this.maneuver, {super.key});

  final Maneuver maneuver;

  @override
  Widget build(BuildContext context) {
    switch (maneuver) {
      /// Left turns
      case Maneuver.turnLeft:
      case Maneuver.turnKeepLeft:
        return const Icon(Icons.turn_left);
      case Maneuver.onRampLeft:
      case Maneuver.onRampKeepLeft:
      case Maneuver.onRampSharpLeft:
      case Maneuver.onRampSlightLeft:
        return const Icon(Icons.ramp_left);
      case Maneuver.offRampLeft:
      case Maneuver.offRampKeepLeft:
      case Maneuver.offRampSharpLeft:
      case Maneuver.offRampSlightLeft:
        return const Icon(Icons.ramp_left);
      case Maneuver.forkLeft:
        return const Icon(Icons.fork_left);
      case Maneuver.turnSlightLeft:
        return const Icon(Icons.turn_slight_left);
      case Maneuver.turnSharpLeft:
        return const Icon(Icons.turn_sharp_left);

      /// Counter-clockwise == left turns
      case Maneuver.roundaboutCounterclockwise:
      case Maneuver.roundaboutExitCounterclockwise:
      case Maneuver.roundaboutLeftCounterclockwise:
      case Maneuver.roundaboutRightCounterclockwise:
      case Maneuver.roundaboutSharpLeftCounterclockwise:
      case Maneuver.roundaboutSharpRightCounterclockwise:
      case Maneuver.roundaboutSlightLeftCounterclockwise:
      case Maneuver.roundaboutSlightRightCounterclockwise:
      case Maneuver.roundaboutStraightCounterclockwise:
      case Maneuver.roundaboutUTurnCounterclockwise:
        return const Icon(Icons.roundabout_left);
      case Maneuver.turnUTurnCounterclockwise:
        return const Icon(Icons.u_turn_left);

      /// Right turns
      case Maneuver.turnRight:
      case Maneuver.turnKeepRight:
        return const Icon(Icons.turn_right);
      case Maneuver.onRampRight:
      case Maneuver.onRampKeepRight:
      case Maneuver.onRampSharpRight:
      case Maneuver.onRampSlightRight:
        return const Icon(Icons.ramp_right);
      case Maneuver.offRampRight:
      case Maneuver.offRampKeepRight:
      case Maneuver.offRampSharpRight:
      case Maneuver.offRampSlightRight:
        return const Icon(Icons.ramp_right);
      case Maneuver.forkRight:
        return const Icon(Icons.fork_right);
      case Maneuver.turnSlightRight:
        return const Icon(Icons.turn_slight_right);
      case Maneuver.turnSharpRight:
        return const Icon(Icons.turn_sharp_right);

      /// Clockwise == right turns
      case Maneuver.roundaboutClockwise:
      case Maneuver.roundaboutExitClockwise:
      case Maneuver.roundaboutLeftClockwise:
      case Maneuver.roundaboutRightClockwise:
      case Maneuver.roundaboutSharpLeftClockwise:
      case Maneuver.roundaboutSharpRightClockwise:
      case Maneuver.roundaboutSlightLeftClockwise:
      case Maneuver.roundaboutSlightRightClockwise:
      case Maneuver.roundaboutStraightClockwise:
      case Maneuver.roundaboutUTurnClockwise:
        return const Icon(Icons.roundabout_right);
      case Maneuver.turnUTurnClockwise:
        return const Icon(Icons.u_turn_right);

      /// Other maneuvers
      case Maneuver.mergeLeft:
      case Maneuver.mergeRight:
      case Maneuver.mergeUnspecified:
        return const Icon(Icons.merge);
      case Maneuver.straight:
        return const Icon(Icons.straight);
      case Maneuver.ferryBoat:
        return const Icon(Icons.directions_boat);
      case Maneuver.ferryTrain:
        return const Icon(Icons.directions_train);
      case Maneuver.depart:
        return const Icon(Icons.directions_car);
      case Maneuver.nameChange:
        return const Icon(Icons.signpost);

      /// Destination maneuvers
      case Maneuver.destination:
        return const Icon(Icons.arrow_circle_down_outlined);
      case Maneuver.destinationLeft:
        return const Icon(Icons.arrow_circle_left_outlined);
      case Maneuver.destinationRight:
        return const Icon(Icons.arrow_circle_right_outlined);

      /// Unknown maneuvers
      case Maneuver.unknown:
      case Maneuver.onRampUnspecified:
      case Maneuver.onRampUTurnClockwise:
      case Maneuver.onRampUTurnCounterclockwise:
      case Maneuver.offRampUnspecified:
      case Maneuver.offRampUTurnClockwise:
      case Maneuver.offRampUTurnCounterclockwise:
        return const Icon(Icons.question_mark);
    }
  }
}
