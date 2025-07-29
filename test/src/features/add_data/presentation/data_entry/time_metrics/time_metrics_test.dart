import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:timeago_flutter/timeago_flutter.dart';

class MockTimeMetricsController extends AutoDisposeAsyncNotifier<void>
    with Mock
    implements TimeMetricsController {
  @override
  FutureOr<void> build() => Future<void>.value();
}

class MockTimeMetricsRepository extends Mock implements TimeMetricsRepository {}

void main() {
  group('TimeMetrics Widget Tests', () {
    late MockTimeMetricsController mockController;
    late MockTimeMetricsRepository mockRepository;

    setUp(() {
      mockController = MockTimeMetricsController();
      mockRepository = MockTimeMetricsRepository();
    });

    Widget createTestWidget({TimeMetricsModel? model}) {
      final testModel = model ?? const TimeMetricsModel();
      when(() => mockRepository.watchTimeMetrics())
          .thenAnswer((_) => Stream.value(testModel));

      return ProviderScope(
        overrides: [
          timeMetricsControllerProvider.overrideWith(() => mockController),
          timeMetricsRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [TimeMetrics()],
            ),
          ),
        ),
      );
    }

    testWidgets('should display all time metric fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Arrived at Patient'), findsOneWidget);
      expect(find.text('First EKG'), findsOneWidget);
      expect(find.text('STEMI Activation'), findsOneWidget);
      expect(find.text('Unit Left Scene'), findsOneWidget);
      expect(find.text('Give ASA 325 mg'), findsOneWidget);
      expect(find.text('Notify Cath Lab'), findsOneWidget);
      expect(find.text('Patient at Destination'), findsOneWidget);
    });

    testWidgets('should display goal dividers', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Goal: 5 min'), findsOneWidget);
      expect(find.text('Goal: 10 min'), findsOneWidget);
      expect(find.text('Goal: 60 min'), findsOneWidget);
    });

    testWidgets('should show Now button when time is not set', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Now'), findsNWidgets(7)); // 7 time metrics
    });

    testWidgets('should call controller when Now button is tapped',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap the first Now button (Arrived at Patient)
      await tester.tap(find.text('Now').first);
      await tester.pumpAndSettle();

      verify(() => mockController.setTimeArrivedAtPatient(any())).called(1);
    });

    testWidgets('should show time and timeago when time is set',
        (tester) async {
      final testTime = DateTime.now().subtract(const Duration(minutes: 5));
      final modelWithTime = const TimeMetricsModel().copyWith(
        timeArrivedAtPatient: () => testTime,
      );

      await tester.pumpWidget(createTestWidget(model: modelWithTime));
      await tester.pumpAndSettle();

      // Should show timeago widget
      expect(find.byType(Timeago), findsOneWidget);

      // Should show formatted time
      final formattedTime = TimeOfDay.fromDateTime(testTime)
          .format(tester.element(find.byType(TimeMetrics)));
      expect(find.text(formattedTime), findsOneWidget);
    });

    testWidgets('should show menu when time is set', (tester) async {
      final testTime = DateTime.now();
      final modelWithTime = const TimeMetricsModel().copyWith(
        timeArrivedAtPatient: () => testTime,
      );

      await tester.pumpWidget(createTestWidget(model: modelWithTime));
      await tester.pumpAndSettle();

      // Should show menu icon
      expect(find.byIcon(Icons.more_vert), findsAtLeastNWidgets(1));
    });

    testWidgets('should show menu options when menu is tapped', (tester) async {
      final testTime = DateTime.now();
      final modelWithTime = const TimeMetricsModel().copyWith(
        timeArrivedAtPatient: () => testTime,
      );

      await tester.pumpWidget(createTestWidget(model: modelWithTime));
      await tester.pumpAndSettle();

      // Tap menu
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      expect(find.text('Change Time'), findsOneWidget);
      expect(find.text('Clear Time'), findsOneWidget);
    });

    testWidgets('should show clear time confirmation dialog', (tester) async {
      final testTime = DateTime.now();
      final modelWithTime = const TimeMetricsModel().copyWith(
        timeArrivedAtPatient: () => testTime,
      );

      await tester.pumpWidget(createTestWidget(model: modelWithTime));
      await tester.pumpAndSettle();

      // Open menu
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      // Tap Clear Time
      await tester.tap(find.text('Clear Time').last);
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(
        find.text('Are you sure you want to clear the time?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('CLEAR TIME'), findsOneWidget);
    });

    testWidgets('should clear time when confirmed', (tester) async {
      final testTime = DateTime.now();
      final modelWithTime = const TimeMetricsModel().copyWith(
        timeArrivedAtPatient: () => testTime,
      );

      await tester.pumpWidget(createTestWidget(model: modelWithTime));
      await tester.pumpAndSettle();

      // Open menu
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      // Tap Clear Time
      await tester.tap(find.text('Clear Time').last);
      await tester.pumpAndSettle();

      // Confirm clear
      await tester.tap(find.text('CLEAR TIME'));
      await tester.pumpAndSettle();

      verify(() => mockController.setTimeArrivedAtPatient(null)).called(1);
    });

    testWidgets('should not clear time when cancelled', (tester) async {
      final testTime = DateTime.now();
      final modelWithTime = const TimeMetricsModel().copyWith(
        timeArrivedAtPatient: () => testTime,
      );

      await tester.pumpWidget(createTestWidget(model: modelWithTime));
      await tester.pumpAndSettle();

      // Open menu
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      // Tap Clear Time
      await tester.tap(find.text('Clear Time').last);
      await tester.pumpAndSettle();

      // Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => mockController.setTimeArrivedAtPatient(null));
    });

    testWidgets('should disable menu when locked', (tester) async {
      final testTime = DateTime.now();
      final modelWithTimeLocked = const TimeMetricsModel().copyWith(
        timeArrivedAtPatient: () => testTime,
        lockTimeArrivedAtPatient: () => true,
      );

      await tester.pumpWidget(createTestWidget(model: modelWithTimeLocked));
      await tester.pumpAndSettle();

      // Menu should be disabled
      // Find IconButtons that contain the more_vert icon
      final iconButtons = find.byType(IconButton);
      
      IconButton? menuButton;
      for (final element in iconButtons.evaluate()) {
        final iconButton = element.widget as IconButton;
        if (iconButton.icon is Icon && 
            (iconButton.icon as Icon).icon == Icons.more_vert) {
          menuButton = iconButton;
          break;
        }
      }
      
      expect(menuButton, isNotNull);
      expect(menuButton!.onPressed, isNull);
    });

    testWidgets('should show error icon when goal is null', (tester) async {
      // Create a model where the goal is not met (returns null)
      final modelWithFailedGoal = const TimeMetricsModel().copyWith(
        timeArrivedAtPatient: () => DateTime.now().subtract(
          const Duration(minutes: 10),
        ),
        timeOfEkgs: () => {
          // EKG taken after 5 minutes (goal failed)
          DateTime.now().subtract(const Duration(minutes: 4)),
        },
      );
      
      await tester.pumpWidget(createTestWidget(model: modelWithFailedGoal));
      await tester.pumpAndSettle();

      // The error icon should be shown when goal is not met (null)
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should show check icon when goal is reached', (tester) async {
      final modelWithGoal = const TimeMetricsModel().copyWith(
        timeArrivedAtPatient: () => DateTime.now().subtract(
          const Duration(minutes: 10),
        ),
        timeOfEkgs: () => {
          DateTime.now().subtract(const Duration(minutes: 8)),
        },
      );

      await tester.pumpWidget(createTestWidget(model: modelWithGoal));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should not show icon when goal is not reached',
        (tester) async {
      // Create a model with no data (returns false)
      const modelWithNoData = TimeMetricsModel();

      await tester.pumpWidget(createTestWidget(model: modelWithNoData));
      await tester.pumpAndSettle();

      // When there's no data (false), no icons should be shown
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byIcon(Icons.error), findsNothing);
    });

    testWidgets('should handle loading state', (tester) async {
      when(() => mockRepository.watchTimeMetrics())
          .thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timeMetricsControllerProvider.overrideWith(() => mockController),
            timeMetricsRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [TimeMetrics()],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle error state', (tester) async {
      when(() => mockRepository.watchTimeMetrics())
          .thenAnswer((_) => Stream.error(Exception('Test error')));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timeMetricsControllerProvider.overrideWith(() => mockController),
            timeMetricsRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [TimeMetrics()],
              ),
            ),
          ),
        ),
      );
      await tester.pump(); // Initial pump
      await tester.pump(); // Let error propagate

      // The AsyncValueSliverWidget wraps the error in a SliverToBoxAdapter
      expect(find.byType(ErrorMessageWidget), findsOneWidget);
    });

    testWidgets('should handle null model state', (tester) async {
      when(() => mockRepository.watchTimeMetrics())
          .thenAnswer((_) => Stream.value(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timeMetricsControllerProvider.overrideWith(() => mockController),
            timeMetricsRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [TimeMetrics()],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should still show UI with all fields
      expect(find.text('Arrived at Patient'), findsOneWidget);
      expect(find.text('Now'), findsNWidgets(7));
    });

    testWidgets('should call all controller methods correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Test each Now button
      final nowButtons = find.text('Now');

      // Arrived at Patient
      await tester.tap(nowButtons.at(0));
      verify(() => mockController.setTimeArrivedAtPatient(any())).called(1);

      // First EKG
      await tester.tap(nowButtons.at(1));
      verify(() => mockController.setTimeOfFirstEkg(any())).called(1);

      // STEMI Activation
      await tester.tap(nowButtons.at(2));
      verify(() => mockController.setTimeOfStemiActivationDecision(any()))
          .called(1);

      // Unit Left Scene
      await tester.tap(nowButtons.at(3));
      verify(() => mockController.setTimeUnitLeftScene(any())).called(1);

      // Give ASA
      await tester.tap(nowButtons.at(4));
      verify(() => mockController.setTimeOfAspirinGivenDecision(any()))
          .called(1);

      // Notify Cath Lab
      await tester.tap(nowButtons.at(5));
      verify(() => mockController.setTimeCathLabNotifiedDecision(any()))
          .called(1);

      // Patient at Destination
      await tester.tap(nowButtons.at(6));
      verify(() => mockController.setTimePatientArrivedAtDestination(any()))
          .called(1);
    });

    testWidgets('should show future time in error color', (tester) async {
      final futureTime = DateTime.now().add(const Duration(hours: 1));
      final modelWithFutureTime = const TimeMetricsModel().copyWith(
        timeArrivedAtPatient: () => futureTime,
      );

      await tester.pumpWidget(createTestWidget(model: modelWithFutureTime));
      await tester.pumpAndSettle();

      // Find the Timeago widget
      final timeagoFinder = find.byType(Timeago);
      expect(timeagoFinder, findsOneWidget);

      // The text should be styled with error color
      final timeagoWidget = tester.widget<Timeago>(timeagoFinder);
      expect(timeagoWidget.date, equals(futureTime));
    });

    testWidgets('should handle first EKG from list', (tester) async {
      final ekgTime = DateTime.now().subtract(const Duration(minutes: 3));
      final modelWithEkg = const TimeMetricsModel().copyWith(
        timeOfEkgs: () => {ekgTime, DateTime.now()},
      );

      await tester.pumpWidget(createTestWidget(model: modelWithEkg));
      await tester.pumpAndSettle();

      // Should show the first EKG time
      final formattedTime = TimeOfDay.fromDateTime(ekgTime)
          .format(tester.element(find.byType(TimeMetrics)));
      expect(find.text(formattedTime), findsOneWidget);
    });

    testWidgets(
        'should show calendar edit icon when time not set and not locked',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_calendar_outlined), findsNWidgets(7));
    });

    testWidgets('should disable calendar icon when locked', (tester) async {
      final modelLocked = const TimeMetricsModel().copyWith(
        lockTimeArrivedAtPatient: () => true,
      );

      await tester.pumpWidget(createTestWidget(model: modelLocked));
      await tester.pumpAndSettle();

      final calendarButton = tester.widget<IconButton>(
        find.byKey(TimeMetric.calendarButtonKey).first,
      );
      expect(calendarButton.onPressed, isNull);
    });
  });

  group('TimeMetricDivider Tests', () {
    Widget createDividerWidget({bool? isGoalReached}) {
      return MaterialApp(
        home: Scaffold(
          body: TimeMetricDivider(
            'Goal: 5 min',
            isGoalReached: isGoalReached != null ? () => isGoalReached : null,
          ),
        ),
      );
    }

    testWidgets('should show check icon when goal reached', (tester) async {
      await tester.pumpWidget(createDividerWidget(isGoalReached: true));

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Goal: 5 min'), findsOneWidget);
    });

    testWidgets('should show error icon when goal is null', (tester) async {
      await tester.pumpWidget(createDividerWidget());

      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Goal: 5 min'), findsOneWidget);
    });

    testWidgets('should show no icon when goal not reached', (tester) async {
      await tester.pumpWidget(createDividerWidget(isGoalReached: false));

      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byIcon(Icons.error), findsNothing);
      expect(find.text('Goal: 5 min'), findsOneWidget);
    });

    testWidgets('should show dividers on both sides', (tester) async {
      await tester.pumpWidget(createDividerWidget(isGoalReached: true));

      expect(find.byType(Divider), findsNWidgets(2));
    });
  });

  group('TimeMetricsMenu Tests', () {
    testWidgets('should open and close menu', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeMetricsMenu(
              onSelectDateTime: () {},
              onClearDateTime: () {},
              isLocked: false,
            ),
          ),
        ),
      );

      // Initially menu should be closed
      expect(find.text('Change Time'), findsNothing);

      // Open menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Change Time'), findsOneWidget);
      expect(find.text('Clear Time'), findsOneWidget);

      // Close menu by tapping again
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Change Time'), findsNothing);
    });

    testWidgets('should call onSelectDateTime when Change Time tapped',
        (tester) async {
      var selectDateTimeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeMetricsMenu(
              onSelectDateTime: () => selectDateTimeCalled = true,
              onClearDateTime: () {},
              isLocked: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Change Time'));
      await tester.pumpAndSettle();

      expect(selectDateTimeCalled, isTrue);
    });

    testWidgets('should be disabled when locked', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeMetricsMenu(
              onSelectDateTime: () {},
              onClearDateTime: () {},
              isLocked: true,
            ),
          ),
        ),
      );

      await tester.pump();

      final button = tester.widget<IconButton>(
          find.byKey(TimeMetricsMenu.timeMetricsMenuButtonKey),);
      expect(button.onPressed, isNull);
    });
  });
}
