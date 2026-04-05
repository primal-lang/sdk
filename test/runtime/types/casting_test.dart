@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('To', () {
    test('to.number converts string to number', () {
      final RuntimeFacade runtime = getRuntime('main = to.number("12.5")');
      checkResult(runtime, 12.5);
    });

    test('to.number returns number unchanged', () {
      final RuntimeFacade runtime = getRuntime('main = to.number(12.5)');
      checkResult(runtime, 12.5);
    });

    test('to.number throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main = to.number(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to.integer converts string to integer', () {
      final RuntimeFacade runtime = getRuntime('main = to.integer("12")');
      checkResult(runtime, 12);
    });

    test('to.integer returns integer unchanged', () {
      final RuntimeFacade runtime = getRuntime('main = to.integer(12)');
      checkResult(runtime, 12);
    });

    test('to.integer truncates decimal below .5', () {
      final RuntimeFacade runtime = getRuntime('main = to.integer(12.4)');
      checkResult(runtime, 12);
    });

    test('to.integer truncates decimal at .5', () {
      final RuntimeFacade runtime = getRuntime('main = to.integer(12.5)');
      checkResult(runtime, 12);
    });

    test('to.integer truncates decimal above .5', () {
      final RuntimeFacade runtime = getRuntime('main = to.integer(12.6)');
      checkResult(runtime, 12);
    });

    test('to.integer throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main = to.integer(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to.decimal converts string to decimal', () {
      final RuntimeFacade runtime = getRuntime('main = to.decimal("12")');
      checkResult(runtime, 12.0);
    });

    test('to.decimal converts integer to decimal', () {
      final RuntimeFacade runtime = getRuntime('main = to.decimal(12)');
      checkResult(runtime, 12.0);
    });

    test('to.decimal throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main = to.decimal(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to.string returns string unchanged', () {
      final RuntimeFacade runtime = getRuntime('main = to.string("12")');
      checkResult(runtime, '"12"');
    });

    test('to.string converts number to string', () {
      final RuntimeFacade runtime = getRuntime('main = to.string(12)');
      checkResult(runtime, '"12"');
    });

    test('to.string converts boolean to string', () {
      final RuntimeFacade runtime = getRuntime('main = to.string(true)');
      checkResult(runtime, '"true"');
    });

    test('to.boolean returns true for non-empty string', () {
      final RuntimeFacade runtime = getRuntime('main = to.boolean("hello")');
      checkResult(runtime, true);
    });

    test('to.boolean returns false for empty string', () {
      final RuntimeFacade runtime = getRuntime('main = to.boolean("")');
      checkResult(runtime, false);
    });

    test('to.boolean returns false for zero', () {
      final RuntimeFacade runtime = getRuntime('main = to.boolean(0)');
      checkResult(runtime, false);
    });

    test('to.boolean returns true for positive number', () {
      final RuntimeFacade runtime = getRuntime('main = to.boolean(12)');
      checkResult(runtime, true);
    });

    test('to.boolean returns true for negative number', () {
      final RuntimeFacade runtime = getRuntime('main = to.boolean(-1)');
      checkResult(runtime, true);
    });

    test('to.boolean returns true unchanged', () {
      final RuntimeFacade runtime = getRuntime('main = to.boolean(true)');
      checkResult(runtime, true);
    });

    test('to.boolean returns false unchanged', () {
      final RuntimeFacade runtime = getRuntime('main = to.boolean(false)');
      checkResult(runtime, false);
    });

    test('to.list converts set to list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = to.list(set.new([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('to.list converts vector to list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = to.list(vector.new([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('to.list converts stack to list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = to.list(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('to.list converts queue to list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = to.list(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2, 3]);
    });
  });

  // Table of type expressions used across all is.* tests.
  final Map<String, String> typeExpressions = {
    'integer': '42',
    'decimal': '12.5',
    'string': '"Hello"',
    'boolean': 'true',
    'list': '[1, 2, 3]',
    'map': '{"foo": 1}',
    'vector': 'vector.new([1, 2, 3])',
    'set': 'set.new([1, 2, 3])',
    'stack': 'stack.new([1, 2, 3])',
    'queue': 'queue.new([1, 2, 3])',
    'function': 'num.abs',
    'timestamp': 'time.now()',
    'file': 'file.fromPath(".")',
    'directory': 'directory.fromPath(".")',
  };

  // Each entry: function name -> set of type keys that should return true.
  final Map<String, Set<String>> isChecks = {
    'is.number': {'integer', 'decimal'},
    'is.string': {'string'},
    'is.boolean': {'boolean'},
    'is.list': {'list'},
    'is.map': {'map'},
    'is.vector': {'vector'},
    'is.set': {'set'},
    'is.stack': {'stack'},
    'is.queue': {'queue'},
    'is.function': {'function'},
    'is.timestamp': {'timestamp'},
    'is.file': {'file'},
    'is.directory': {'directory'},
  };

  for (final MapEntry<String, Set<String>> entry in isChecks.entries) {
    final String functionName = entry.key;
    final Set<String> trueTypes = entry.value;

    group(functionName, () {
      for (final MapEntry<String, String> typeEntry
          in typeExpressions.entries) {
        final String typeName = typeEntry.key;
        final String expression = typeEntry.value;
        final bool expected = trueTypes.contains(typeName);

        test('returns $expected for $typeName', () {
          final RuntimeFacade runtime = getRuntime(
            'main = $functionName($expression)',
          );
          checkResult(runtime, expected);
        });
      }
    });
  }

  // Special cases not covered by the table above.
  group('Is (special cases)', () {
    test('is.integer returns false for whole decimal', () {
      final RuntimeFacade runtime = getRuntime('main = is.integer(12.0)');
      checkResult(runtime, false);
    });

    test('is.integer returns true for integer', () {
      final RuntimeFacade runtime = getRuntime('main = is.integer(12)');
      checkResult(runtime, true);
    });

    test('is.integer returns false for fractional decimal', () {
      final RuntimeFacade runtime = getRuntime('main = is.integer(12.1)');
      checkResult(runtime, false);
    });

    test('is.decimal returns false for integer', () {
      final RuntimeFacade runtime = getRuntime('main = is.decimal(12)');
      checkResult(runtime, false);
    });

    test('is.decimal returns true for decimal', () {
      final RuntimeFacade runtime = getRuntime('main = is.decimal(12.5)');
      checkResult(runtime, true);
    });

    test('is.infinite returns false for finite number', () {
      final RuntimeFacade runtime = getRuntime('main = is.infinite(12)');
      checkResult(runtime, false);
    });

    test('is.infinite returns true for infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main = is.infinite(num.infinity())',
      );
      checkResult(runtime, true);
    });

    test('is.list returns true for empty list', () {
      final RuntimeFacade runtime = getRuntime('main = is.list([])');
      checkResult(runtime, true);
    });

    test('is.map returns true for empty map', () {
      final RuntimeFacade runtime = getRuntime('main = is.map({})');
      checkResult(runtime, true);
    });

    test('is.stack returns true for empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = is.stack(stack.new([]))',
      );
      checkResult(runtime, true);
    });

    test('is.queue returns true for empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = is.queue(queue.new([]))',
      );
      checkResult(runtime, true);
    });
  });

  group('Casting Edge Cases', () {
    test('to.number throws ParseError for non-numeric string', () {
      final RuntimeFacade runtime = getRuntime('main = to.number("hello")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<ParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('hello'),
              contains('number'),
              contains('to.number'),
            ),
          ),
        ),
      );
    });

    test('to.integer throws ParseError for non-numeric string', () {
      final RuntimeFacade runtime = getRuntime('main = to.integer("hello")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<ParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('hello'),
              contains('integer'),
              contains('to.integer'),
            ),
          ),
        ),
      );
    });

    test('to.integer throws ParseError for decimal string', () {
      final RuntimeFacade runtime = getRuntime('main = to.integer("3.14")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<ParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('3.14'),
              contains('integer'),
            ),
          ),
        ),
      );
    });

    test('to.decimal throws ParseError for non-numeric string', () {
      final RuntimeFacade runtime = getRuntime('main = to.decimal("hello")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<ParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('hello'),
              contains('decimal'),
              contains('to.decimal'),
            ),
          ),
        ),
      );
    });

    test('to.list with number throws', () {
      final RuntimeFacade runtime = getRuntime('main = to.list(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to.boolean with list throws', () {
      final RuntimeFacade runtime = getRuntime('main = to.boolean([])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to.boolean with map throws', () {
      final RuntimeFacade runtime = getRuntime('main = to.boolean({})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to.list with list', () {
      final RuntimeFacade runtime = getRuntime('main = to.list([1, 2, 3])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
