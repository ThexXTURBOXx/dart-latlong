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

import 'package:latlong2/latlong2.dart';

/// A rectangular geographical bounding box defined by southwest and northeast corners.
class LatLngBounds {
  /// The southwest corner of the bounding box.
  final LatLng southWest;

  /// The northeast corner of the bounding box.
  final LatLng northEast;

  /// Creates a [LatLngBounds] from [southWest] and [northEast] coordinates.
  const LatLngBounds(this.southWest, this.northEast);

  /// Creates a [LatLngBounds] encompassing all given [points].
  factory LatLngBounds.fromPoints(final Iterable<LatLng> points) {
    if (points.isEmpty) {
      throw ArgumentError('Points must not be empty to create LatLngBounds.');
    }
    double? minLat, maxLat, minLng, maxLng;
    for (final p in points) {
      final lat = p.latitude;
      final lng = p
          .longitude; // Uses absolute longitude for WorldLatLng, standard for LatLng
      minLat = minLat == null ? lat : (lat < minLat ? lat : minLat);
      maxLat = maxLat == null ? lat : (lat > maxLat ? lat : maxLat);
      minLng = minLng == null ? lng : (lng < minLng ? lng : minLng);
      maxLng = maxLng == null ? lng : (lng > maxLng ? lng : maxLng);
    }
    return LatLngBounds(
      LatLng(minLat!, minLng!),
      LatLng(maxLat!, maxLng!),
    );
  }

  /// The southern latitude boundary.
  double get south => southWest.latitude;

  /// The northern latitude boundary.
  double get north => northEast.latitude;

  /// The western longitude boundary.
  double get west => southWest.longitude;

  /// The eastern longitude boundary.
  double get east => northEast.longitude;

  /// The geographical center point of the bounding box (normalized to [-180, 180]).
  LatLng get center {
    final rawLng = (west + east) / 2;
    final normalizedLng = ((rawLng + 180.0) % 360.0 + 360.0) % 360.0 - 180.0;
    return LatLng(
      (south + north) / 2,
      normalizedLng,
    );
  }

  /// The southeast corner of the bounding box.
  LatLng get southEast => LatLng(south, east);

  /// The northwest corner of the bounding box.
  LatLng get northWest => LatLng(north, west);

  /// Returns true if the bounding box contains the given [point].
  bool contains(final LatLng point) {
    final lng = point.longitude;
    return point.latitude >= south &&
        point.latitude <= north &&
        lng >= west &&
        lng <= east;
  }

  /// Returns true if this bounding box completely contains [other].
  bool containsBounds(final LatLngBounds other) {
    return other.south >= south &&
        other.north <= north &&
        other.west >= west &&
        other.east <= east;
  }

  /// Returns true if this bounding box overlaps with [other].
  bool isOverlapping(final LatLngBounds other) {
    return !(other.south > north ||
        other.north < south ||
        other.west > east ||
        other.east < west);
  }

  /// Returns a new [LatLngBounds] extended to include [point].
  LatLngBounds extend(final LatLng point) {
    final lng = point.longitude;
    return LatLngBounds(
      LatLng(
        point.latitude < south ? point.latitude : south,
        lng < west ? lng : west,
      ),
      LatLng(
        point.latitude > north ? point.latitude : north,
        lng > east ? lng : east,
      ),
    );
  }

  /// Returns a new [LatLngBounds] extended to include [other] bounds.
  LatLngBounds extendBounds(final LatLngBounds other) {
    return extend(other.southWest).extend(other.northEast);
  }

  /// Returns true if the bounds are valid (south <= north and west <= east).
  bool get isValid =>
      southWest.isValid && northEast.isValid && south <= north && west <= east;

  @override
  String toString() =>
      'LatLngBounds(southWest: $southWest, northEast: $northEast)';

  @override
  int get hashCode => Object.hash(southWest, northEast);

  @override
  bool operator ==(final Object other) =>
      other is LatLngBounds &&
      southWest == other.southWest &&
      northEast == other.northEast;
}
