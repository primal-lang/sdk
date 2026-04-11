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

      test('equality is symmetric', () {
        const Lexeme lexeme1 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );
        const Lexeme lexeme2 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme1 == lexeme2, isTrue);
        expect(lexeme2 == lexeme1, isTrue);
      });

      test('equality is transitive', () {
        const Lexeme lexeme1 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );
        const Lexeme lexeme2 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );
        const Lexeme lexeme3 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme1 == lexeme2, isTrue);
        expect(lexeme2 == lexeme3, isTrue);
        expect(lexeme1 == lexeme3, isTrue);
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

      test('hashCode is stable across multiple calls', () {
        const Lexeme lexeme = Lexeme(
          value: 'stable',
          location: Location(row: 1, column: 1),
        );

        final int hash1 = lexeme.hashCode;
        final int hash2 = lexeme.hashCode;
        final int hash3 = lexeme.hashCode;

        expect(hash1, equals(hash2));
        expect(hash2, equals(hash3));
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

      test('both negative row and column values', () {
        const Lexeme lexeme = Lexeme(
          value: 'test',
          location: Location(row: -5, column: -10),
        );

        expect(lexeme.location.row, equals(-5));
        expect(lexeme.location.column, equals(-10));
      });
    });

    group('single character edge cases', () {
      test('constructor with single character value', () {
        const Lexeme lexeme = Lexeme(
          value: 'x',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme.value, equals('x'));
        expect(lexeme.value.length, equals(1));
      });

      test('add() single character to empty value', () {
        const Lexeme lexeme = Lexeme(
          value: '',
          location: Location(row: 1, column: 1),
        );

        final Lexeme result = lexeme.add('z');

        expect(result.value, equals('z'));
        expect(result.value.length, equals(1));
      });

      test('add() single character to existing value', () {
        const Lexeme lexeme = Lexeme(
          value: 'abc',
          location: Location(row: 1, column: 1),
        );

        final Lexeme result = lexeme.add('d');

        expect(result.value, equals('abcd'));
      });
    });

    group('multiple empty add operations', () {
      test('multiple empty adds do not change value', () {
        const Lexeme lexeme = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );

        final Lexeme result = lexeme.add('').add('').add('');

        expect(result.value, equals('test'));
      });

      test('empty adds interspersed with real adds', () {
        const Lexeme lexeme = Lexeme(
          value: 'a',
          location: Location(row: 1, column: 1),
        );

        final Lexeme result = lexeme.add('').add('b').add('').add('c').add('');

        expect(result.value, equals('abc'));
      });
    });

    group('collection behavior', () {
      test('Lexeme works correctly in Set', () {
        const Lexeme lexeme1 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );
        const Lexeme lexeme2 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );
        const Lexeme lexeme3 = Lexeme(
          value: 'different',
          location: Location(row: 1, column: 1),
        );

        // ignore: equal_elements_in_set
        final Set<Lexeme> lexemeSet = {lexeme1, lexeme2, lexeme3};

        expect(lexemeSet.length, equals(2));
        expect(lexemeSet.contains(lexeme1), isTrue);
        expect(lexemeSet.contains(lexeme3), isTrue);
      });

      test('Lexeme works correctly as Map key', () {
        const Lexeme key1 = Lexeme(
          value: 'key1',
          location: Location(row: 1, column: 1),
        );
        const Lexeme key1Duplicate = Lexeme(
          value: 'key1',
          location: Location(row: 1, column: 1),
        );
        const Lexeme key2 = Lexeme(
          value: 'key2',
          location: Location(row: 2, column: 2),
        );

        final Map<Lexeme, String> map = {
          key1: 'value1',
          key2: 'value2',
        };

        expect(map[key1], equals('value1'));
        expect(map[key1Duplicate], equals('value1'));
        expect(map[key2], equals('value2'));
        expect(map.length, equals(2));
      });

      test('Lexeme lookup in Set with different instance', () {
        const Lexeme original = Lexeme(
          value: 'lookup',
          location: Location(row: 5, column: 10),
        );
        const Lexeme lookup = Lexeme(
          value: 'lookup',
          location: Location(row: 5, column: 10),
        );

        final Set<Lexeme> set = {original};

        expect(set.contains(lookup), isTrue);
      });
    });

    group('equality with different location components', () {
      test('same value different row only', () {
        const Lexeme lexeme1 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 5),
        );
        const Lexeme lexeme2 = Lexeme(
          value: 'test',
          location: Location(row: 2, column: 5),
        );

        expect(lexeme1, isNot(equals(lexeme2)));
        expect(lexeme1.hashCode, isNot(equals(lexeme2.hashCode)));
      });

      test('same value same row different column', () {
        const Lexeme lexeme1 = Lexeme(
          value: 'test',
          location: Location(row: 3, column: 1),
        );
        const Lexeme lexeme2 = Lexeme(
          value: 'test',
          location: Location(row: 3, column: 2),
        );

        expect(lexeme1, isNot(equals(lexeme2)));
        expect(lexeme1.hashCode, isNot(equals(lexeme2.hashCode)));
      });
    });

    group('empty value edge cases', () {
      test('two empty Lexemes with same location are equal', () {
        const Lexeme lexeme1 = Lexeme(
          value: '',
          location: Location(row: 1, column: 1),
        );
        const Lexeme lexeme2 = Lexeme(
          value: '',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme1, equals(lexeme2));
        expect(lexeme1.hashCode, equals(lexeme2.hashCode));
      });

      test('two empty Lexemes with different locations are not equal', () {
        const Lexeme lexeme1 = Lexeme(
          value: '',
          location: Location(row: 1, column: 1),
        );
        const Lexeme lexeme2 = Lexeme(
          value: '',
          location: Location(row: 2, column: 2),
        );

        expect(lexeme1, isNot(equals(lexeme2)));
      });

      test('empty Lexeme not equal to non-empty Lexeme', () {
        const Lexeme emptyLexeme = Lexeme(
          value: '',
          location: Location(row: 1, column: 1),
        );
        const Lexeme nonEmptyLexeme = Lexeme(
          value: 'a',
          location: Location(row: 1, column: 1),
        );

        expect(emptyLexeme, isNot(equals(nonEmptyLexeme)));
      });
    });

    group('cross-type equality', () {
      test('Lexeme not equal to Located with same location', () {
        const Lexeme lexeme = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );
        const Located located = Located(
          location: Location(row: 1, column: 1),
        );

        expect(lexeme == located, isFalse);
      });

      test('Lexeme equality check with null via dynamic', () {
        const Lexeme lexeme = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme == (null as dynamic), isFalse);
      });
    });

    group('toString edge cases', () {
      test('toString with single character value', () {
        const Lexeme lexeme = Lexeme(
          value: 'x',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme.toString(), equals('"x" at [1, 1]'));
      });

      test('toString with value containing quotes', () {
        const Lexeme lexeme = Lexeme(
          value: 'say "hello"',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme.toString(), equals('"say "hello"" at [1, 1]'));
      });

      test('toString with carriage return', () {
        const Lexeme lexeme = Lexeme(
          value: 'line\r',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme.toString(), equals('"line\r" at [1, 1]'));
      });

      test('toString with negative location values', () {
        const Lexeme lexeme = Lexeme(
          value: 'test',
          location: Location(row: -1, column: -2),
        );

        expect(lexeme.toString(), equals('"test" at [-1, -2]'));
      });
    });

    group('add() return type', () {
      test('add() returns Lexeme type not Located', () {
        const Lexeme lexeme = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );

        final Lexeme result = lexeme.add('!');

        expect(result, isA<Lexeme>());
        expect(result.runtimeType, equals(Lexeme));
      });

      test('add() result has correct value property', () {
        const Lexeme lexeme = Lexeme(
          value: 'hello',
          location: Location(row: 1, column: 1),
        );

        final Lexeme result = lexeme.add(' world');

        expect(result.value, equals('hello world'));
      });
    });

    group('hashCode distribution', () {
      test('similar values produce different hashCodes', () {
        const Lexeme lexeme1 = Lexeme(
          value: 'aaa',
          location: Location(row: 1, column: 1),
        );
        const Lexeme lexeme2 = Lexeme(
          value: 'aab',
          location: Location(row: 1, column: 1),
        );
        const Lexeme lexeme3 = Lexeme(
          value: 'aba',
          location: Location(row: 1, column: 1),
        );

        final Set<int> hashCodes = {
          lexeme1.hashCode,
          lexeme2.hashCode,
          lexeme3.hashCode,
        };

        expect(hashCodes.length, equals(3));
      });

      test('adjacent locations produce different hashCodes', () {
        const Lexeme lexeme1 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 1),
        );
        const Lexeme lexeme2 = Lexeme(
          value: 'test',
          location: Location(row: 1, column: 2),
        );
        const Lexeme lexeme3 = Lexeme(
          value: 'test',
          location: Location(row: 2, column: 1),
        );

        final Set<int> hashCodes = {
          lexeme1.hashCode,
          lexeme2.hashCode,
          lexeme3.hashCode,
        };

        expect(hashCodes.length, equals(3));
      });
    });

    group('immutability guarantees', () {
      test('original lexeme unchanged after multiple operations', () {
        const Lexeme original = Lexeme(
          value: 'original',
          location: Location(row: 1, column: 1),
        );

        final Lexeme result1 = original.add('1');
        final Lexeme result2 = original.add('2');
        final Lexeme result3 = result1.add('3');

        expect(original.value, equals('original'));
        expect(result1.value, equals('original1'));
        expect(result2.value, equals('original2'));
        expect(result3.value, equals('original13'));
      });

      test('location remains unchanged through add operations', () {
        const Location originalLocation = Location(row: 10, column: 20);
        const Lexeme lexeme = Lexeme(
          value: 'start',
          location: originalLocation,
        );

        final Lexeme result = lexeme.add('middle').add('end');

        expect(result.location, equals(originalLocation));
        expect(result.location.row, equals(10));
        expect(result.location.column, equals(20));
      });
    });

    group('escape sequence handling', () {
      test('value with backslash', () {
        const Lexeme lexeme = Lexeme(
          value: 'path\\to\\file',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme.value, equals('path\\to\\file'));
      });

      test('value with null character', () {
        const Lexeme lexeme = Lexeme(
          value: 'before\x00after',
          location: Location(row: 1, column: 1),
        );

        expect(lexeme.value, equals('before\x00after'));
        expect(lexeme.value.length, equals(12));
      });

      test('add() with backslash', () {
        const Lexeme lexeme = Lexeme(
          value: 'C:',
          location: Location(row: 1, column: 1),
        );

        final Lexeme result = lexeme.add('\\Users');

        expect(result.value, equals('C:\\Users'));
      });
    });
  });
}
