import 'package:latlong2/latlong2.dart';
import 'package:test/test.dart';

void main() {
  group('LatLngBounds', () {
    test('Creation and bounds properties', () {
      final sw = LatLng(10.0, 20.0);
      final ne = LatLng(30.0, 40.0);
      final bounds = LatLngBounds(sw, ne);

      expect(bounds.south, 10.0);
      expect(bounds.north, 30.0);
      expect(bounds.west, 20.0);
      expect(bounds.east, 40.0);
      expect(bounds.center, LatLng(20.0, 30.0));
      expect(bounds.southEast, LatLng(10.0, 40.0));
      expect(bounds.northWest, LatLng(30.0, 20.0));
      expect(bounds.isValid, isTrue);
    });

    test('fromPoints', () {
      final points = [
        LatLng(10.0, 20.0),
        LatLng(30.0, 40.0),
        LatLng(0.0, 10.0),
      ];
      final bounds = LatLngBounds.fromPoints(points);

      expect(bounds.south, 0.0);
      expect(bounds.north, 30.0);
      expect(bounds.west, 10.0);
      expect(bounds.east, 40.0);
    });

    test('WorldLatLng across multiple worlds (World 0 and World 3)', () {
      final p1 =
          WorldLatLng.inWorld(0.0, 10.0, worldNumber: 0); // absolute lng 10
      final p2 =
          WorldLatLng.inWorld(0.0, 10.0, worldNumber: 3); // absolute lng 1090
      final bounds = LatLngBounds.fromPoints([p1, p2]);

      expect(bounds.west, 10.0);
      expect(bounds.east, 1090.0);
      expect(bounds.center.latitude, 0.0);
      expect(bounds.center.longitude, -170.0);

      final wPoint =
          WorldLatLng.inWorld(0.0, 140.0, worldNumber: 1); // absolute lng 500
      expect(bounds.contains(wPoint), isTrue);
    });

    test('contains', () {
      final bounds = LatLngBounds(LatLng(10.0, 20.0), LatLng(30.0, 40.0));

      expect(bounds.contains(LatLng(20.0, 30.0)), isTrue);
      expect(bounds.contains(LatLng(5.0, 30.0)), isFalse);
      expect(bounds.contains(LatLng(20.0, 50.0)), isFalse);
    });

    test('extend and extendBounds', () {
      var bounds = LatLngBounds(LatLng(10.0, 20.0), LatLng(30.0, 40.0));
      bounds = bounds.extend(LatLng(5.0, 45.0));

      expect(bounds.south, 5.0);
      expect(bounds.north, 30.0);
      expect(bounds.west, 20.0);
      expect(bounds.east, 45.0);
    });
  });
}
