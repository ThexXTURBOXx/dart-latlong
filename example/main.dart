import 'dart:math';

import 'package:latlong2/latlong2.dart';

void main() {
  var distance = Distance();

  // km = 423
  final km = distance.as(LengthUnit.kilometer, LatLng(52.518611, 13.408056),
      LatLng(51.519475, 7.46694444));

  // meter = 422591.551
  final meter =
      distance(LatLng(52.518611, 13.408056), LatLng(51.519475, 7.46694444));

  print('km: $km, meter: $meter');

  distance = const Distance();
  final num distanceInMeter = (earthRadius * pi / 4).round();

  final p1 = LatLng(0.0, 0.0);
  final p2 = distance.offset(p1, distanceInMeter, 180);

  // LatLng(latitude:-45.219848, longitude:0.0)
  print(p2.round());

  // 45° 13' 11.45" S, 0° 0' 0.00" O
  print(p2.toSexagesimal());

  //create a new distance calculator with Haversine algorithm
  distance = const Distance(calculator: Haversine());

  //create coordinates with NaN or Infinity state to check if the distance is calculated correctly
  final point1 = LatLng(double.nan, 0.0);
  final point2 = distance.offset(point1, distanceInMeter, 180);

  var meterDistance = distance.as(LengthUnit.meter, point1, point2);
  print(meterDistance);
}
