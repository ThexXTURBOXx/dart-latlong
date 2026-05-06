//@TestOn("content-shell")
import 'dart:math';

import 'package:latlong2/latlong2.dart';
import 'package:test/test.dart';
// import 'package:logging/logging.dart';

// Browser
// import "package:console_log_handler/console_log_handler.dart";

// Commandline
// import "package:console_log_handler/print_log_handler.dart";

/// Raw epsilon for comparing large doubles (high accuracy).
const eps = 1;

/// Percentage epsilon for comparing large doubles (low accuracy).
const epsPerc = 0.005;

void main() {
  // final Logger _logger = new Logger("test.Distance");
  // configLogging();

  group('Distance', () {
    setUp(() {});

    test('> Radius', () {
      expect(Distance().radius, earthRadius);
      expect(Distance.withRadius(100.0).radius, 100.0);
    }); // end of 'Radius' test

    group('Vincenty [accurate]', () {
      test('> Random test', () {
        final distance = Distance(calculator: Vincenty());

        expect(
            distance(
                LatLng(52.518611, 13.408056), LatLng(51.519475, 7.46694444)),
            422592);

        expect(
            distance.as(LengthUnit.kilometer, LatLng(52.518611, 13.408056),
                LatLng(51.519475, 7.46694444)),
            423);
      });

      test('> Distance to the same point', () {
        final compute = DistanceVincenty();
        final p = LatLng(0.0, 0.0);
        final q = LatLng(55.0, 78.0);

        expect(compute.distance(p, p, lngDir: SegmentDirection.laziest),
            equals(0));
        expect(
            compute.distance(p, p, lngDir: SegmentDirection.lazy), equals(0));
        expect(compute.distance(p, p, lngDir: SegmentDirection.shortestPath),
            equals(0));
        expect(compute.distance(p, p, lngDir: SegmentDirection.longestPath),
            closeTo(compute.radius * tau, eps));
        expect(compute.distance(p, p, lngDir: SegmentDirection.eastward),
            equals(0));
        expect(compute.distance(p, p, lngDir: SegmentDirection.westward),
            equals(0));
        expect(
            compute.distance(p, p, lngDir: SegmentDirection.strictlyEastward),
            closeTo(compute.radius * tau, eps));
        expect(
            compute.distance(p, p, lngDir: SegmentDirection.strictlyWestward),
            closeTo(compute.radius * tau, eps));

        expect(compute.distance(q, q, lngDir: SegmentDirection.laziest),
            equals(0));
        expect(
            compute.distance(q, q, lngDir: SegmentDirection.lazy), equals(0));
        expect(compute.distance(q, q, lngDir: SegmentDirection.shortestPath),
            equals(0));
        expect(compute.distance(q, q, lngDir: SegmentDirection.longestPath),
            closeTo(compute.radius * tau, eps));
        expect(compute.distance(q, q, lngDir: SegmentDirection.eastward),
            equals(0));
        expect(compute.distance(q, q, lngDir: SegmentDirection.westward),
            equals(0));
        expect(
            compute.distance(q, q, lngDir: SegmentDirection.strictlyEastward),
            closeTo(compute.radius * tau, eps));
        expect(
            compute.distance(q, q, lngDir: SegmentDirection.strictlyWestward),
            closeTo(compute.radius * tau, eps));
      }); // end of 'Distance to the same point' test

      test('> Distance between 0 and 90.0 is around 10.002km', () {
        final distance = Distance();
        final p1 = LatLng(0.0, 0.0);
        final p2 = LatLng(90.0, 0.0);

        // no rounding
        expect(distance(p1, p2) ~/ 1000, closeTo(10002, eps));

        expect(
            LengthUnit.meter.to(LengthUnit.kilometer, distance(p1, p2)).round(),
            closeTo(10002, eps));

        // rounds to 10002
        expect(distance.as(LengthUnit.kilometer, p1, p2), closeTo(10002, eps));
        expect(distance.as(LengthUnit.meter, p1, p2), closeTo(10001966, eps));
      }); // end of 'Distance between 0 and 90.0' test

      test('> Distance between 0 and 90.0 is 10001.96572931165 km', () {
        final distance = Distance(roundResult: false);
        final p1 = LatLng(0.0, 0.0);
        final p2 = LatLng(90.0, 0.0);

        expect(distance.as(LengthUnit.kilometer, p1, p2),
            equals(10001.96572931165));
      }); // end of 'Round' test

      test('> distance between 0,-180 and 0,180', () {
        final compute = Distance();
        final p1 = LatLng(0.0, -180.0);
        final p2 = LatLng(0.0, 180.0);

        expect(compute.distance(p1, p2, lngDir: SegmentDirection.laziest),
            closeTo(compute.radius * tau, eps));
        expect(
            compute.distance(p1, p2, lngDir: SegmentDirection.lazy), equals(0));
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.shortestPath),
            equals(0));
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.longestPath),
            closeTo(compute.radius * tau, eps));
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.eastward),
            equals(0));
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.westward),
            equals(0));
        expect(
            compute.distance(p1, p2, lngDir: SegmentDirection.strictlyEastward),
            closeTo(compute.radius * tau, eps));
        expect(
            compute.distance(p1, p2, lngDir: SegmentDirection.strictlyWestward),
            closeTo(compute.radius * tau, eps));

        expect(compute.distance(p2, p1, lngDir: SegmentDirection.laziest),
            closeTo(compute.radius * tau, eps));
        expect(
            compute.distance(p2, p1, lngDir: SegmentDirection.lazy), equals(0));
        expect(compute.distance(p2, p1, lngDir: SegmentDirection.shortestPath),
            equals(0));
        expect(compute.distance(p2, p1, lngDir: SegmentDirection.longestPath),
            closeTo(compute.radius * tau, eps));
        expect(compute.distance(p2, p1, lngDir: SegmentDirection.eastward),
            equals(0));
        expect(compute.distance(p2, p1, lngDir: SegmentDirection.westward),
            equals(0));
        expect(
            compute.distance(p2, p1, lngDir: SegmentDirection.strictlyEastward),
            closeTo(compute.radius * tau, eps));
        expect(
            compute.distance(p2, p1, lngDir: SegmentDirection.strictlyWestward),
            closeTo(compute.radius * tau, eps));
      }); // end of 'distance between 0,-180 and 0,180' test

      test('> distance between 1,-179 and -1,179', () {
        final compute = Distance();
        final p1 = LatLng(1.0, -179.0);
        final p2 = LatLng(-1.0, 179.0);

        // 39660259 is not radius*tau-313799. This is because it is not
        // necessarily THE longest path, but rather the path in the opposite
        // direction of whatever shortestPath would do. And in this case, we
        // need to account for the eccentricity of the earth (two different
        // radii, according to the WGS84 definition).
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.laziest),
            closeTo(39660259, eps));
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.lazy),
            closeTo(39660259, eps));
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.shortestPath),
            closeTo(313799, eps));
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.longestPath),
            closeTo(39660259, eps));
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.eastward),
            closeTo(39660259, eps));
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.westward),
            closeTo(313799, eps));
        expect(
            compute.distance(p1, p2, lngDir: SegmentDirection.strictlyEastward),
            closeTo(39660259, eps));
        expect(
            compute.distance(p1, p2, lngDir: SegmentDirection.strictlyWestward),
            closeTo(313799, eps));

        expect(compute.distance(p2, p1, lngDir: SegmentDirection.laziest),
            closeTo(39660259, eps));
        expect(compute.distance(p2, p1, lngDir: SegmentDirection.lazy),
            closeTo(39660259, eps));
        expect(compute.distance(p2, p1, lngDir: SegmentDirection.shortestPath),
            closeTo(313799, eps));
        expect(compute.distance(p2, p1, lngDir: SegmentDirection.longestPath),
            closeTo(39660259, eps));
        expect(compute.distance(p2, p1, lngDir: SegmentDirection.eastward),
            closeTo(313799, eps));
        expect(compute.distance(p2, p1, lngDir: SegmentDirection.westward),
            closeTo(39660259, eps));
        expect(
            compute.distance(p2, p1, lngDir: SegmentDirection.strictlyEastward),
            closeTo(313799, eps));
        expect(
            compute.distance(p2, p1, lngDir: SegmentDirection.strictlyWestward),
            closeTo(39660259, eps));
      }); // end of 'distance between 0,-179 and 0,179' test

      test('> distance between 0,0 and 0,-45', () {
        final distance = Distance();
        final p1 = LatLng(0.0, 0.0);
        final p2 = LatLng(0.0, -45.0);

        expect(distance(p1, p2, lngDir: SegmentDirection.laziest),
            closeTo(5009377, eps));
        expect(distance(p1, p2, lngDir: SegmentDirection.lazy),
            closeTo(5009377, eps));
        expect(distance(p1, p2, lngDir: SegmentDirection.shortestPath),
            closeTo(5009377, eps));
        expect(distance(p1, p2, lngDir: SegmentDirection.longestPath),
            closeTo(34931276, eps));
        expect(distance(p1, p2, lngDir: SegmentDirection.eastward),
            closeTo(34931276, eps));
        expect(distance(p1, p2, lngDir: SegmentDirection.westward),
            closeTo(5009377, eps));
        expect(distance(p1, p2, lngDir: SegmentDirection.strictlyEastward),
            closeTo(34931276, eps));
        expect(distance(p1, p2, lngDir: SegmentDirection.strictlyWestward),
            closeTo(5009377, eps));

        expect(distance(p2, p1, lngDir: SegmentDirection.laziest),
            closeTo(5009377, eps));
        expect(distance(p2, p1, lngDir: SegmentDirection.lazy),
            closeTo(5009377, eps));
        expect(distance(p2, p1, lngDir: SegmentDirection.shortestPath),
            closeTo(5009377, eps));
        expect(distance(p2, p1, lngDir: SegmentDirection.longestPath),
            closeTo(34931276, eps));
        expect(distance(p2, p1, lngDir: SegmentDirection.eastward),
            closeTo(5009377, eps));
        expect(distance(p2, p1, lngDir: SegmentDirection.westward),
            closeTo(34931276, eps));
        expect(distance(p2, p1, lngDir: SegmentDirection.strictlyEastward),
            closeTo(5009377, eps));
        expect(distance(p2, p1, lngDir: SegmentDirection.strictlyWestward),
            closeTo(34931276, eps));
      }); // end of 'distance between 0,0 and 0,-45' test
    }); // End of 'Vincenty' group

    group('Haversine [not so accurate]', () {
      test('> Random test', () {
        final distance = Distance(calculator: const Haversine());

        expect(
            distance(
                LatLng(52.518611, 13.408056), LatLng(51.519475, 7.46694444)),
            421786.0);
      });

      test('> Distance to the same point', () {
        final compute = DistanceHaversine();
        final p = LatLng(0.0, 0.0);
        final q = LatLng(55.0, 78.0);

        expect(compute.distance(p, p, lngDir: SegmentDirection.laziest),
            equals(0));
        expect(
            compute.distance(p, p, lngDir: SegmentDirection.lazy), equals(0));
        expect(compute.distance(p, p, lngDir: SegmentDirection.shortestPath),
            equals(0));
        expect(compute.distance(p, p, lngDir: SegmentDirection.longestPath),
            closeToPerc(compute.radius * tau, epsPerc));
        expect(compute.distance(p, p, lngDir: SegmentDirection.eastward),
            equals(0));
        expect(compute.distance(p, p, lngDir: SegmentDirection.westward),
            equals(0));
        expect(
            compute.distance(p, p, lngDir: SegmentDirection.strictlyEastward),
            closeToPerc(compute.radius * tau, epsPerc));
        expect(
            compute.distance(p, p, lngDir: SegmentDirection.strictlyWestward),
            closeToPerc(compute.radius * tau, epsPerc));

        expect(compute.distance(q, q, lngDir: SegmentDirection.laziest),
            equals(0));
        expect(
            compute.distance(q, q, lngDir: SegmentDirection.lazy), equals(0));
        expect(compute.distance(q, q, lngDir: SegmentDirection.shortestPath),
            equals(0));
        expect(compute.distance(q, q, lngDir: SegmentDirection.longestPath),
            closeToPerc(compute.radius * tau, epsPerc));
        expect(compute.distance(q, q, lngDir: SegmentDirection.eastward),
            equals(0));
        expect(compute.distance(q, q, lngDir: SegmentDirection.westward),
            equals(0));
        expect(
            compute.distance(q, q, lngDir: SegmentDirection.strictlyEastward),
            closeToPerc(compute.radius * tau, epsPerc));
        expect(
            compute.distance(q, q, lngDir: SegmentDirection.strictlyWestward),
            closeToPerc(compute.radius * tau, epsPerc));
      }); // end of 'Distance to the same point' test

      test('> Distance between 0 and 90.0 is around 10.002km', () {
        final distance = DistanceHaversine();
        final p1 = LatLng(0.0, 0.0);
        final p2 = LatLng(90.0, 0.0);

        // no rounding
        expect(distance(p1, p2) ~/ 1000, closeToPerc(10002, epsPerc));

        expect(
            LengthUnit.meter.to(LengthUnit.kilometer, distance(p1, p2)).round(),
            closeToPerc(10002, epsPerc));

        // rounds to 10002
        expect(distance.as(LengthUnit.kilometer, p1, p2),
            closeToPerc(10002, epsPerc));
        expect(distance.as(LengthUnit.meter, p1, p2),
            closeToPerc(10001966, epsPerc));
      }); // end of 'Distance between 0 and 90.0' test

      test('> distance between 0,-180 and 0,180', () {
        final compute = DistanceHaversine();
        final p1 = LatLng(0.0, -180.0);
        final p2 = LatLng(0.0, 180.0);

        expect(compute.distance(p1, p2, lngDir: SegmentDirection.laziest),
            closeToPerc(compute.radius * tau, epsPerc));
        expect(
            compute.distance(p1, p2, lngDir: SegmentDirection.lazy), equals(0));
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.shortestPath),
            equals(0));
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.longestPath),
            closeToPerc(compute.radius * tau, epsPerc));
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.eastward),
            equals(0));
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.westward),
            equals(0));
        expect(
            compute.distance(p1, p2, lngDir: SegmentDirection.strictlyEastward),
            closeToPerc(compute.radius * tau, epsPerc));
        expect(
            compute.distance(p1, p2, lngDir: SegmentDirection.strictlyWestward),
            closeToPerc(compute.radius * tau, epsPerc));
      }); // end of 'distance between 0,-180 and 0,180' test

      test('> distance between 1,-179 and -1,179', () {
        final compute = DistanceHaversine();
        final p1 = LatLng(1.0, -179.0);
        final p2 = LatLng(-1.0, 179.0);

        // 39660259 is not radius*tau-313799. This is because it is not
        // necessarily THE longest path, but rather the path in the opposite
        // direction of whatever shortestPath would do. And in this case, we
        // need to account for the eccentricity of the earth (two different
        // radii, according to the WGS84 definition).
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.laziest),
            closeToPerc(39660259, epsPerc));
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.lazy),
            closeToPerc(39660259, epsPerc));
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.shortestPath),
            closeToPerc(313799, epsPerc));
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.longestPath),
            closeToPerc(39660259, epsPerc));
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.eastward),
            closeToPerc(39660259, epsPerc));
        expect(compute.distance(p1, p2, lngDir: SegmentDirection.westward),
            closeToPerc(313799, epsPerc));
        expect(
            compute.distance(p1, p2, lngDir: SegmentDirection.strictlyEastward),
            closeToPerc(39660259, epsPerc));
        expect(
            compute.distance(p1, p2, lngDir: SegmentDirection.strictlyWestward),
            closeToPerc(313799, epsPerc));

        expect(compute.distance(p2, p1, lngDir: SegmentDirection.laziest),
            closeToPerc(39660259, epsPerc));
        expect(compute.distance(p2, p1, lngDir: SegmentDirection.lazy),
            closeToPerc(39660259, epsPerc));
        expect(compute.distance(p2, p1, lngDir: SegmentDirection.shortestPath),
            closeToPerc(313799, epsPerc));
        expect(compute.distance(p2, p1, lngDir: SegmentDirection.longestPath),
            closeToPerc(39660259, epsPerc));
        expect(compute.distance(p2, p1, lngDir: SegmentDirection.eastward),
            closeToPerc(313799, epsPerc));
        expect(compute.distance(p2, p1, lngDir: SegmentDirection.westward),
            closeToPerc(39660259, epsPerc));
        expect(
            compute.distance(p2, p1, lngDir: SegmentDirection.strictlyEastward),
            closeToPerc(313799, epsPerc));
        expect(
            compute.distance(p2, p1, lngDir: SegmentDirection.strictlyWestward),
            closeToPerc(39660259, epsPerc));
      }); // end of 'distance between 0,-179 and 0,179' test

      test('> distance between 0,0 and 0,-45', () {
        final distance = DistanceHaversine();
        final p1 = LatLng(0.0, 0.0);
        final p2 = LatLng(0.0, -45.0);

        expect(distance(p1, p2, lngDir: SegmentDirection.laziest),
            closeToPerc(5009377, epsPerc));
        expect(distance(p1, p2, lngDir: SegmentDirection.lazy),
            closeToPerc(5009377, epsPerc));
        expect(distance(p1, p2, lngDir: SegmentDirection.shortestPath),
            closeToPerc(5009377, epsPerc));
        expect(distance(p1, p2, lngDir: SegmentDirection.longestPath),
            closeToPerc(34931276, epsPerc));
        expect(distance(p1, p2, lngDir: SegmentDirection.eastward),
            closeToPerc(34931276, epsPerc));
        expect(distance(p1, p2, lngDir: SegmentDirection.westward),
            closeToPerc(5009377, epsPerc));
        expect(distance(p1, p2, lngDir: SegmentDirection.strictlyEastward),
            closeToPerc(34931276, epsPerc));
        expect(distance(p1, p2, lngDir: SegmentDirection.strictlyWestward),
            closeToPerc(5009377, epsPerc));
      }); // end of 'distance between 0,0 and 0,-45' test
    }); // End of 'Haversine' group
  });
  // End of 'Distance' group

  group('Bearing', () {
    test('bearing to the same point is 0 degree', () {
      final distance = const Distance();
      final p = LatLng(0.0, 0.0);
      expect(distance.bearing(p, p), equals(0));
    });

    test('bearing between 0,0 and 90,0 is 0 degree', () {
      final distance = const Distance();
      final p1 = LatLng(0.0, 0.0);
      final p2 = LatLng(90.0, 0.0);
      expect(distance.bearing(p1, p2), equals(0));
    });

    test('bearing between 0,0 and -90,0 is 180 degree', () {
      final distance = const Distance();
      final p1 = LatLng(0.0, 0.0);
      final p2 = LatLng(-90.0, 0.0);
      expect(distance.bearing(p1, p2), equals(180));
    });

    test('bearing between 0,-90 and 0,90 is -90 degree', () {
      final distance = const Distance();
      final p1 = LatLng(0.0, -90.0);
      final p2 = LatLng(0.0, 90.0);
      expect(distance.bearing(p1, p2), equals(90));
    });

    test('bearing between 0,-180 and 0,180 is -90 degree', () {
      final distance = const Distance();
      final p1 = LatLng(0.0, -180.0);
      final p2 = LatLng(0.0, 180.0);

      expect(distance.bearing(p1, p2), equals(-90));
      expect(normalizeBearing(distance.bearing(p1, p2)), equals(270));
    });
  }); // End of 'Direction' group

  group('Offset', () {
    test('offset from 0,0 with bearing 0 and distance 10018.754 km is 90,180',
        () {
      final distance = const Distance();

      final num distanceInMeter = (earthRadius * pi / 2).round();
      //print("Dist $distanceInMeter");

      final p1 = LatLng(0.0, 0.0);
      final p2 = distance.offset(p1, distanceInMeter.round(), 0);

      //print(p2);
      //print("${decimal2sexagesimal(p2.latitude)} / ${decimal2sexagesimal(p2.longitude)}");

      expect(p2.latitude.round(), equals(90));
      expect(p2.longitude.round(), equals(180));
    });

    test('offset from 0,0 with bearing 180 and distance ~ 5.000 km is -45,0',
        () {
      final distance = const Distance();
      final num distanceInMeter = (earthRadius * pi / 4).round();

      final p1 = LatLng(0.0, 0.0);
      final p2 = distance.offset(p1, distanceInMeter, 180);

      // print(p2.round());
      // print(p2.toSexagesimal());

      expect(p2.latitude.round(), equals(-45));
      expect(p2.longitude.round(), equals(0));
    });

    test('offset from 0,0 with bearing 180 and distance ~ 10.000 km is -90,180',
        () {
      final distance = const Distance();
      final num distanceInMeter = (earthRadius * pi / 2).round();

      final p1 = LatLng(0.0, 0.0);
      final p2 = distance.offset(p1, distanceInMeter, 180);

      expect(p2.latitude.round(), equals(-90));
      expect(p2.longitude.round(), equals(180)); // 0 Vincenty
    });

    test('offset from 0,0 with bearing 90 and distance ~ 5.000 km is 0,45', () {
      final distance = const Distance();
      final num distanceInMeter = (earthRadius * pi / 4).round();

      final p1 = LatLng(0.0, 0.0);
      final p2 = distance.offset(p1, distanceInMeter, 90);

      expect(p2.latitude.round(), equals(0));
      expect(p2.longitude.round(), equals(45));
    });
  }); // End of 'Offset' group
}

// - Helper --------------------------------------------------------------------------------------

Matcher closeToPerc(num value, num percentage) =>
    closeTo(value, percentage * value);
