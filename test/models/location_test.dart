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

    group('equality', () {
      test('equals location with same row and column', () {
        const Location first = Location(row: 5, column: 10);
        const Location second = Location(row: 5, column: 10);
        expect(first == second, isTrue);
      });

      test('not equal when row differs', () {
        const Location first = Location(row: 5, column: 10);
        const Location second = Location(row: 6, column: 10);
        expect(first == second, isFalse);
      });

      test('not equal when column differs', () {
        const Location first = Location(row: 5, column: 10);
        const Location second = Location(row: 5, column: 11);
        expect(first == second, isFalse);
      });

      test('not equal when both row and column differ', () {
        const Location first = Location(row: 5, column: 10);
        const Location second = Location(row: 6, column: 11);
        expect(first == second, isFalse);
      });

      test('equals itself via identity', () {
        const Location location = Location(row: 5, column: 10);
        expect(location == location, isTrue);
      });

      test('not equal to non-Location object', () {
        const Location location = Location(row: 5, column: 10);
        expect(location == Object(), isFalse);
      });
    });

    group('hashCode', () {
      test('equal locations have same hashCode', () {
        const Location first = Location(row: 5, column: 10);
        const Location second = Location(row: 5, column: 10);
        expect(first.hashCode, second.hashCode);
      });

      test('different locations typically have different hashCodes', () {
        const Location first = Location(row: 5, column: 10);
        const Location second = Location(row: 6, column: 11);
        expect(first.hashCode, isNot(second.hashCode));
      });
    });

    test('const constructor creates compile-time constants', () {
      const Location first = Location(row: 1, column: 2);
      const Location second = Location(row: 1, column: 2);
      expect(identical(first, second), isTrue);
    });
  });

  group('Located', () {
    test('stores location', () {
      const Location location = Location(row: 2, column: 4);
      const Located located = Located(location: location);
      expect(located.location.row, 2);
      expect(located.location.column, 4);
    });

    group('equality', () {
      test('equals located with same location', () {
        const Location location = Location(row: 2, column: 4);
        const Located first = Located(location: location);
        const Located second = Located(location: location);
        expect(first == second, isTrue);
      });

      test('equals located with equivalent location', () {
        const Located first = Located(location: Location(row: 2, column: 4));
        const Located second = Located(location: Location(row: 2, column: 4));
        expect(first == second, isTrue);
      });

      test('not equal when locations differ', () {
        const Located first = Located(location: Location(row: 2, column: 4));
        const Located second = Located(location: Location(row: 3, column: 5));
        expect(first == second, isFalse);
      });

      test('equals itself via identity', () {
        const Located located = Located(location: Location(row: 2, column: 4));
        expect(located == located, isTrue);
      });

      test('not equal to non-Located object', () {
        const Located located = Located(location: Location(row: 2, column: 4));
        expect(located == Object(), isFalse);
      });
    });

    group('hashCode', () {
      test('equal located objects have same hashCode', () {
        const Located first = Located(location: Location(row: 2, column: 4));
        const Located second = Located(location: Location(row: 2, column: 4));
        expect(first.hashCode, second.hashCode);
      });

      test('hashCode matches location hashCode', () {
        const Location location = Location(row: 2, column: 4);
        const Located located = Located(location: location);
        expect(located.hashCode, location.hashCode);
      });

      test('different located objects typically have different hashCodes', () {
        const Located first = Located(location: Location(row: 2, column: 4));
        const Located second = Located(location: Location(row: 3, column: 5));
        expect(first.hashCode, isNot(second.hashCode));
      });
    });

    test('const constructor creates compile-time constants', () {
      const Located first = Located(location: Location(row: 2, column: 4));
      const Located second = Located(location: Location(row: 2, column: 4));
      expect(identical(first, second), isTrue);
    });
  });
}
