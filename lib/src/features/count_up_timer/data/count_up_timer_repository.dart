import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'count_up_timer_repository.g.dart';

class CountUpTimerRepository {
  CountUpTimerRepository() {
    // Add the initial event
    _timerStreamController.add(0);

    // Initialize the periodic timer
    _startPeriodicTimer();
  }

  final _timerStreamController = StreamController<int>();
  final _stopwatch = Stopwatch();
  Timer? _timer;
  int _elapsedTimeOffset = 0;

  Stream<int> get timerStream => _timerStreamController.stream;

  void start() {
    _stopwatch.start();
  }

  void stop() {
    _stopwatch.stop();
  }

  Future<void> reset() async {
    _stopwatch
      ..stop()
      ..reset();
    _elapsedTimeOffset = 0;
    _timerStreamController.add(0);
  }

  Future<void> setElapsedTime(int seconds) async {
    final isRunning = _stopwatch.isRunning;
    // Manually set the elapsed time
    _stopwatch
      ..stop()
      ..reset();
    _elapsedTimeOffset = seconds;

    // Add the new value to the stream
    _timerStreamController.add(seconds);

    // Restart the stopwatch if it was running
    if (isRunning) {
      _stopwatch.start();
    }
  }

  void _startPeriodicTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        _timerStreamController
            .add(_stopwatch.elapsed.inSeconds + _elapsedTimeOffset);
      },
    );
  }

  /// Set timer from [startDateTime] to now.
  /// You may optionally also define an [endDateTime], such as if the timer is
  /// stopped.
  Future<void> setTimerFromDateTime(
    DateTime? startDateTime, {
    DateTime? endDateTime,
  }) async {
    if (startDateTime == null) {
      await reset();
      return;
    }

    final seconds =
        (endDateTime ?? DateTime.now()).difference(startDateTime).inSeconds;

    if (seconds < 0) {
      throw ArgumentError('End time must be after start time');
    }

    if (endDateTime != null) {
      _stopwatch.stop();
    } else {
      _stopwatch.start();
    }

    await setElapsedTime(seconds);
  }

  void dispose() {
    _timer?.cancel();
    _timerStreamController.close();
  }
}

@riverpod
CountUpTimerRepository countUpTimerRepository(CountUpTimerRepositoryRef ref) {
  final repository = CountUpTimerRepository();
  ref.onDispose(repository.dispose);
  return repository;
}

@riverpod
Stream<int> countUpTimer(CountUpTimerRef ref) {
  return ref.watch(countUpTimerRepositoryProvider).timerStream;
}
