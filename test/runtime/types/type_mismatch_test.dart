@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Type Mismatch Errors', () {
    test('number plus boolean', () {
      final Runtime runtime = getRuntime('main = 5 + true');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid argument types for function "+"'),
          ),
        ),
      );
    });

    test('string minus string', () {
      final Runtime runtime = getRuntime('main = "hello" - "world"');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid argument types for function "-"'),
          ),
        ),
      );
    });

    test('string times number', () {
      final Runtime runtime = getRuntime('main = "hello" * 3');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Actual: (String, Number)'),
          ),
        ),
      );
    });

    test('num.abs with string', () {
      final Runtime runtime = getRuntime('main = num.abs("hello")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "num.abs"'),
              contains('Expected: (Number)'),
              contains('Actual: (String)'),
            ),
          ),
        ),
      );
    });

    test('str.length with number', () {
      final Runtime runtime = getRuntime('main = str.length(42)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "str.length"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('list.length with number', () {
      final Runtime runtime = getRuntime('main = list.length(42)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "list.length"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('boolean greater than', () {
      final Runtime runtime = getRuntime('main = true > false');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Actual: (Boolean, Boolean)'),
          ),
        ),
      );
    });

    test('boolean minus number', () {
      final Runtime runtime = getRuntime('main = true - 5');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid argument types for function "-"'),
          ),
        ),
      );
    });

    test('string divided by number', () {
      final Runtime runtime = getRuntime('main = "hello" / 2');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid argument types for function "/"'),
          ),
        ),
      );
    });

    test('boolean modulo number', () {
      final Runtime runtime = getRuntime('main = true % 3');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid argument types for function "%"'),
          ),
        ),
      );
    });

    test('string plus boolean', () {
      final Runtime runtime = getRuntime('main = "hello" + true');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid argument types for function "+"'),
          ),
        ),
      );
    });

    test('str.concat with numbers', () {
      final Runtime runtime = getRuntime('main = str.concat(5, 5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "str.concat"'),
              contains('Actual: (Number, Number)'),
            ),
          ),
        ),
      );
    });

    test('str.uppercase with number', () {
      final Runtime runtime = getRuntime('main = str.uppercase(5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "str.uppercase"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('str.contains with numbers', () {
      final Runtime runtime = getRuntime('main = str.contains(5, 5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "str.contains"'),
              contains('Actual: (Number, Number)'),
            ),
          ),
        ),
      );
    });

    test('list.first with number', () {
      final Runtime runtime = getRuntime('main = list.first(5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "list.first"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('list.reverse with number', () {
      final Runtime runtime = getRuntime('main = list.reverse(5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "list.reverse"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('list.map with non-list', () {
      final Runtime runtime = getRuntime('main = list.map(5, num.abs)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('function "list.map"'),
          ),
        ),
      );
    });

    test('list.filter with non-list', () {
      final Runtime runtime = getRuntime(
        'main = list.filter("hello", num.abs)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('function "list.filter"'),
          ),
        ),
      );
    });

    test('map.keys with number', () {
      final Runtime runtime = getRuntime('main = map.keys(5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "map.keys"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('map.values with number', () {
      final Runtime runtime = getRuntime('main = map.values(5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "map.values"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('number less than boolean', () {
      final Runtime runtime = getRuntime('main = 5 < true');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Actual: (Number, Boolean)'),
          ),
        ),
      );
    });

    test('number less equal boolean', () {
      final Runtime runtime = getRuntime('main = 5 <= true');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Actual: (Number, Boolean)'),
          ),
        ),
      );
    });

    test('number greater equal boolean', () {
      final Runtime runtime = getRuntime('main = 5 >= true');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Actual: (Number, Boolean)'),
          ),
        ),
      );
    });

    test('number and number', () {
      final Runtime runtime = getRuntime('main = 5 & 3');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid argument types for function "&"'),
          ),
        ),
      );
    });

    test('not number', () {
      final Runtime runtime = getRuntime('main = !5');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid argument types for function "!"'),
          ),
        ),
      );
    });
  });
}
