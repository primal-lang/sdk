@Tags(['unit'])
library;

import 'package:primal/compiler/models/located.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:test/test.dart';

void main() {
  group('Location', () {
    test('stores row and column', () {
      const Location location = Location(row: 1, column: 5);
      expect(location.row, 1);
      expect(location.column, 5);
    });

    test('toString returns [row, column] format', () {
      const Location location = Location(row: 3, column: 10);
      expect(location.toString(), '[3, 10]');
    });

    test('zero-based position', () {
      const Location location = Location(row: 0, column: 0);
      expect(location.toString(), '[0, 0]');
    });

    test('large row and column values', () {
      const Location location = Location(row: 999, column: 500);
      expect(location.row, 999);
      expect(location.column, 500);
      expect(location.toString(), '[999, 500]');
    });
  });

  group('Located', () {
    test('stores location', () {
      const Location location = Location(row: 2, column: 4);
      const Located located = Located(location: location);
      expect(located.location.row, 2);
      expect(located.location.column, 4);
    });
  });
}
