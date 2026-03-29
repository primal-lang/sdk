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
  });
}
