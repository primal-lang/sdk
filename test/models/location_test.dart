@Tags(['unit'])
library;

import 'package:primal/compiler/models/located.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:test/test.dart';

void main() {
  group('Location', () {
    test('stores row and column', () {
      const Location loc = Location(row: 1, column: 5);
      expect(loc.row, 1);
      expect(loc.column, 5);
    });

    test('toString returns [row, column] format', () {
      const Location loc = Location(row: 3, column: 10);
      expect(loc.toString(), '[3, 10]');
    });

    test('zero-based position', () {
      const Location loc = Location(row: 0, column: 0);
      expect(loc.toString(), '[0, 0]');
    });

    test('large row and column values', () {
      const Location loc = Location(row: 999, column: 500);
      expect(loc.row, 999);
      expect(loc.column, 500);
      expect(loc.toString(), '[999, 500]');
    });
  });

  group('Located', () {
    test('stores location', () {
      const Location loc = Location(row: 2, column: 4);
      const Located located = Located(location: loc);
      expect(located.location.row, 2);
      expect(located.location.column, 4);
    });
  });
}
