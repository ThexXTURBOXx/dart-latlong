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
import 'package:latlong2/spline.dart';

/// Necessary for creating new instances T extends LatLng (Path&lt;T extends LatLng&rt;)
///
///     class Location extends LatLng {
///         ....
///     }
///
///     final Path<Location> path = Path<Location>(factory: locationFactory);
///
typedef LatLngFactory = LatLng Function(double latitude, double longitude);

LatLng _defaultLatLngFactory(final double latitude, final double longitude) =>
    LatLng(latitude, longitude);

/// Path of [LatLng] values that implements [Iterable<T>] for collection manipulation.
///
/// If you use [Path] with Generics - check out this sample:
///
///     class Location extends LatLng {
///         ....
///     }
///
///     final Path<Location> path = Path<Location>(factory: locationFactory);
///
class Path<T extends LatLng> extends Iterable<T> {
  /// Coordinates managed by this class.
  final List<T> _coordinates;

  /// For [Distance] calculations.
  final Distance _distance;

  /// Factory to instantiate new coordinates.
  final LatLngFactory _latLngFactory;

  /// Creates an empty path with optional [factory] and [distance] calculator.
  Path({
    final LatLngFactory factory = _defaultLatLngFactory,
    final Distance distance = const Distance(),
  })  : _coordinates = [],
        _latLngFactory = factory,
        _distance = distance;

  /// Creates a path from an iterable of [coordinates] with optional [factory] and [distance] calculator.
  Path.from(
    final Iterable<T> coordinates, {
    final LatLngFactory factory = _defaultLatLngFactory,
    final Distance distance = const Distance(),
  })  : _coordinates = List<T>.from(coordinates),
        _latLngFactory = factory,
        _distance = distance;

  /// Returns the list of coordinates managed by this path.
  List<T> get coordinates => _coordinates;

  /// The distance calculator configured for this path.
  Distance get distanceCalculator => _distance;

  /// Removes all coordinates from the path.
  void clear() => _coordinates.clear();

  /// Adds a new coordinate [value] to the path.
  void add(final T value) {
    _coordinates.add(value);
  }

  /// Adds all coordinates from [values] to the path.
  void addAll(final Iterable<T> values) {
    _coordinates.addAll(values);
  }

  /// Returns the first coordinate in the path.
  @override
  T get first => _coordinates.first;

  /// Returns the last coordinate in the path.
  @override
  T get last => _coordinates.last;

  /// Returns the number of coordinates in the path.
  @override
  int get length => _coordinates.length;

  /// Returns true if the path contains no coordinates.
  @override
  bool get isEmpty => _coordinates.isEmpty;

  /// Returns true if the path contains one or more coordinates.
  @override
  bool get isNotEmpty => _coordinates.isNotEmpty;

  /// Returns an iterator over the path coordinates.
  @override
  Iterator<T> get iterator => _coordinates.iterator;

  /// Returns the coordinate at the specified [index].
  T operator [](final int index) => _coordinates[index];

  /// Sets the coordinate at the specified [index] to [value].
  void operator []=(final int index, final T value) {
    _coordinates[index] = value;
  }

  /// Removes [value] from the path.
  bool remove(Object? value) => _coordinates.remove(value);

  /// Removes and returns the coordinate at the specified [index].
  T removeAt(int index) => _coordinates.removeAt(index);

  /// Inserts [element] at the specified [index].
  void insert(int index, T element) => _coordinates.insert(index, element);

  /// Inserts all [iterable] elements at the specified [index].
  void insertAll(int index, Iterable<T> iterable) =>
      _coordinates.insertAll(index, iterable);

  /// Returns a sublist of coordinates from [start] to [end].
  List<T> sublist(int start, [int? end]) => _coordinates.sublist(start, end);

