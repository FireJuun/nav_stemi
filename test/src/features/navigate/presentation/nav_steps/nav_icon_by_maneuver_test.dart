import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/src/features/navigate/presentation/nav_steps/nav_icon_by_maneuver.dart';

void main() {
  group('NavIconByManeuver', () {
    Widget createTestWidget(Maneuver maneuver) {
      return MaterialApp(
        home: Scaffold(
          body: NavIconByManeuver(maneuver),
        ),
      );
    }

    testWidgets('should display turn_left icon for left turn maneuvers',
        (tester) async {
      final leftTurnManeuvers = [
        Maneuver.turnLeft,
        Maneuver.turnKeepLeft,
      ];

      for (final maneuver in leftTurnManeuvers) {
        await tester.pumpWidget(createTestWidget(maneuver));
        expect(find.byIcon(Icons.turn_left), findsOneWidget);
      }
    });

    testWidgets('should display ramp_left icon for left ramp maneuvers',
        (tester) async {
      final leftRampManeuvers = [
        Maneuver.onRampLeft,
        Maneuver.onRampKeepLeft,
        Maneuver.onRampSharpLeft,
        Maneuver.onRampSlightLeft,
        Maneuver.offRampLeft,
        Maneuver.offRampKeepLeft,
        Maneuver.offRampSharpLeft,
        Maneuver.offRampSlightLeft,
      ];

      for (final maneuver in leftRampManeuvers) {
        await tester.pumpWidget(createTestWidget(maneuver));
        expect(find.byIcon(Icons.ramp_left), findsOneWidget);
      }
    });

    testWidgets('should display fork_left icon for fork left', (tester) async {
      await tester.pumpWidget(createTestWidget(Maneuver.forkLeft));
      expect(find.byIcon(Icons.fork_left), findsOneWidget);
    });

    testWidgets('should display turn_slight_left icon for slight left turn',
        (tester) async {
      await tester.pumpWidget(createTestWidget(Maneuver.turnSlightLeft));
      expect(find.byIcon(Icons.turn_slight_left), findsOneWidget);
    });

    testWidgets('should display turn_sharp_left icon for sharp left turn',
        (tester) async {
      await tester.pumpWidget(createTestWidget(Maneuver.turnSharpLeft));
      expect(find.byIcon(Icons.turn_sharp_left), findsOneWidget);
    });

    testWidgets(
        'should display roundabout_left icon for counterclockwise roundabouts',
        (tester) async {
      final counterclockwiseRoundabouts = [
        Maneuver.roundaboutCounterclockwise,
        Maneuver.roundaboutExitCounterclockwise,
        Maneuver.roundaboutLeftCounterclockwise,
        Maneuver.roundaboutRightCounterclockwise,
        Maneuver.roundaboutSharpLeftCounterclockwise,
        Maneuver.roundaboutSharpRightCounterclockwise,
        Maneuver.roundaboutSlightLeftCounterclockwise,
        Maneuver.roundaboutSlightRightCounterclockwise,
        Maneuver.roundaboutStraightCounterclockwise,
        Maneuver.roundaboutUTurnCounterclockwise,
      ];

      for (final maneuver in counterclockwiseRoundabouts) {
        await tester.pumpWidget(createTestWidget(maneuver));
        expect(find.byIcon(Icons.roundabout_left), findsOneWidget);
      }
    });

    testWidgets('should display u_turn_left icon for counterclockwise U-turn',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(Maneuver.turnUTurnCounterclockwise),
      );
      expect(find.byIcon(Icons.u_turn_left), findsOneWidget);
    });

    testWidgets('should display turn_right icon for right turn maneuvers',
        (tester) async {
      final rightTurnManeuvers = [
        Maneuver.turnRight,
        Maneuver.turnKeepRight,
      ];

      for (final maneuver in rightTurnManeuvers) {
        await tester.pumpWidget(createTestWidget(maneuver));
        expect(find.byIcon(Icons.turn_right), findsOneWidget);
      }
    });

    testWidgets('should display ramp_right icon for right ramp maneuvers',
        (tester) async {
      final rightRampManeuvers = [
        Maneuver.onRampRight,
        Maneuver.onRampKeepRight,
        Maneuver.onRampSharpRight,
        Maneuver.onRampSlightRight,
        Maneuver.offRampRight,
        Maneuver.offRampKeepRight,
        Maneuver.offRampSharpRight,
        Maneuver.offRampSlightRight,
      ];

      for (final maneuver in rightRampManeuvers) {
        await tester.pumpWidget(createTestWidget(maneuver));
        expect(find.byIcon(Icons.ramp_right), findsOneWidget);
      }
    });

    testWidgets('should display fork_right icon for fork right',
        (tester) async {
      await tester.pumpWidget(createTestWidget(Maneuver.forkRight));
      expect(find.byIcon(Icons.fork_right), findsOneWidget);
    });

    testWidgets('should display turn_slight_right icon for slight right turn',
        (tester) async {
      await tester.pumpWidget(createTestWidget(Maneuver.turnSlightRight));
      expect(find.byIcon(Icons.turn_slight_right), findsOneWidget);
    });

    testWidgets('should display turn_sharp_right icon for sharp right turn',
        (tester) async {
      await tester.pumpWidget(createTestWidget(Maneuver.turnSharpRight));
      expect(find.byIcon(Icons.turn_sharp_right), findsOneWidget);
    });

    testWidgets(
        'should display roundabout_right icon for clockwise roundabouts',
        (tester) async {
      final clockwiseRoundabouts = [
        Maneuver.roundaboutClockwise,
        Maneuver.roundaboutExitClockwise,
        Maneuver.roundaboutLeftClockwise,
        Maneuver.roundaboutRightClockwise,
        Maneuver.roundaboutSharpLeftClockwise,
        Maneuver.roundaboutSharpRightClockwise,
        Maneuver.roundaboutSlightLeftClockwise,
        Maneuver.roundaboutSlightRightClockwise,
        Maneuver.roundaboutStraightClockwise,
        Maneuver.roundaboutUTurnClockwise,
      ];

      for (final maneuver in clockwiseRoundabouts) {
        await tester.pumpWidget(createTestWidget(maneuver));
        expect(find.byIcon(Icons.roundabout_right), findsOneWidget);
      }
    });

    testWidgets('should display u_turn_right icon for clockwise U-turn',
        (tester) async {
      await tester.pumpWidget(createTestWidget(Maneuver.turnUTurnClockwise));
      expect(find.byIcon(Icons.u_turn_right), findsOneWidget);
    });

    testWidgets('should display merge icon for merge maneuvers',
        (tester) async {
      final mergeManeuvers = [
        Maneuver.mergeLeft,
        Maneuver.mergeRight,
        Maneuver.mergeUnspecified,
      ];

      for (final maneuver in mergeManeuvers) {
        await tester.pumpWidget(createTestWidget(maneuver));
        expect(find.byIcon(Icons.merge), findsOneWidget);
      }
    });

    testWidgets('should display straight icon for straight maneuver',
        (tester) async {
      await tester.pumpWidget(createTestWidget(Maneuver.straight));
      expect(find.byIcon(Icons.straight), findsOneWidget);
    });

    testWidgets('should display directions_boat icon for ferry boat',
        (tester) async {
      await tester.pumpWidget(createTestWidget(Maneuver.ferryBoat));
      expect(find.byIcon(Icons.directions_boat), findsOneWidget);
    });

    testWidgets('should display directions_train icon for ferry train',
        (tester) async {
      await tester.pumpWidget(createTestWidget(Maneuver.ferryTrain));
      expect(find.byIcon(Icons.directions_train), findsOneWidget);
    });

    testWidgets('should display directions_car icon for depart',
        (tester) async {
      await tester.pumpWidget(createTestWidget(Maneuver.depart));
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });

    testWidgets('should display signpost icon for name change', (tester) async {
      await tester.pumpWidget(createTestWidget(Maneuver.nameChange));
      expect(find.byIcon(Icons.signpost), findsOneWidget);
    });

    testWidgets(
        'should display arrow_circle_down_outlined icon for destination',
        (tester) async {
      await tester.pumpWidget(createTestWidget(Maneuver.destination));
      expect(find.byIcon(Icons.arrow_circle_down_outlined), findsOneWidget);
    });

    testWidgets(
        'should display arrow_circle_left_outlined icon for destination left',
        (tester) async {
      await tester.pumpWidget(createTestWidget(Maneuver.destinationLeft));
      expect(find.byIcon(Icons.arrow_circle_left_outlined), findsOneWidget);
    });

    testWidgets(
        'should display arrow_circle_right_outlined icon for destination right',
        (tester) async {
      await tester.pumpWidget(createTestWidget(Maneuver.destinationRight));
      expect(find.byIcon(Icons.arrow_circle_right_outlined), findsOneWidget);
    });

    testWidgets('should display question_mark icon for unknown maneuvers',
        (tester) async {
      final unknownManeuvers = [
        Maneuver.unknown,
        Maneuver.onRampUnspecified,
        Maneuver.onRampUTurnClockwise,
        Maneuver.onRampUTurnCounterclockwise,
        Maneuver.offRampUnspecified,
        Maneuver.offRampUTurnClockwise,
        Maneuver.offRampUTurnCounterclockwise,
      ];

      for (final maneuver in unknownManeuvers) {
        await tester.pumpWidget(createTestWidget(maneuver));
        expect(find.byIcon(Icons.question_mark), findsOneWidget);
      }
    });

    testWidgets('should render NavIconByManeuver widget', (tester) async {
      await tester.pumpWidget(createTestWidget(Maneuver.straight));
      expect(find.byType(NavIconByManeuver), findsOneWidget);
    });

    testWidgets('should render Icon widget', (tester) async {
      await tester.pumpWidget(createTestWidget(Maneuver.straight));
      expect(find.byType(Icon), findsOneWidget);
    });
  });
}
