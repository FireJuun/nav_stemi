import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

class MockStepInfo extends Mock implements StepInfo {}

void main() {
  final stepInfo = StepInfo(
    maneuver: Maneuver.depart,
    lanes: [],
    roundaboutTurnNumber: 0,
    stepNumber: 0,
    simpleRoadName: '',
    fullRoadName: 'Main Street',
    fullInstructions: 'Full instructions',
    exitNumber: null,
    distanceFromPrevStepMeters: 500,
    timeFromPrevStepSeconds: 0,
    drivingSide: DrivingSide.right,
  );

  group('NextStep', () {
    late MockStepInfo mockStepInfo;

    setUp(() {
      mockStepInfo = MockStepInfo();
    });

    testWidgets('should display next step info when available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NextStep(
              routeLegStep: stepInfo,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(NavIconByManeuver), findsOneWidget);
      expect(find.text('Full instructions'), findsOneWidget);
      expect(find.text('500 m'), findsOneWidget);
    });

    testWidgets('should display distance in kilometers for long distances',
        (tester) async {
      when(() => mockStepInfo.fullRoadName).thenReturn('Interstate 95');
      when(() => mockStepInfo.fullInstructions).thenReturn('Full instructions');
      when(() => mockStepInfo.maneuver).thenReturn(Maneuver.straight);
      when(() => mockStepInfo.distanceFromPrevStepMeters).thenReturn(55);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NextStep(
              routeLegStep: mockStepInfo,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('55 m'), findsOneWidget);
    });
  });
}
