@Tags(['compiler'])
library;

import 'package:primal/compiler/lexical/lexeme.dart';
import 'package:primal/compiler/models/located.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:test/test.dart';

void main() {
  group('Lexeme', () {
    test('add() appends character value correctly', () {
      const lexeme = Lexeme(
        value: 'abc',
        location: Location(row: 1, column: 1),
      );

      final Lexeme result = lexeme.add('d');

      expect(result.value, equals('abcd'));
    });

    test('add() preserves original location', () {
      const originalLocation = Location(row: 5, column: 10);
      const lexeme = Lexeme(
        value: 'hello',
        location: originalLocation,
      );

      final Lexeme result = lexeme.add('!');

      expect(result.location, equals(originalLocation));
    });

    test('chaining multiple add() calls', () {
      const lexeme = Lexeme(
        value: '',
        location: Location(row: 1, column: 1),
      );

      final Lexeme result = lexeme.add('a').add('b').add('c');

      expect(result.value, equals('abc'));
    });

    test('add() returns new immutable Lexeme', () {
      const original = Lexeme(
        value: 'test',
        location: Location(row: 1, column: 1),
      );

      final Lexeme modified = original.add('!');

      expect(original.value, equals('test'));
      expect(modified.value, equals('test!'));
      expect(identical(original, modified), isFalse);
    });

    test('add() with empty string', () {
      const lexeme = Lexeme(
        value: 'hello',
        location: Location(row: 1, column: 1),
      );

      final Lexeme result = lexeme.add('');

      expect(result.value, equals('hello'));
    });

    test('add() with multi-character string', () {
      const lexeme = Lexeme(
        value: 'pre',
        location: Location(row: 1, column: 1),
      );

      final Lexeme result = lexeme.add('fix');

      expect(result.value, equals('prefix'));
    });

    test('equality', () {
      const lexeme1 = Lexeme(
        value: 'test',
        location: Location(row: 1, column: 1),
      );
      const lexeme2 = Lexeme(
        value: 'test',
        location: Location(row: 1, column: 1),
      );
      const lexeme3 = Lexeme(
        value: 'test',
        location: Location(row: 2, column: 1),
      );

      expect(lexeme1, equals(lexeme2));
      expect(lexeme1, isNot(equals(lexeme3)));
    });

    test('hashCode is consistent with equality', () {
      const lexeme1 = Lexeme(
        value: 'test',
        location: Location(row: 1, column: 1),
      );
      const lexeme2 = Lexeme(
        value: 'test',
        location: Location(row: 1, column: 1),
      );

      expect(lexeme1.hashCode, equals(lexeme2.hashCode));
    });

    test('toString() format', () {
      const lexeme = Lexeme(
        value: 'hello',
        location: Location(row: 3, column: 7),
      );

      expect(lexeme.toString(), equals('"hello" at [3, 7]'));
    });

    test('toString() with empty value', () {
      const lexeme = Lexeme(
        value: '',
        location: Location(row: 1, column: 1),
      );

      expect(lexeme.toString(), equals('"" at [1, 1]'));
    });

    test('toString() with special characters', () {
      const lexeme = Lexeme(
        value: 'a\tb\nc',
        location: Location(row: 2, column: 5),
      );

      expect(lexeme.toString(), equals('"a\tb\nc" at [2, 5]'));
    });

    group('equality edge cases', () {
      test('self-equality with identical object', () {
        const lexeme = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme == lexeme, isTrue);
      });

      test('different value same location', () {
        const lexeme1 = Lexeme(
          value: 'abc',
          location: Location(row: 1, column: 1),
        );
        const lexeme2 = Lexeme(
          value: 'xyz',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme1, isNot(equals(lexeme2)));
      });

      test('same value different column', () {
        const lexeme1 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );
        const lexeme2 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 5),
        );

        expect(lexeme1, isNot(equals(lexeme2)));
      });

      test('equality with non-Lexeme object returns false', () {
        const Lexeme lexeme = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );
        // Use dynamic to test the equality operator with different types
        expect(lexeme == ('test' as dynamic), isFalse);
        expect(lexeme == (42 as dynamic), isFalse);
        expect(lexeme == (Object() as dynamic), isFalse);
      });
    });

    group('hashCode edge cases', () {
      test('different values produce different hashCodes', () {
        const lexeme1 = Lexeme(
          value: 'abc',
          location: Location(row: 1, column: 1),
        );
        const lexeme2 = Lexeme(
          value: 'xyz',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme1.hashCode, isNot(equals(lexeme2.hashCode)));
      });

      test('different locations produce different hashCodes', () {
        const lexeme1 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );
        const lexeme2 = Lexeme(
          value: 'test',
          location: Location(row: 2, column: 3),
        );

        expect(lexeme1.hashCode, isNot(equals(lexeme2.hashCode)));
      });
    });

    group('constructor edge cases', () {
      test('empty value', () {
        const lexeme = Lexeme(
          value: '',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme.value, equals(''));
        expect(lexeme.location, equals(const Location(row: 1, column: 1)));
      });

      test('special characters in value', () {
        const lexeme = Lexeme(
          value: '\t\n\r',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme.value, equals('\t\n\r'));
      });

      test('unicode characters in value', () {
        const lexeme = Lexeme(
          value: '\u{1F600}\u03B1',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme.value, equals('\u{1F600}\u03B1'));
      });

      test('boundary location values', () {
        const lexeme = Lexeme(
          value: 'test',
          location: Location(row: 0, column: 0),
        );

        expect(lexeme.location.row, equals(0));
        expect(lexeme.location.column, equals(0));
      });

      test('large location values', () {
        const lexeme = Lexeme(
          value: 'test',
          location: Location(row: 999999, column: 999999),
        );

        expect(lexeme.location.row, equals(999999));
        expect(lexeme.location.column, equals(999999));
      });
    });

    group('add() edge cases', () {
      test('add() with special characters', () {
        const lexeme = Lexeme(
          value: 'line1',
          location: Location(row: 1, column: 1),
        );

        final Lexeme result = lexeme.add('\n').add('line2');

        expect(result.value, equals('line1\nline2'));
      });

      test('add() with unicode characters', () {
        const lexeme = Lexeme(
          value: 'smile: ',
          location: Location(row: 1, column: 1),
        );

        final Lexeme result = lexeme.add('\u{1F600}');

        expect(result.value, equals('smile: \u{1F600}'));
      });

      test('add() with tab character', () {
        const lexeme = Lexeme(
          value: 'col1',
          location: Location(row: 1, column: 1),
        );

        final Lexeme result = lexeme.add('\t').add('col2');

        expect(result.value, equals('col1\tcol2'));
      });

      test('add() starting from empty builds complete string', () {
        const lexeme = Lexeme(
          value: '',
          location: Location(row: 1, column: 1),
        );

        final Lexeme result = lexeme
            .add('h')
            .add('e')
            .add('l')
            .add('l')
            .add('o');

        expect(result.value, equals('hello'));
        expect(result.location, equals(const Location(row: 1, column: 1)));
      });

      test('add() does not modify original when chained', () {
        const original = Lexeme(
          value: 'a',
          location: Location(row: 1, column: 1),
        );

        final Lexeme step1 = original.add('b');
        final Lexeme step2 = step1.add('c');

        expect(original.value, equals('a'));
        expect(step1.value, equals('ab'));
        expect(step2.value, equals('abc'));
      });
    });

    group('value property', () {
      test('value is accessible', () {
        const lexeme = Lexeme(
          value: 'myvalue',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme.value, equals('myvalue'));
      });
    });

    group('location property', () {
      test('location is accessible', () {
        const location = Location(row: 10, column: 20);
        const lexeme = Lexeme(
          value: 'test',
          location: location,
        );

        expect(lexeme.location, equals(location));
        expect(lexeme.location.row, equals(10));
        expect(lexeme.location.column, equals(20));
      });
    });

    group('inheritance from Located', () {
      test('Lexeme is a Located instance', () {
        const Lexeme lexeme = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme, isA<Located>());
      });

      test('location is inherited from Located', () {
        const location = Location(row: 5, column: 10);
        const Lexeme lexeme = Lexeme(
          value: 'test',
          location: location,
        );

        const Located locatedReference = lexeme;

        expect(locatedReference.location, equals(location));
      });
    });

    group('const constructor', () {
      test('identical const Lexemes are the same instance', () {
        const Lexeme lexeme1 = Lexeme(
          value: 'same',
          location: Location(row: 1, column: 1),
        );
        const Lexeme lexeme2 = Lexeme(
          value: 'same',
          location: Location(row: 1, column: 1),
        );

        expect(identical(lexeme1, lexeme2), isTrue);
      });

      test('different const Lexemes are not the same instance', () {
        const Lexeme lexeme1 = Lexeme(
          value: 'first',
          location: Location(row: 1, column: 1),
        );
        const Lexeme lexeme2 = Lexeme(
          value: 'second',
          location: Location(row: 1, column: 1),
        );

        expect(identical(lexeme1, lexeme2), isFalse);
      });
    });

    group('long string handling', () {
      test('constructor with very long value', () {
        final String longValue = 'x' * 10000;
        final Lexeme lexeme = Lexeme(
          value: longValue,
          location: const Location(row: 1, column: 1),
        );

        expect(lexeme.value.length, equals(10000));
        expect(lexeme.value, equals(longValue));
      });

      test('add() with very long string', () {
        const Lexeme lexeme = Lexeme(
          value: 'prefix',
          location: Location(row: 1, column: 1),
        );

        final String longSuffix = 'y' * 5000;
        final Lexeme result = lexeme.add(longSuffix);

        expect(result.value, equals('prefix$longSuffix'));
        expect(result.value.length, equals(5006));
      });

      test('toString() with very long value', () {
        final String longValue = 'a' * 100;
        final Lexeme lexeme = Lexeme(
          value: longValue,
          location: const Location(row: 1, column: 1),
        );

        expect(lexeme.toString(), equals('"$longValue" at [1, 1]'));
      });
    });

    group('whitespace value handling', () {
      test('value containing only spaces', () {
        const Lexeme lexeme = Lexeme(
          value: '   ',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme.value, equals('   '));
      });

      test('value containing mixed whitespace', () {
        const Lexeme lexeme = Lexeme(
          value: ' \t \n ',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme.value, equals(' \t \n '));
      });

      test('add() whitespace to existing value', () {
        const Lexeme lexeme = Lexeme(
          value: 'word',
          location: Location(row: 1, column: 1),
        );

        final Lexeme result = lexeme.add('   ');

        expect(result.value, equals('word   '));
      });
    });

    group('negative location values', () {
      test('negative row value', () {
        const Lexeme lexeme = Lexeme(
          value: 'test',
          location: Location(row: -1, column: 1),
        );

        expect(lexeme.location.row, equals(-1));
      });

      test('negative column value', () {
        const Lexeme lexeme = Lexeme(
          value: 'test',
          location: Location(row: 1, column: -1),
        );

        expect(lexeme.location.column, equals(-1));
      });
    });
  });
}