  /// Splits the path into even sections.
  ///
  /// The section size is defined with [distanceInMeterPerTime].
  /// [distanceInMeterPerTime] means that the original size on the given
  /// path will stay the same but the created section could be smaller because of the "linear distance"
  ///
  /// However - if you follow the steps in a given time then the distance from point to point (over time)
  /// is correct. (Almost - because of the curves generate with [CatmullRomSpline2D]
  ///
  ///     final Path path = Path.from(zigzag);
  ///
  /// If [smoothPath] is turned on than the minimum of 3 coordinates is required otherwise
  /// we need two
  Path equalize(final double distanceInMeterPerTime,
      {final bool smoothPath = true}) {
    if (distanceInMeterPerTime <= 0) {
      throw ArgumentError.value(distanceInMeterPerTime,
          'distanceInMeterPerTime', 'Distance must be greater than 0');
    }
    if (!((smoothPath && _coordinates.length >= 3) ||
        (!smoothPath && _coordinates.length >= 2))) {
      throw ArgumentError.value(smoothPath, 'smoothPath',
          'At least ${smoothPath ? 3 : 2} coordinates are needed to create the steps in between');
    }

    // If we "smooth" the path every second step becomes a spline - so every other step
    // becomes a "Keyframe". A step on the given path
    final stepDistance = smoothPath
        ? distanceInMeterPerTime * 2.0
        : distanceInMeterPerTime.toDouble();

    final baseLength = distance;
    if (baseLength < stepDistance) {
      throw ArgumentError.value(baseLength, 'baseLength',
          'Path distance must be at least ${stepDistance}mn (step distance)');
    }

    if (stepDistance > baseLength / 2) {
      print(
          'Warning: Equalizing the path (L: $baseLength) with a key-frame distance of $stepDistance leads to'
          'weired results. Turn of path smoothing.');
    }

    // no steps possible - so return an empty path
    if (baseLength == stepDistance) {
      return Path.from([_coordinates.first, _coordinates.last],
          factory: _latLngFactory, distance: _distance);
    }

    final tempCoordinates = List<T>.from(_coordinates);
    final path = Path(factory: _latLngFactory, distance: _distance);

    var remainingSteps = 0.0;
    double bearing;

    path.add(tempCoordinates.first);
    var baseStep = tempCoordinates.first;

    for (var index = 0; index < coordinates.length - 1; index++) {
      final distance =
          _distance(tempCoordinates[index], tempCoordinates[index + 1]);

      // Remember the direction
      bearing =
          _distance.bearing(tempCoordinates[index], tempCoordinates[index + 1]);

      if (remainingSteps <= distance ||
          (stepDistance - remainingSteps) <= distance) {
        // First step position
        var firstStepPos = stepDistance - remainingSteps;

        final steps = ((distance - firstStepPos) / stepDistance) + 1;

        final fullSteps = steps.toInt();
        remainingSteps =
            round(fullSteps > 0 ? steps % fullSteps : steps, decimals: 6) *
                stepDistance;

        baseStep = tempCoordinates[index];

        for (var stepCounter = 0; stepCounter < fullSteps; stepCounter++) {
          // Add step on the given path
          // Intermediate step is necessary to stay type-safe
          final tempStep = _distance.offset(baseStep, firstStepPos, bearing);
          final nextStep =
              _latLngFactory(tempStep.latitude, tempStep.longitude);
          path.add(nextStep);
          firstStepPos += stepDistance;

          if (smoothPath) {
            // Now - split it
            CatmullRomSpline2D<double> spline;

            if (path.nrOfCoordinates == 3) {
              spline = _createSpline(path[0], path[0], path[1], path[2]);

              // Insert new point between 0 and 1
              path.coordinates.insert(1, _pointToLatLng(spline.percentage(50)));
            } else if (path.nrOfCoordinates > 3) {
              final baseIndex = path.nrOfCoordinates - 1;
              spline = _createSpline(path[baseIndex - 3], path[baseIndex - 2],
                  path[baseIndex - 1], path[baseIndex]);

              // Insert new point at last position - 2 (pushes the next 2 items down)
              path.coordinates
                  .insert(baseIndex - 1, _pointToLatLng(spline.percentage(50)));
            }
          }
        }
      } else {
        remainingSteps += distance;
      }
    }

    // If last step is on the same position as the last generated step
    // then don't add the last base step.
    if (baseStep.round() != tempCoordinates.last.round() &&
        baseStep.round() != tempCoordinates.first.round() &&
        round(_distance(baseStep, tempCoordinates.last)) > 1) {
      path.add(tempCoordinates.last);
    }

    if (smoothPath) {
      // Last Spline between the last 4 elements
      var baseIndex = path.nrOfCoordinates - 1;
      if (baseIndex > 3) {
        final spline = _createSpline(path[baseIndex - 3], path[baseIndex - 2],
            path[baseIndex - 1], path[baseIndex - 0]);

        path.coordinates
            .insert(baseIndex - 1, _pointToLatLng(spline.percentage(50)));
      }

      // Check if there is a remaining gap between the last two elements - close it
      // Could be because of reminder from path divisions
      baseIndex = path.nrOfCoordinates - 1;
      if (_distance(path[baseIndex - 1], path[baseIndex]) >= stepDistance) {
        final spline = _createSpline(path[baseIndex - 1], path[baseIndex - 1],
            path[baseIndex - 0], path[baseIndex - 0]);

        path.coordinates
            .insert(baseIndex, _pointToLatLng(spline.percentage(50)));
      }
    }

    // Make sure we have no duplicates!
    // _removeDuplicates();
    return path;
  }

  /// Sums up all the distances on the path using [LongitudeDirection.greenwich].
  ///
  ///     final Path path = Path.from(route);
  ///     print(path.distance);
  ///
  double get distance => distanceWith(lngDir: LongitudeDirection.greenwich);

  /// Sums up all the distances on the path using the specified [lngDir].
  double distanceWith(
      {final LongitudeDirection lngDir = LongitudeDirection.greenwich}) {
    final tempCoordinates = List<T>.from(_coordinates);
    var length = 0.0;

    for (var index = 0; index < coordinates.length - 1; index++) {
      length += _distance.distance(
          tempCoordinates[index], tempCoordinates[index + 1],
          lngDir: lngDir);
    }
    return round(length);
  }

  /// Returns the geographical bounding box ([LatLngBounds]) of the path coordinates.
  LatLngBounds get bounds {
    if (coordinates.isEmpty) {
      throw AssertionError('Coordinates must not be empty!');
    }
    return LatLngBounds.fromPoints(_coordinates);
  }

  /// Returns the number of coordinates in the path.
  ///
  ///     final Path path = Path.from(<LatLng>[ startPos,endPos ]);
  ///     final int nr = path.nrOfCoordinates; // nr == 2
  ///
  int get nrOfCoordinates => _coordinates.length;

  //- private -----------------------------------------------------------------------------------

  /// 4 Points are necessary to create a [CatmullRomSpline2D]
  CatmullRomSpline2D<double> _createSpline(
      final LatLng p0, final LatLng p1, final LatLng p2, final LatLng p3) {
    return CatmullRomSpline2D(
        Point2D(p0.latitude, p0.longitude),
        Point2D(p1.latitude, p1.longitude),
        Point2D(p2.latitude, p2.longitude),
        Point2D(p3.latitude, p3.longitude));
  }

  /// Convert [Point2D] to [LatLng]
  LatLng _pointToLatLng(final Point2D point) =>
      _latLngFactory(point.x, point.y);
}
