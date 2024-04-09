import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'count_up_timer_repository.g.dart';

class CountUpTimerRepository {
  CountUpTimerRepository() {
    _timerStreamController
      ..add(0)
      ..addStream(
        Stream.periodic(
          const Duration(seconds: 1),
          (x) => _stopwatch.elapsed.inSeconds,
        ),
      );
  }

  final _stopwatch = Stopwatch();
  final _timer = Timer.periodic(
    const Duration(seconds: 1),
    (timer) {},
  );

  Stream<int> get timerStream => _timerStreamController.stream;
  final _timerStreamController = StreamController<int>();

  void start() {
    _stopwatch.start();
  }

  void stop() {
    _stopwatch.stop();
  }

  void reset() {
    _stopwatch.reset();
  }

  void setTimerInSeconds(int seconds) {
    _stopwatch
      ..reset()
      ..start();
    _timerStreamController.add(seconds);
  }

  void setTimerFromDateTime(DateTime dateTime) {
    final seconds = DateTime.now().difference(dateTime).inSeconds;
    setTimerInSeconds(seconds);
  }

  void dispose() {
    _timer.cancel();
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
