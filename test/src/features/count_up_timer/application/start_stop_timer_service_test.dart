import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Mocks
class MockRef extends Mock implements Ref {}

class MockCountUpTimerRepository extends Mock
    implements CountUpTimerRepository {}

class MockTimeMetricsModel extends Mock implements TimeMetricsModel {}

class MockProviderSubscription extends Mock
    implements ProviderSubscription<AsyncValue<TimeMetricsModel?>> {}

// Fakes
class FakeAsyncValue<T> extends Fake implements AsyncValue<T> {}

void main() {
  late StartStopTimerService service;
  late MockRef mockRef;
  late MockCountUpTimerRepository mockRepository;
  late MockTimeMetricsModel mockTimeMetrics;
  late MockProviderSubscription mockSubscription;

  setUpAll(() {
    registerFallbackValue(FakeAsyncValue<TimeMetricsModel?>());
    registerFallbackValue(timeMetricsModelProvider);
  });

  setUp(() {
    mockRef = MockRef();
    mockRepository = MockCountUpTimerRepository();
    mockTimeMetrics = MockTimeMetricsModel();
    mockSubscription = MockProviderSubscription();

    // Setup default behavior
    when(() => mockRef.read(countUpTimerRepositoryProvider))
        .thenReturn(mockRepository);
    when(
      () => mockRepository.setTimerFromDateTime(
        any(),
        endDateTime: any(named: 'endDateTime'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockRef.listen<AsyncValue<TimeMetricsModel?>>(
        any(),
        any(),
        fireImmediately: any(named: 'fireImmediately'),
        onError: any(named: 'onError'),
      ),
    ).thenReturn(mockSubscription);
  });

  group('StartStopTimerService', () {
    test('should initialize and set up listener', () {
      // Create service
      service = StartStopTimerService(mockRef);

      // Verify that listen was called
      verify(
        () => mockRef.listen<AsyncValue<TimeMetricsModel?>>(
          timeMetricsModelProvider,
          any(),
          fireImmediately: any(named: 'fireImmediately'),
          onError: any(named: 'onError'),
        ),
      ).called(1);
    });

    test('should update timer when time metrics change', () async {
      final startTime = DateTime.now().subtract(const Duration(minutes: 10));
      final endTime = DateTime.now();

      // Setup time metrics
      when(() => mockTimeMetrics.timeArrivedAtPatient).thenReturn(startTime);
      when(() => mockTimeMetrics.timePatientArrivedAtDestination)
          .thenReturn(endTime);

      when(
        () => mockRef.listen<AsyncValue<TimeMetricsModel?>>(
          any(),
          any(),
          fireImmediately: any(named: 'fireImmediately'),
          onError: any(named: 'onError'),
        ),
      ).thenAnswer((invocation) {
        callback = invocation.positionalArguments[1] as void Function(
          AsyncValue<TimeMetricsModel?>?,
          AsyncValue<TimeMetricsModel?>,
        );
        return mockSubscription;
      });

      // Create service
      service = StartStopTimerService(mockRef);

      // Trigger the listener with new time metrics
      callback(
        const AsyncValue.data(null),
        AsyncValue.data(mockTimeMetrics),
      );

      // Allow async operations to complete
      await Future.delayed(Duration.zero);

      // Verify repository was called with correct times
      verify(
        () => mockRepository.setTimerFromDateTime(
          startTime,
          endDateTime: endTime,
        ),
      ).called(1);
    });

    test('should handle null end time', () async {
      final startTime = DateTime.now().subtract(const Duration(minutes: 10));

      // Setup time metrics with null end time
      when(() => mockTimeMetrics.timeArrivedAtPatient).thenReturn(startTime);
      when(() => mockTimeMetrics.timePatientArrivedAtDestination)
          .thenReturn(null);

      when(
        () => mockRef.listen<AsyncValue<TimeMetricsModel?>>(
          any(),
          any(),
          fireImmediately: any(named: 'fireImmediately'),
          onError: any(named: 'onError'),
        ),
      ).thenAnswer((invocation) {
        callback = invocation.positionalArguments[1] as void Function(
          AsyncValue<TimeMetricsModel?>?,
          AsyncValue<TimeMetricsModel?>,
        );
        return mockSubscription;
      });

      // Create service
      service = StartStopTimerService(mockRef);

      // Trigger the listener with new time metrics
      callback(
        const AsyncValue.data(null),
        AsyncValue.data(mockTimeMetrics),
      );

      // Allow async operations to complete
      await Future.delayed(Duration.zero);

      // Verify repository was called with null end time
      verify(
        () => mockRepository.setTimerFromDateTime(
          startTime,
        ),
      ).called(1);
    });

    test('should not update timer when time metrics is null', () async {
      when(
        () => mockRef.listen<AsyncValue<TimeMetricsModel?>>(
          any(),
          any(),
          fireImmediately: any(named: 'fireImmediately'),
          onError: any(named: 'onError'),
        ),
      ).thenAnswer((invocation) {
        callback = invocation.positionalArguments[1] as void Function(
          AsyncValue<TimeMetricsModel?>?,
          AsyncValue<TimeMetricsModel?>,
        );
        return mockSubscription;
      });

      // Create service
      service = StartStopTimerService(mockRef);

      // Trigger the listener with null time metrics
      callback(
        const AsyncValue.data(null),
        const AsyncValue.data(null),
      );

      // Allow async operations to complete
      await Future.delayed(Duration.zero);

      // Verify repository was NOT called
      verifyNever(
        () => mockRepository.setTimerFromDateTime(
          any(),
          endDateTime: any(named: 'endDateTime'),
        ),
      );
    });

    test('should handle AsyncValue loading state', () async {
      when(
        () => mockRef.listen<AsyncValue<TimeMetricsModel?>>(
          any(),
          any(),
          fireImmediately: any(named: 'fireImmediately'),
          onError: any(named: 'onError'),
        ),
      ).thenAnswer((invocation) {
        callback = invocation.positionalArguments[1] as void Function(
          AsyncValue<TimeMetricsModel?>?,
          AsyncValue<TimeMetricsModel?>,
        );
        return mockSubscription;
      });

      // Create service
      service = StartStopTimerService(mockRef);

      // Trigger the listener with loading state
      callback(
        const AsyncValue.data(null),
        const AsyncValue.loading(),
      );

      // Allow async operations to complete
      await Future.delayed(Duration.zero);

      // Verify repository was NOT called
      verifyNever(
        () => mockRepository.setTimerFromDateTime(
          any(),
          endDateTime: any(named: 'endDateTime'),
        ),
      );
    });
  });

  group('startStopTimerServiceProvider', () {
    test('should provide StartStopTimerService instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(startStopTimerServiceProvider);

      expect(service, isA<StartStopTimerService>());
    });
  });
}

void Function(
  AsyncValue<TimeMetricsModel?>?,
  AsyncValue<TimeMetricsModel?>,
) callback = (_, __) {};
