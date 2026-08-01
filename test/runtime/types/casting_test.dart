@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('To', () {
    test('to_number converts string to number', () {
      final RuntimeFacade runtime = getRuntime('main() = to_number("12.5")');
      checkResult(runtime, 12.5);
    });

    test('to_number returns number unchanged', () {
      final RuntimeFacade runtime = getRuntime('main() = to_number(12.5)');
      checkResult(runtime, 12.5);
    });

    test('to_number throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = to_number(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to_integer converts string to integer', () {
      final RuntimeFacade runtime = getRuntime('main() = to_integer("12")');
      checkResult(runtime, 12);
    });

    test('to_integer returns integer unchanged', () {
      final RuntimeFacade runtime = getRuntime('main() = to_integer(12)');
      checkResult(runtime, 12);
    });

    test('to_integer truncates decimal below .5', () {
      final RuntimeFacade runtime = getRuntime('main() = to_integer(12.4)');
      checkResult(runtime, 12);
    });

    test('to_integer truncates decimal at .5', () {
      final RuntimeFacade runtime = getRuntime('main() = to_integer(12.5)');
      checkResult(runtime, 12);
    });

    test('to_integer truncates decimal above .5', () {
      final RuntimeFacade runtime = getRuntime('main() = to_integer(12.6)');
      checkResult(runtime, 12);
    });

    test('to_integer throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = to_integer(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to_integer throws ParseError for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = to_integer("")');
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });

    test('to_decimal converts string to decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = to_decimal("12")');
      checkResult(runtime, 12.0);
    });

    test('to_decimal converts integer to decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = to_decimal(12)');
      checkResult(runtime, 12.0);
    });

    test('to_decimal throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = to_decimal(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to_decimal throws ParseError for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = to_decimal("")');
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });

    test('to_string returns string unchanged', () {
      final RuntimeFacade runtime = getRuntime('main() = to_string("12")');
      checkResult(runtime, '"12"');
    });

    test('to_string converts number to string', () {
      final RuntimeFacade runtime = getRuntime('main() = to_string(12)');
      checkResult(runtime, '"12"');
    });

    test('to_string converts boolean to string', () {
      final RuntimeFacade runtime = getRuntime('main() = to_string(true)');
      checkResult(runtime, '"true"');
    });

    test('to_boolean returns true for non-empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = to_boolean("hello")');
      checkResult(runtime, true);
    });

    test('to_boolean returns false for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = to_boolean("")');
      checkResult(runtime, false);
    });

    test('to_boolean returns false for zero', () {
      final RuntimeFacade runtime = getRuntime('main() = to_boolean(0)');
      checkResult(runtime, false);
    });

    test('to_boolean returns true for positive number', () {
      final RuntimeFacade runtime = getRuntime('main() = to_boolean(12)');
      checkResult(runtime, true);
    });

    test('to_boolean returns true for negative number', () {
      final RuntimeFacade runtime = getRuntime('main() = to_boolean(-1)');
      checkResult(runtime, true);
    });

    test('to_boolean returns true unchanged', () {
      final RuntimeFacade runtime = getRuntime('main() = to_boolean(true)');
      checkResult(runtime, true);
    });

    test('to_boolean returns false unchanged', () {
      final RuntimeFacade runtime = getRuntime('main() = to_boolean(false)');
      checkResult(runtime, false);
    });

    test('to_list converts set to list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = to_list(set_new([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('to_list converts vector to list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = to_list(vector_new([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('to_list converts stack to list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = to_list(stack_new([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('to_list converts queue to list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = to_list(queue_new([1, 2, 3]))',
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
    'vector': 'vector_new([1, 2, 3])',
    'set': 'set_new([1, 2, 3])',
    'stack': 'stack_new([1, 2, 3])',
    'queue': 'queue_new([1, 2, 3])',
    'function': 'num_abs',
    'timestamp': 'time_now()',
    'duration': 'duration_fromHours(2)',
    'file': 'file_fromPath(".")',
    'directory': 'directory_fromPath(".")',
  };

  // Each entry: function name -> set of type keys that should return true.
  final Map<String, Set<String>> isChecks = {
    'is_number': {'integer', 'decimal'},
    'is_string': {'string'},
    'is_boolean': {'boolean'},
    'is_list': {'list'},
    'is_map': {'map'},
    'is_vector': {'vector'},
    'is_set': {'set'},
    'is_stack': {'stack'},
    'is_queue': {'queue'},
    'is_function': {'function'},
    'is_timestamp': {'timestamp'},
    'is_duration': {'duration'},
    'is_file': {'file'},
    'is_directory': {'directory'},
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
            'main() = $functionName($expression)',
          );
          checkResult(runtime, expected);
        });
      }
    });
  }

  // Special cases not covered by the table above.
  group('Is (special cases)', () {
    test('is_integer returns false for whole decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = is_integer(12.0)');
      checkResult(runtime, false);
    });

    test('is_integer returns true for integer', () {
      final RuntimeFacade runtime = getRuntime('main() = is_integer(12)');
      checkResult(runtime, true);
    });

    test('is_integer returns false for fractional decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = is_integer(12.1)');
      checkResult(runtime, false);
    });

    test('is_decimal returns false for integer', () {
      final RuntimeFacade runtime = getRuntime('main() = is_decimal(12)');
      checkResult(runtime, false);
    });

    test('is_decimal returns true for decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = is_decimal(12.5)');
      checkResult(runtime, true);
    });

    test('is_infinite returns false for finite number', () {
      final RuntimeFacade runtime = getRuntime('main() = is_infinite(12)');
      checkResult(runtime, false);
    });

    test('is_infinite returns true for infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_infinite(num_infinity())',
      );
      checkResult(runtime, true);
    });

    test('is_list returns true for empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = is_list([])');
      checkResult(runtime, true);
    });

    test('is_vector returns true for empty vector', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_vector(vector_new([]))',
      );
      checkResult(runtime, true);
    });

    test('is_set returns true for empty set', () {
      final RuntimeFacade runtime = getRuntime('main() = is_set(set_new([]))');
      checkResult(runtime, true);
    });

    test('is_map returns true for empty map', () {
      final RuntimeFacade runtime = getRuntime('main() = is_map({})');
      checkResult(runtime, true);
    });

    test('is_stack returns true for empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_stack(stack_new([]))',
      );
      checkResult(runtime, true);
    });

    test('is_queue returns true for empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_queue(queue_new([]))',
      );
      checkResult(runtime, true);
    });
  });

  group('Casting Edge Cases', () {
    test('to_number throws ParseError for non-numeric string', () {
      final RuntimeFacade runtime = getRuntime('main() = to_number("hello")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<ParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('hello'),
              contains('number'),
              contains('to_number'),
            ),
          ),
        ),
      );
    });

    test('to_integer throws ParseError for non-numeric string', () {
      final RuntimeFacade runtime = getRuntime('main() = to_integer("hello")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<ParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('hello'),
              contains('integer'),
              contains('to_integer'),
            ),
          ),
        ),
      );
    });

    test('to_integer throws ParseError for decimal string', () {
      final RuntimeFacade runtime = getRuntime('main() = to_integer("3.14")');
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

    test('to_decimal throws ParseError for non-numeric string', () {
      final RuntimeFacade runtime = getRuntime('main() = to_decimal("hello")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<ParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('hello'),
              contains('decimal'),
              contains('to_decimal'),
            ),
          ),
        ),
      );
    });

    test('to_list with number throws', () {
      final RuntimeFacade runtime = getRuntime('main() = to_list(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to_boolean with list throws', () {
      final RuntimeFacade runtime = getRuntime('main() = to_boolean([])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to_boolean with map throws', () {
      final RuntimeFacade runtime = getRuntime('main() = to_boolean({})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to_list with list', () {
      final RuntimeFacade runtime = getRuntime('main() = to_list([1, 2, 3])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to_list with string throws', () {
      final RuntimeFacade runtime = getRuntime('main() = to_list("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to_list with boolean throws', () {
      final RuntimeFacade runtime = getRuntime('main() = to_list(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to_list with map throws', () {
      final RuntimeFacade runtime = getRuntime('main() = to_list({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to_list converts empty set to empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = to_list(set_new([]))');
      checkResult(runtime, <dynamic>[]);
    });

    test('to_list converts empty vector to empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = to_list(vector_new([]))',
      );
      checkResult(runtime, <dynamic>[]);
    });

    test('to_list converts empty stack to empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = to_list(stack_new([]))',
      );
      checkResult(runtime, <dynamic>[]);
    });

    test('to_list converts empty queue to empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = to_list(queue_new([]))',
      );
      checkResult(runtime, <dynamic>[]);
    });

    test('to_number throws ParseError for empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = to_number("")');
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });

    test('to_integer converts negative integer unchanged', () {
      final RuntimeFacade runtime = getRuntime('main() = to_integer(-5)');
      checkResult(runtime, -5);
    });

    test('to_integer truncates negative decimal toward zero', () {
      final RuntimeFacade runtime = getRuntime('main() = to_integer(-3.7)');
      checkResult(runtime, -3);
    });

    test('to_integer converts negative string to integer', () {
      final RuntimeFacade runtime = getRuntime('main() = to_integer("-42")');
      checkResult(runtime, -42);
    });

    test('to_decimal returns decimal unchanged', () {
      final RuntimeFacade runtime = getRuntime('main() = to_decimal(3.14)');
      checkResult(runtime, 3.14);
    });

    test('to_string converts list to string', () {
      final RuntimeFacade runtime = getRuntime('main() = to_string([1, 2, 3])');
      checkResult(runtime, '"[1, 2, 3]"');
    });

    test('to_string converts map to string', () {
      final RuntimeFacade runtime = getRuntime('main() = to_string({"a": 1})');
      checkResult(runtime, '"{a: 1}"');
    });

    test('to_string converts decimal to string', () {
      final RuntimeFacade runtime = getRuntime('main() = to_string(3.14)');
      checkResult(runtime, '"3.14"');
    });

    test('to_string converts duration to string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = to_string(duration_from(0, 2, 30, 45, 500))',
      );
      checkResult(runtime, '"0d 2h 30m 45s 500ms"');
    });

    test('to_string for zero duration', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = to_string(duration_fromMilliseconds(0))',
      );
      checkResult(runtime, '"0d 0h 00m 00s 000ms"');
    });

    test('to_string for 50 hours duration', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = to_string(duration_fromHours(50))',
      );
      checkResult(runtime, '"2d 2h 00m 00s 000ms"');
    });

    test('to_string for 100 days duration', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = to_string(duration_fromDays(100))',
      );
      checkResult(runtime, '"100d 0h 00m 00s 000ms"');
    });

    test('to_boolean returns false for whitespace-only string', () {
      final RuntimeFacade runtime = getRuntime('main() = to_boolean("   ")');
      checkResult(runtime, false);
    });

    test('to_boolean returns true for string with leading whitespace', () {
      final RuntimeFacade runtime = getRuntime('main() = to_boolean("  a")');
      checkResult(runtime, true);
    });

    test('to_boolean returns true for decimal zero', () {
      final RuntimeFacade runtime = getRuntime('main() = to_boolean(0.0)');
      checkResult(runtime, false);
    });

    test('to_boolean returns true for small decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = to_boolean(0.001)');
      checkResult(runtime, true);
    });
  });

  group('Is (additional type checks)', () {
    test('is_integer returns false for string', () {
      final RuntimeFacade runtime = getRuntime('main() = is_integer("42")');
      checkResult(runtime, false);
    });

    test('is_integer returns false for boolean', () {
      final RuntimeFacade runtime = getRuntime('main() = is_integer(true)');
      checkResult(runtime, false);
    });

    test('is_integer returns false for list', () {
      final RuntimeFacade runtime = getRuntime('main() = is_integer([1, 2])');
      checkResult(runtime, false);
    });

    test('is_integer returns false for negative decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = is_integer(-3.5)');
      checkResult(runtime, false);
    });

    test('is_integer returns true for negative integer', () {
      final RuntimeFacade runtime = getRuntime('main() = is_integer(-42)');
      checkResult(runtime, true);
    });

    test('is_decimal returns true for whole decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = is_decimal(12.0)');
      checkResult(runtime, false);
    });

    test('is_decimal returns false for string', () {
      final RuntimeFacade runtime = getRuntime('main() = is_decimal("3.14")');
      checkResult(runtime, false);
    });

    test('is_decimal returns false for boolean', () {
      final RuntimeFacade runtime = getRuntime('main() = is_decimal(true)');
      checkResult(runtime, false);
    });

    test('is_decimal returns false for list', () {
      final RuntimeFacade runtime = getRuntime('main() = is_decimal([1.5])');
      checkResult(runtime, false);
    });

    test('is_decimal returns true for negative decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = is_decimal(-3.14)');
      checkResult(runtime, true);
    });

    test('is_infinite returns true for negative infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_infinite(num_negative(num_infinity()))',
      );
      checkResult(runtime, true);
    });

    test('is_infinite returns false for string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_infinite("infinity")',
      );
      checkResult(runtime, false);
    });

    test('is_infinite returns false for boolean', () {
      final RuntimeFacade runtime = getRuntime('main() = is_infinite(true)');
      checkResult(runtime, false);
    });

    test('is_infinite returns false for zero', () {
      final RuntimeFacade runtime = getRuntime('main() = is_infinite(0)');
      checkResult(runtime, false);
    });

    test('is_infinite returns false for large number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_infinite(999999999999)',
      );
      checkResult(runtime, false);
    });
  });
}
