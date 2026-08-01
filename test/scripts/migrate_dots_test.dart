@Tags(['unit'])
library;

import 'dart:io';

import 'package:test/test.dart';

import '../../scripts/migrate_dots.dart';

/// A fixed library table, so the tests do not move when the real standard
/// library gains a function.
const Set<String> library = {'num_abs', 'list_map', 'assert_equal'};

String rewrite(String source) {
  final MigrationResult result = migrate(source, libraryNames: library);

  expect(
    result.isRefused,
    isFalse,
    reason: 'unexpected refusal: ${result.collisions}',
  );

  return result.source;
}

void main() {
  group('Migrate dots', () {
    group('Identifiers', () {
      test('Standard library call', () {
        expect(rewrite('main() = num.abs(-5)'), equals('main() = num_abs(-5)'));
      });

      test('User-defined dotted name', () {
        expect(
          rewrite('piEstimate.helper(i) = i\nmain() = piEstimate.helper(1)'),
          equals('piEstimate_helper(i) = i\nmain() = piEstimate_helper(1)'),
        );
      });

      test('Multiple dots in one name', () {
        expect(
          rewrite('test.factorial.base() = 1'),
          equals('test_factorial_base() = 1'),
        );
      });

      test('Trailing dot', () {
        expect(rewrite('foo.(n) = n'), equals('foo_(n) = n'));
      });

      test('Parameter names', () {
        expect(rewrite('foo(a.b) = a.b'), equals('foo(a_b) = a_b'));
      });

      test('Underscored names are left alone', () {
        const String source = 'num_abs_helper(n) = n';

        expect(rewrite(source), equals(source));
      });

      test('Undotted source is byte-identical', () {
        const String source = 'main() = 1 + 2\n// a comment\n';

        expect(rewrite(source), equals(source));
      });
    });

    group('Non-identifiers', () {
      test('Decimal literal', () {
        const String source = 'main() = 1.5';

        expect(rewrite(source), equals(source));
      });

      test('Decimal literal with exponent', () {
        const String source = 'main() = 1.5e3 + 2.5E-4 + 1_000.5';

        expect(rewrite(source), equals(source));
      });

      test('Double-quoted string', () {
        const String source = 'main() = "num.abs and a.b"';

        expect(rewrite(source), equals(source));
      });

      test('Single-quoted string', () {
        const String source = "main() = 'num.abs'";

        expect(rewrite(source), equals(source));
      });

      test('Escaped quote inside a string', () {
        const String source = r'main() = "a \" num.abs" + 1';

        expect(rewrite(source), equals(source));
      });

      test('Line comment', () {
        const String source = '// i.e. num.abs\nmain() = 1';

        expect(rewrite(source), equals(source));
      });

      test('Block comment', () {
        const String source =
            '/*\n  num.abs, i.e. the absolute value\n*/\n'
            'main() = 1';

        expect(rewrite(source), equals(source));
      });

      test('Shebang line', () {
        const String source = '#!/usr/bin/env primal.sh\nmain() = 1';

        expect(rewrite(source), equals(source));
      });

      test('Identifiers around a decimal literal are still rewritten', () {
        expect(
          rewrite('main() = num.add(1.5, num.abs(-2.5))'),
          equals('main() = num_add(1.5, num_abs(-2.5))'),
        );
      });
    });

    group('Replacement count', () {
      test('Counts every dot rewritten, not every identifier', () {
        final MigrationResult result = migrate(
          'test.factorial.base() = num.abs(-1)',
          libraryNames: library,
        );

        expect(result.replacements, equals(3));
      });

      test('Counts zero when nothing changes', () {
        final MigrationResult result = migrate(
          'main() = 1.5 // num.abs',
          libraryNames: library,
        );

        expect(result.replacements, equals(0));
      });
    });

    group('Collisions', () {
      test('Rewrite would collide with a name the file already uses', () {
        final MigrationResult result = migrate(
          'foo_bar(n) = n\nmain() = foo.bar(-5)',
          libraryNames: library,
        );

        expect(result.isRefused, isTrue);
        expect(result.replacements, equals(0));
        expect(result.source, contains('foo.bar'));
        expect(result.collisions.single, contains('"foo.bar"'));
        expect(result.collisions.single, contains('"foo_bar"'));
      });

      test('A file can trip both collision checks at once', () {
        final MigrationResult result = migrate(
          'num_abs(n) = n\nmain() = num.abs(-5)',
          libraryNames: library,
        );

        expect(result.collisions, hasLength(2));
        expect(
          result.collisions.any((String c) => c.contains('already uses')),
          isTrue,
        );
        expect(
          result.collisions.any(
            (String c) => c.contains('standard library function'),
          ),
          isTrue,
        );
      });

      test(
        'File defines a name the standard library owns after the rename',
        () {
          final MigrationResult result = migrate(
            'num_abs(n) = n\nmain() = num_abs(-5)',
            libraryNames: library,
          );

          expect(result.isRefused, isTrue);
          expect(
            result.collisions.single,
            contains('standard library function'),
          );
        },
      );

      test('Two distinct dotted names collapsing onto one is refused', () {
        // Neither spelling is undotted, so the undotted check cannot see this.
        final MigrationResult result = migrate(
          'a.b_c(n) = n\na_b.c(n) = n\nmain() = a.b_c(1) + a_b.c(2)',
          libraryNames: library,
        );

        expect(result.isRefused, isTrue);
        expect(result.replacements, equals(0));
        expect(result.collisions.single, contains('"a.b_c"'));
        expect(result.collisions.single, contains('"a_b.c"'));
        expect(result.collisions.single, contains('"a_b_c"'));
      });

      test(
        'The same library function spelled both ways is not a collision',
        () {
          // A file part-way through migration: both spellings denote num_abs.
          final MigrationResult result = migrate(
            'main() = num_abs(-1) + num.abs(-2)',
            libraryNames: library,
          );

          expect(result.isRefused, isFalse);
          expect(result.source, equals('main() = num_abs(-1) + num_abs(-2)'));
        },
      );

      test('Repeating one dotted name is not a collapse', () {
        final MigrationResult result = migrate(
          'main() = num.abs(num.abs(-1))',
          libraryNames: library,
        );

        expect(result.isRefused, isFalse);
        expect(result.replacements, equals(2));
      });

      test('Calling a library function is not a collision', () {
        final MigrationResult result = migrate(
          'main() = list.map(foo, [1])',
          libraryNames: library,
        );

        expect(result.isRefused, isFalse);
        expect(result.source, equals('main() = list_map(foo, [1])'));
      });

      test('Collisions are reported in a stable order', () {
        final MigrationResult result = migrate(
          'num_abs(n) = n\nlist_map(f, l) = l\nmain() = num.abs(1)',
          libraryNames: library,
        );

        expect(result.collisions, equals(List.of(result.collisions)..sort()));
      });
    });

    group('Defined names', () {
      test('Definitions are detected and rewritten', () {
        expect(
          definedNames('foo.bar(a, b) = a\nmain() = foo.bar(1, 2)'),
          equals({'foo_bar', 'main'}),
        );
      });

      test('A call is not a definition', () {
        expect(definedNames('main() = num.abs(-5)'), equals({'main'}));
      });

      test('A comparison is not a definition', () {
        expect(definedNames('main() = foo() == 1'), equals({'main'}));
      });

      test('A let binding is not a definition', () {
        expect(definedNames('main() = let x = 1 in x'), equals({'main'}));
      });

      test('Trivia between the name, the parameters and the equals', () {
        expect(
          definedNames('foo.bar /* c */ ( a , b ) // c\n = a'),
          equals({'foo_bar'}),
        );
      });
    });

    group('Standard library table', () {
      test('Contains no dotted name after the rename', () {
        expect(
          standardLibraryNames().where((String name) => name.contains('.')),
          isEmpty,
        );
      });

      test('Underscoring is idempotent', () {
        expect(underscored(underscored('num.abs')), equals('num_abs'));
      });
    });

    group('Unterminated constructs', () {
      test('Unterminated string is refused, not silently skipped', () {
        final MigrationResult result = migrate(
          'main() = "num.abs\nfoo.bar(n) = n',
          libraryNames: library,
        );

        expect(result.isRefused, isTrue);
        expect(result.collisions.single, contains('string literal'));
        expect(result.collisions.single, contains('[1, 10]'));
      });

      test('Unterminated block comment is refused', () {
        final MigrationResult result = migrate(
          'main() = 1 /* num.abs\nfoo.bar(n) = n',
          libraryNames: library,
        );

        expect(result.isRefused, isTrue);
        expect(result.collisions.single, contains('block comment'));
      });

      test('A closed string and comment are not refused', () {
        final MigrationResult result = migrate(
          'main() = "ok" /* ok */ + num.abs(1)',
          libraryNames: library,
        );

        expect(result.isRefused, isFalse);
      });
    });

    group('Line endings', () {
      test('A CR-only shebang does not swallow the file', () {
        expect(
          rewrite('#!/usr/bin/env primal\rmain() = num.abs(1)'),
          equals('#!/usr/bin/env primal\rmain() = num_abs(1)'),
        );
      });

      test('A CR-only line comment ends at the CR', () {
        expect(
          rewrite('// i.e. keep\rmain() = num.abs(1)'),
          equals('// i.e. keep\rmain() = num_abs(1)'),
        );
      });

      test('CRLF is handled', () {
        expect(
          rewrite('// c\r\nmain() = num.abs(1)'),
          equals('// c\r\nmain() = num_abs(1)'),
        );
      });
    });

    // run() owns the write guard, so a regression here rewrites a user's tree.
    group('run()', () {
      late Directory directory;

      setUp(() {
        directory = Directory.systemTemp.createTempSync('migrate_dots_test');
      });

      tearDown(() {
        if (directory.existsSync()) {
          directory.deleteSync(recursive: true);
        }
      });

      File write(String name, String content) {
        final File file = File('${directory.path}/$name')
          ..writeAsStringSync(content);

        return file;
      }

      test('--dry-run writes nothing and returns 0', () {
        const String source = 'main() = num.abs(-5)';
        final File file = write('a.prm', source);

        expect(run(['--dry-run', file.path]), equals(0));
        expect(file.readAsStringSync(), equals(source));
      });

      test('without --dry-run the file is rewritten', () {
        final File file = write('a.prm', 'main() = num.abs(-5)');

        expect(run([file.path]), equals(0));
        expect(file.readAsStringSync(), equals('main() = num_abs(-5)'));
      });

      test('a directory is searched recursively for .prm files', () {
        Directory('${directory.path}/nested').createSync();
        final File nested = write('nested/b.prm', 'main() = num.abs(1)');
        final File other = write('c.txt', 'main() = num.abs(1)');

        expect(run([directory.path]), equals(0));
        expect(nested.readAsStringSync(), equals('main() = num_abs(1)'));
        // Only .prm files are touched.
        expect(other.readAsStringSync(), equals('main() = num.abs(1)'));
      });

      test('a refused file returns 1 and is left untouched', () {
        const String source = 'num_abs(n) = n\nmain() = num.abs(-5)';
        final File file = write('a.prm', source);

        expect(run([file.path]), equals(1));
        expect(file.readAsStringSync(), equals(source));
      });

      test('a missing path returns 2 before touching anything', () {
        final File file = write('a.prm', 'main() = num.abs(1)');

        expect(run([file.path, '${directory.path}/nope.prm']), equals(2));
        expect(file.readAsStringSync(), equals('main() = num.abs(1)'));
      });

      test('an unknown option returns 2 rather than being ignored', () {
        const String source = 'main() = num.abs(-5)';
        final File file = write('a.prm', source);

        // A mistyped --dry-run must not fall through to a real rewrite.
        expect(run(['--dryrun', file.path]), equals(2));
        expect(file.readAsStringSync(), equals(source));
      });

      test('no arguments returns 2', () {
        expect(run([]), equals(2));
      });

      test('--help and -h return 0', () {
        expect(run(['--help']), equals(0));
        expect(run(['-h']), equals(0));
      });
    });
  });
}
