import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

class MockNavInfo extends Mock implements NavInfo {}

void main() {
  group('EtaWidget', () {
    late MockNavInfo mockNavInfo;

    setUp(() {
      mockNavInfo = MockNavInfo();
    });

    Widget createTestWidget({
      AsyncValue<NavInfo?>? navInfoValue,
    }) {
      return ProviderScope(
        overrides: [
          if (navInfoValue != null)
            navInfoProvider.overrideWith((ref) {
              if (navInfoValue.isLoading) {
                return const Stream.empty();
              } else if (navInfoValue.hasError) {
                return Stream.error(
                  navInfoValue.error!,
                  navInfoValue.stackTrace,
                );
              } else {
                return Stream.value(navInfoValue.value);
              }
            }),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: EtaWidget(),
            ),
          ),
        ),
      );
    }

    testWidgets('should show loading when nav info is loading', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          navInfoValue: const AsyncValue<NavInfo?>.loading(),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error when nav info has error', (tester) async {
      final error = Exception('Test error');

      await tester.pumpWidget(
        createTestWidget(
          navInfoValue: AsyncValue<NavInfo?>.error(
            error,
            StackTrace.current,
          ),
        ),
      );

      await tester.pump();

      expect(find.text(error.toString()), findsOneWidget);
    });

    testWidgets('should show empty when nav info is null', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          navInfoValue: const AsyncValue<NavInfo?>.data(null),
        ),
      );
      await tester.pump();

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('ETA:'), findsNothing);
    });

    testWidgets('should show empty when time to destination is null',
        (tester) async {
      when(() => mockNavInfo.timeToFinalDestinationSeconds).thenReturn(null);

      await tester.pumpWidget(
        createTestWidget(
          navInfoValue: AsyncValue<NavInfo?>.data(mockNavInfo),
        ),
      );
      await tester.pump();

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('ETA:'), findsNothing);
    });

    testWidgets('should show empty when time to destination is negative',
        (tester) async {
      when(() => mockNavInfo.timeToFinalDestinationSeconds).thenReturn(-1);

      await tester.pumpWidget(
        createTestWidget(
          navInfoValue: AsyncValue<NavInfo?>.data(mockNavInfo),
        ),
      );
      await tester.pump();

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('ETA:'), findsNothing);
    });

    testWidgets('should display ETA when time to destination is valid',
        (tester) async {
      // 5 minutes and 30 seconds
      when(() => mockNavInfo.timeToFinalDestinationSeconds).thenReturn(330);

      await tester.pumpWidget(
        createTestWidget(
          navInfoValue: AsyncValue<NavInfo?>.data(mockNavInfo),
        ),
      );
      await tester.pump();

      expect(find.text('ETA:'), findsOneWidget);
      expect(find.text('05:30'), findsOneWidget);
    });

    testWidgets('should display arrival time in correct format',
        (tester) async {
      // Mock current time to ensure predictable results
// 2:30 PM

      // Use a known time to destination
      when(() => mockNavInfo.timeToFinalDestinationSeconds)
          .thenReturn(1800); // 30 minutes

      await tester.pumpWidget(
        createTestWidget(
          navInfoValue: AsyncValue<NavInfo?>.data(mockNavInfo),
        ),
      );
      await tester.pump();

      // Check that duration is displayed correctly
      expect(find.text('30:00'), findsOneWidget);

      // Verify that arrival time text is present (format depends on locale)
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.style?.fontStyle == FontStyle.italic &&
              widget.textAlign == TextAlign.end,
        ),
        findsOneWidget,
      );
    });

    testWidgets('should apply correct text styles', (tester) async {
      when(() => mockNavInfo.timeToFinalDestinationSeconds).thenReturn(300);

      await tester.pumpWidget(
        createTestWidget(
          navInfoValue: AsyncValue<NavInfo?>.data(mockNavInfo),
        ),
      );
      await tester.pump();

      // Check ETA label style
      final etaLabel = tester.widget<Text>(find.text('ETA:'));
      expect(
        etaLabel.style,
        Theme.of(tester.element(find.text('ETA:'))).textTheme.titleLarge,
      );

      // Check duration style
      final duration = tester.widget<Text>(find.text('05:00'));
      expect(
        duration.style,
        Theme.of(tester.element(find.text('05:00'))).textTheme.titleMedium,
      );
      expect(duration.textAlign, TextAlign.end);

      // Check arrival time style
      final arrivalTime = tester.widget<Text>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text && widget.style?.fontStyle == FontStyle.italic,
        ),
      );
      expect(arrivalTime.textAlign, TextAlign.end);
    });

    testWidgets('should use correct flex values for layout', (tester) async {
      when(() => mockNavInfo.timeToFinalDestinationSeconds).thenReturn(300);

      await tester.pumpWidget(
        createTestWidget(
          navInfoValue: AsyncValue<NavInfo?>.data(mockNavInfo),
        ),
      );
      await tester.pump();

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.center);

      final expandedWidgets =
          tester.widgetList<Expanded>(find.byType(Expanded)).toList();
      expect(expandedWidgets.length, 3);
      expect(expandedWidgets[0].flex, 2); // ETA label
      expect(expandedWidgets[1].flex, 3); // Duration
      expect(expandedWidgets[2].flex, 2); // Arrival time
    });
  });
}
