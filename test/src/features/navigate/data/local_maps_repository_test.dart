import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';

void main() {
  late LocalMapsRepository repository;

  setUp(() {
    repository = LocalMapsRepository();
  });

  group('LocalMapsRepository', () {
    test('should initialize with null mapsInfo', () {
      expect(repository.getMapsInfo(), isNull);
    });

    test('should update mapsInfo when set', () {
      const newMapsInfo = MapsInfo();
      repository.setMapsInfo(newMapsInfo);
      expect(repository.getMapsInfo(), equals(newMapsInfo));
    });

    test('should initialize with null map ready state', () {
      final stream = repository.watchMapsInfo();
      stream.listen((value) {
        expect(value, isNull);
      });
    });

    test('should update map ready state', () async {
      final values = <MapsInfo?>[];
      final subscription = repository.watchMapsInfo().listen(values.add);

      // Give time for initial value
      await Future.delayed(Duration.zero);

      repository.setMapsInfo(const MapsInfo());
      await Future.delayed(Duration.zero);

      repository.setMapsInfo(const MapsInfo());
      await Future.delayed(Duration.zero);

      repository.setMapsInfo(const MapsInfo());
      await Future.delayed(Duration.zero);

      await subscription.cancel();

      expect(values, containsAll([null, const MapsInfo()]));
    });

    test('should handle multiple subscribers to map ready stream', () async {
      final stream1Values = <MapsInfo?>[];
      final stream2Values = <MapsInfo?>[];

      final sub1 = repository.watchMapsInfo().listen(stream1Values.add);
      final sub2 = repository.watchMapsInfo().listen(stream2Values.add);

      await Future.delayed(Duration.zero);
      repository.setMapsInfo(const MapsInfo());
      await Future.delayed(Duration.zero);

      await sub1.cancel();
      await sub2.cancel();

      expect(stream1Values, isNotEmpty);
      expect(stream2Values, isNotEmpty);
      expect(stream1Values.last, equals(const MapsInfo()));
      expect(stream2Values.last, equals(const MapsInfo()));
    });
  });
}
