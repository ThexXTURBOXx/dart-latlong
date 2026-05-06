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

import 'package:latlong2/latlong2.dart';

abstract class DistanceCalculator {
  double distance(final LatLng p1, final LatLng p2,
      {final SegmentDirection lngDir = SegmentDirection.lazy});

  LatLng offset(
      final LatLng from, final double distanceInMeter, final double bearing);
}

/// Determines how the longitudinal delta is interpreted when computing
/// the distance between two points on a geodesic.
///
/// Built-in instances are available as static constants. Custom directions
/// can be created by extending this class and overriding [effectiveDLng].
///
/// Resulted as part of a discussion in
/// [flutter_map](https://github.com/fleaflet/flutter_map/issues/2206).
abstract class SegmentDirection {
  const SegmentDirection();

  // ---------------------------------------------------------------------------
  // Built-in instances
  // ---------------------------------------------------------------------------

  /// Raw `p2 − p1` longitude difference. May accidentally take the long arc
  /// if the points straddle the antimeridian.
  static const laziest = _LaziestDirection();

  /// `(p2 − p1) mod (2*pi)` longitude difference. May accidentally take the
  /// long arc if the points straddle the antimeridian.
  /// May also be called "Greenwich" or similar.
  /// This is the same as the 0.x default behaviour.
  static const lazy = _LazyDirection();

  /// Always takes the shortest angular path. May still cross the antimeridian.
  static const shortestPath = _ShortestPathDirection();

  /// Always takes the longest angular path (> 180°). Complementary to
  /// [shortestPath]. Direction (east/west) follows whichever way [shortestPath]
  /// would go, but on the opposite arc.
  static const longestPath = _LongestPathDirection();

  /// Travels eastward (increasing longitude, wrapping at 180°).
  /// Returns 0 for coincident longitudes -> distance is 0.
  static const eastward = _EastwardDirection();

  /// Travels westward (decreasing longitude, wrapping at −180°).
  /// Returns 0 for coincident longitudes -> distance is 0.
  static const westward = _WestwardDirection();

  /// Like [eastward], but travels a full loop when longitudes coincide.
  static const strictlyEastward = _StrictlyEastwardDirection();

  /// Like [westward], but travels a full loop when longitudes coincide.
  static const strictlyWestward = _StrictlyWestwardDirection();

  // ---------------------------------------------------------------------------
  // Contract
  // ---------------------------------------------------------------------------

  /// Returns the effective longitudinal delta in radians that the distance
  /// formula should use.
  ///
  /// Values in `(−pi, pi]` are treated as the short arc.
  /// Values outside that range (absolute value > pi) are treated as the long
  /// arc by both [Haversine] and [Vincenty].
  double effectiveDLng(LatLng p1, LatLng p2);

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  /// Normalises [radians] to `(−pi, pi]`.
  static double normaliseShort(double radians) {
    final w = radians % tau; // always in [0, 2*pi)
    return w > pi ? w - tau : w; // remap (pi, 2*pi) to (−pi, 0)
  }

  /// Normalises [radians] to `[0, 2*pi)`, i.e. a strictly eastward range.
  static double normaliseEast(double radians) => ((radians % tau) + tau) % tau;

  /// Normalises [radians] to `(−2*pi, 0]`, i.e. a strictly westward range.
  static double normaliseWest(double radians) => -normaliseEast(-radians);
}

// =============================================================================
// Private implementations of the built-in directions
// =============================================================================

class _LaziestDirection extends SegmentDirection {
  const _LaziestDirection();

  @override
  double effectiveDLng(LatLng p1, LatLng p2) =>
      p2.longitudeInRad - p1.longitudeInRad;
}

class _LazyDirection extends SegmentDirection {
  const _LazyDirection();

  @override
  double effectiveDLng(LatLng p1, LatLng p2) =>
      (p2.longitudeInRad - p1.longitudeInRad).remainder(tau);
}

class _ShortestPathDirection extends SegmentDirection {
  const _ShortestPathDirection();

  @override
  double effectiveDLng(LatLng p1, LatLng p2) => SegmentDirection.normaliseShort(
        p2.longitudeInRad - p1.longitudeInRad,
      );
}

class _LongestPathDirection extends SegmentDirection {
  const _LongestPathDirection();

  @override
  double effectiveDLng(LatLng p1, LatLng p2) {
    final shortest = SegmentDirection.normaliseShort(
      p2.longitudeInRad - p1.longitudeInRad,
    );
    if (shortest == 0.0) return tau; // co-incident -> full eastward loop
    return shortest > 0 ? shortest - tau : shortest + tau;
  }
}

class _EastwardDirection extends SegmentDirection {
  const _EastwardDirection();

  @override
  double effectiveDLng(LatLng p1, LatLng p2) => SegmentDirection.normaliseEast(
        p2.longitudeInRad - p1.longitudeInRad,
      );
}

class _WestwardDirection extends SegmentDirection {
  const _WestwardDirection();

  @override
  double effectiveDLng(LatLng p1, LatLng p2) => SegmentDirection.normaliseWest(
        p2.longitudeInRad - p1.longitudeInRad,
      );
}

class _StrictlyEastwardDirection extends SegmentDirection {
  const _StrictlyEastwardDirection();

  @override
  double effectiveDLng(LatLng p1, LatLng p2) {
    final e = SegmentDirection.normaliseEast(
      p2.longitudeInRad - p1.longitudeInRad,
    );
    return e == 0.0 ? tau : e;
  }
}

class _StrictlyWestwardDirection extends SegmentDirection {
  const _StrictlyWestwardDirection();

  @override
  double effectiveDLng(LatLng p1, LatLng p2) {
    final w = SegmentDirection.normaliseWest(
      p2.longitudeInRad - p1.longitudeInRad,
    );
    return w == 0.0 ? -tau : w;
  }
}
