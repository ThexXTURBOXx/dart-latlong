/*
 * Copyright (c) 2016, Michael Mitterer (office@mikemitterer.at),
 * IT-Consulting and Development Limited.
 *
 * All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:math';

import 'package:intl/intl.dart';
import 'package:latlong2/latlong2.dart';

/// Coordinates in Degrees (Normal/Standard LatLng)
///
///     final LatLng location = LatLng(10.000002, 12.00001);
///
class LatLng {
  /// Latitude in degrees (-90 to 90)
  final double latitude;

  /// Longitude in degrees (-180 to 180)
  final double longitude;

  /// Creates a [LatLng] with [latitude] and [longitude] in degrees.
  const LatLng(this.latitude, this.longitude);

  /// Latitude in radians
  double get latitudeInRad => degToRadian(latitude);

  /// Longitude in radians
  double get longitudeInRad => degToRadian(longitude);

  /// Returns true if latitude is between -90 and 90 and longitude is between -180 and 180.
  bool get isValid =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  /// Returns the world number (always 0 for normal [LatLng]).
  int get worldNumber => 0;

  /// Converts this [LatLng] into a world-aware [WorldLatLng], automatically parsing
  /// its longitude as an absolute (unspooled) coordinate if it exceeds `[-180, 180]`.
  WorldLatLng toWorld() => WorldLatLng(latitude, longitude);

  /// Converts this [LatLng] into a world-aware [WorldLatLng] with the specified [worldNumber].
  WorldLatLng toWorldIn({required final int worldNumber}) =>
      WorldLatLng.inWorld(latitude, longitude, worldNumber: worldNumber);

  /// Creates a [LatLng] from JSON map.
  LatLng.fromJson(Map<String, dynamic> json)
      : this((json['coordinates'][1] as num).toDouble(),
            (json['coordinates'][0] as num).toDouble());

  /// Converts [LatLng] to JSON map.
  Map<String, dynamic> toJson() => {
        'coordinates': [longitude, latitude]
      };

  @override
  String toString() =>
      'LatLng(latitude:${NumberFormat("0.0#####").format(latitude)}, '
      'longitude:${NumberFormat("0.0#####").format(longitude)})';

  /// Converts sexagesimal string into a lat/long value
  ///
  ///     final LatLng p1 = LatLng.fromSexagesimal('''51° 31' 10.11" N, 19° 22' 32.00" W''');
  ///     print("${p1.latitude}, ${p1.longitude}");
  ///     // Shows:
  ///     51.519475, -19.37555556
  ///
  factory LatLng.fromSexagesimal(final String str) {
    double lat = 0.0;
    double lng = 0.0;
    // try format '''47° 09' 53.57" N, 8° 32' 09.04" E'''
    var splits = str.split(',');
    if (splits.length != 2) {
      // try format '''N 47°08'52.57" E 8°32'09.04"'''
      splits = str.split('E');
      if (splits.length != 2) {
        // try format '''N 47°08'52.57" W 8°32'09.04"'''
        splits = str.split('W');
        if (splits.length != 2) {
          throw ArgumentError.value(
              str, 'str', 'Unsupported sexagesimal format');
        }
      }
    }
    lat = sexagesimal2decimal(splits[0]);
    lng = sexagesimal2decimal(splits[1]);
    if (str.contains('S')) {
      lat = -lat;
    }
    if (str.contains('W')) {
      lng = -lng;
    }
    return LatLng(lat, lng);
  }

  /// Converts lat/long values into sexagesimal
  ///
  ///     final LatLng p1 = LatLng(51.519475, -19.37555556);
  ///
  ///     // Shows: 51° 31' 10.11" N, 19° 22' 32.00" W
  ///     print(p1..toSexagesimal());
  ///
  String toSexagesimal() {
    var latDirection = latitude >= 0 ? 'N' : 'S';
    var lonDirection = longitude >= 0 ? 'E' : 'W';
    return '${decimal2sexagesimal(latitude)} $latDirection, ${decimal2sexagesimal(longitude)} $lonDirection';
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  bool operator ==(final Object other) =>
      other is LatLng &&
      latitude == other.latitude &&
      longitude == other.longitude;

  /// Rounds latitude and longitude to given number of decimals.
  LatLng round({final int decimals = 6}) => LatLng(
      _round(latitude, decimals: decimals),
      _round(longitude, decimals: decimals));

  //- private -----------------------------------------------------------------------------------

  /// No qualifier for top level functions in Dart. Had to copy this function
  double _round(final double value, {final int decimals = 6}) =>
      (value * pow(10, decimals)).round() / pow(10, decimals);
}

/// A world-aware extension of [LatLng] that explicitly tracks the [worldNumber]
/// for multi-world paths and antimeridian crossings.
class WorldLatLng extends LatLng {
  /// The world number (e.g., 0 for [-180, 180), 1 for [180, 540), etc.).
  @override
  final int worldNumber;
  final double _localLongitude;

  /// Creates a [WorldLatLng] from an absolute (unspooled) longitude,
  /// automatically calculating the [worldNumber] and local longitude.
  WorldLatLng(double latitude, double absoluteLongitude)
      : worldNumber = _calcWorld(absoluteLongitude),
        _localLongitude = _calcLocal(absoluteLongitude),
        super(latitude, _calcLocal(absoluteLongitude));

  /// Creates a [WorldLatLng] explicitly specifying [localLongitude] and [worldNumber].
  const WorldLatLng.inWorld(
    super.latitude,
    super.localLongitude, {
    required this.worldNumber,
  }) : _localLongitude = localLongitude;

  static int _calcWorld(double absLng) => ((absLng + 180.0) / 360.0).floor();

  static double _calcLocal(double absLng) =>
      absLng - (_calcWorld(absLng) * 360.0);

  /// Converts this [WorldLatLng] into a standard (normal) [LatLng] using its local longitude.
  LatLng toLatLng() => LatLng(latitude, localLongitude);

  /// Converts this [WorldLatLng] into a standard (normal) [LatLng] retaining
  /// its absolute (unspooled) longitude (which may exceed `[-180, 180]`).
  LatLng toAbsoluteLatLng() => LatLng(latitude, longitude);

  /// The absolute longitude adjusted by the [worldNumber] (localLongitude + worldNumber * 360°).
  @override
  double get longitude => _localLongitude + (worldNumber * 360.0);

  /// The local longitude in the base world range `[-180, 180]`.
  double get localLongitude => _localLongitude;

  /// Longitude in radians based on the local geographic longitude.
  @override
  double get longitudeInRad => degToRadian(_localLongitude);

  @override
  bool get isValid =>
      latitude >= -90 &&
      latitude <= 90 &&
      _localLongitude >= -180 &&
      _localLongitude <= 180;

  @override
  int get hashCode => Object.hash(latitude, _localLongitude, worldNumber);

  @override
  bool operator ==(final Object other) =>
      other is WorldLatLng &&
      latitude == other.latitude &&
      _localLongitude == other.localLongitude &&
      worldNumber == other.worldNumber;

  @override
  String toString() =>
      'WorldLatLng(latitude:${NumberFormat("0.0#####").format(latitude)}, '
      'longitude:${NumberFormat("0.0#####").format(longitude)}, '
      'localLongitude:${NumberFormat("0.0#####").format(_localLongitude)}, '
      'worldNumber:$worldNumber)';
}
