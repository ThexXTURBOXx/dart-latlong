//@TestOn("content-shell")
import 'package:latlong2/latlong2.dart';
import 'package:test/test.dart';
// import 'package:logging/logging.dart';

// Browser
// import "package:console_log_handler/console_log_handler.dart";

// Commandline
// import "package:console_log_handler/print_log_handler.dart";

void main() async {
  // final Logger _logger = new Logger("test.LengthUnit");
  // configLogging();

  //await saveDefaultCredentials();

  group('LengthUnit', () {
    setUp(() {});

    test('> Millimeter', () {
      expect(LengthUnit.millimeter.to(LengthUnit.millimeter, 1.0), 1.0);
      expect(LengthUnit.millimeter.to(LengthUnit.centimeter, 1.0), 0.1);
      expect(LengthUnit.millimeter.to(LengthUnit.meter, 1000.0), 1.0);
      expect(LengthUnit.millimeter.to(LengthUnit.kilometer, 1000000.0), 1);
    }); // end of 'Millimeter' test

    test('> Centimeter', () {
      expect(LengthUnit.centimeter.to(LengthUnit.centimeter, 1.0), 1.0);
      expect(LengthUnit.centimeter.to(LengthUnit.millimeter, 1.0), 10.0);
    }); // end of 'Centimeter' test

    test('> Meter', () {
      expect(LengthUnit.meter.to(LengthUnit.meter, 100.0), 100.0);
      expect(LengthUnit.meter.to(LengthUnit.kilometer, 1.0), 0.001);
    }); // end of 'Meter' test

    test('> Kilometer', () {
      expect(LengthUnit.kilometer.to(LengthUnit.kilometer, 1.0), 1.0);
      expect(LengthUnit.kilometer.to(LengthUnit.meter, 1.0), 1000.0);
    }); // end of 'Kilometer' test

    test('> Mike', () {
      expect((LengthUnit.mile.to(LengthUnit.meter, 1.0) * 100).round() / 100,
          1609.34);
    }); // end of 'Mike' test
  });
  // End of 'LengthUnit' group
}

// - Helper --------------------------------------------------------------------------------------
