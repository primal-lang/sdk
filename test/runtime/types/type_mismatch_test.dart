@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Type Mismatch Errors', () {
    test('number plus boolean', () {
      final RuntimeFacade runtime = getRuntime('main() = 5 + true');
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
      final RuntimeFacade runtime = getRuntime('main() = "hello" - "world"');
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
      final RuntimeFacade runtime = getRuntime('main() = "hello" * 3');
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
      final RuntimeFacade runtime = getRuntime('main() = num.abs("hello")');
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
      final RuntimeFacade runtime = getRuntime('main() = str.length(42)');
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
      final RuntimeFacade runtime = getRuntime('main() = list.length(42)');
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
      final RuntimeFacade runtime = getRuntime('main() = true > false');
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
      final RuntimeFacade runtime = getRuntime('main() = true - 5');
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
      final RuntimeFacade runtime = getRuntime('main() = "hello" / 2');
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
      final RuntimeFacade runtime = getRuntime('main() = true % 3');
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
      final RuntimeFacade runtime = getRuntime('main() = "hello" + true');
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
      final RuntimeFacade runtime = getRuntime('main() = str.concat(5, 5)');
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
      final RuntimeFacade runtime = getRuntime('main() = str.uppercase(5)');
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
      final RuntimeFacade runtime = getRuntime('main() = str.contains(5, 5)');
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
      final RuntimeFacade runtime = getRuntime('main() = list.first(5)');
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
      final RuntimeFacade runtime = getRuntime('main() = list.reverse(5)');
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
      final RuntimeFacade runtime = getRuntime('main() = list.map(5, num.abs)');
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
      final RuntimeFacade runtime = getRuntime(
        'main() = list.filter("hello", num.abs)',
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
      final RuntimeFacade runtime = getRuntime('main() = map.keys(5)');
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
      final RuntimeFacade runtime = getRuntime('main() = map.values(5)');
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
      final RuntimeFacade runtime = getRuntime('main() = 5 < true');
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
      final RuntimeFacade runtime = getRuntime('main() = 5 <= true');
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
      final RuntimeFacade runtime = getRuntime('main() = 5 >= true');
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
      final RuntimeFacade runtime = getRuntime('main() = 5 & 3');
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
      final RuntimeFacade runtime = getRuntime('main() = !5');
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

  group('Arithmetic Type Mismatches', () {
    test('num.pow with strings', () {
      final RuntimeFacade runtime = getRuntime('main() = num.pow("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.sqrt with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num.sqrt("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.floor with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num.floor("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.ceil with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num.ceil("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.round with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num.round("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.add with strings', () {
      final RuntimeFacade runtime = getRuntime('main() = num.add("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.sub with strings', () {
      final RuntimeFacade runtime = getRuntime('main() = num.sub("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.mul with strings', () {
      final RuntimeFacade runtime = getRuntime('main() = num.mul("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.div with strings', () {
      final RuntimeFacade runtime = getRuntime('main() = num.div("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.mod with strings', () {
      final RuntimeFacade runtime = getRuntime('main() = num.mod("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.sin with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num.sin("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.cos with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num.cos("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.tan with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num.tan("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.log with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num.log("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.negative with string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num.negative("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.sign with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num.sign("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.inc with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num.inc("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.dec with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num.dec("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.fraction with string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num.fraction("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.asDegrees with string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num.asDegrees("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.asRadians with string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num.asRadians("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.isEven with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num.isEven("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.isOdd with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num.isOdd("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.isZero with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num.isZero("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.isNegative with string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num.isNegative("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.isPositive with string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num.isPositive("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.max with strings', () {
      final RuntimeFacade runtime = getRuntime('main() = num.max("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.min with strings', () {
      final RuntimeFacade runtime = getRuntime('main() = num.min("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.sum with strings', () {
      final RuntimeFacade runtime = getRuntime('main() = num.sum("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.compare with strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num.compare("a", "b")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.integerRandom with strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num.integerRandom("a", "b")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.clamp with strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num.clamp("a", "b", "c")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test(
      'num.integerRandom throws InvalidNumericOperationError when max is less than min',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = num.integerRandom(5, 4)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('num.integerRandom'),
                contains('max (4) must be >= min (5)'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'num.clamp throws InvalidNumericOperationError when minimum bound exceeds maximum bound',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = num.clamp(5, 10, 4)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('num.clamp'),
                contains('min bound (10) must be <= max bound (4)'),
              ),
            ),
          ),
        );
      },
    );
  });

  group('Logic Function Type Mismatches', () {
    test('bool.and with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = bool.and(1, 2)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool.and first argument non-boolean', () {
      final RuntimeFacade runtime = getRuntime('main() = bool.and(5, true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool.and second argument non-boolean when first is true', () {
      final RuntimeFacade runtime = getRuntime('main() = bool.and(true, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool.or with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = bool.or(1, 2)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool.or first argument non-boolean', () {
      final RuntimeFacade runtime = getRuntime('main() = bool.or(5, false)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool.or second argument non-boolean when first is false', () {
      final RuntimeFacade runtime = getRuntime('main() = bool.or(false, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool.xor with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = bool.xor(1, 2)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool.not with number', () {
      final RuntimeFacade runtime = getRuntime('main() = bool.not(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool.andStrict with a non-boolean first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.andStrict(1, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool.andStrict with a non-boolean second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.andStrict(true, 1)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool.orStrict with a non-boolean first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.orStrict(1, false)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool.orStrict with a non-boolean second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.orStrict(false, 1)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('String Type Mismatches', () {
    test('str.first with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str.first(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.last with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str.last(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.rest with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str.rest(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.init with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str.init(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.isEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str.isEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.isNotEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str.isNotEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.bytes with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str.bytes(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.at with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = str.at(5, 0)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.compare with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = str.compare(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.drop with booleans', () {
      final RuntimeFacade runtime = getRuntime('main() = str.drop(true, true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.take with booleans', () {
      final RuntimeFacade runtime = getRuntime('main() = str.take(true, true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.startsWith with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = str.startsWith(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.endsWith with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = str.endsWith(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.match with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = str.match(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.padLeft with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padLeft(true, true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.padRight with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.padRight(true, true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.removeAt with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.removeAt(true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.lowercase with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str.lowercase(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.trim with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str.trim(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.reverse with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str.reverse(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.replace with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = str.replace(5, 5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.split with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = str.split(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.substring with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring(true, true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.indexOf with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = str.indexOf(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.match throws ParseError for an invalid regular expression', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.match("hello", "(")',
      );
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });
  });

  group('List Type Mismatches', () {
    test('list.isNotEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = list.isNotEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.rest with number', () {
      final RuntimeFacade runtime = getRuntime('main() = list.rest(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.init with number', () {
      final RuntimeFacade runtime = getRuntime('main() = list.init(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.at with booleans', () {
      final RuntimeFacade runtime = getRuntime('main() = list.at(true, true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.concat with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = list.concat(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.drop with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.drop(true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.filled with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.filled(true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.insertEnd with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = list.insertEnd(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.insertStart with numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.insertStart(5, 5)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.join with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = list.join(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.take with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.take(true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.all with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = list.all(5, num.abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.any with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = list.any(5, num.abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.none with non-list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.none(5, num.abs)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.removeAt with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.removeAt(true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.sublist with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.sublist(true, true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.indexOf with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = list.indexOf(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.set with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.set(true, true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.remove with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = list.remove(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.swap with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.swap(true, true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.zip with non-list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.zip(5, 5, num.abs)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.isEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = list.isEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.last with number', () {
      final RuntimeFacade runtime = getRuntime('main() = list.last(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.contains with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = list.contains(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.reduce with non-list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.reduce(5, 0, num.add)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.sort with non-list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.sort(5, num.compare)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    group('Higher Order Function Type Mismatches', () {
      test('list.map with non-function second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.map([1, 2], 5)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('list.filter with non-function second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.filter([1, 2], 5)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('list.reduce with non-function third argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.reduce([1, 2], 0, 5)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('list.sort with non-function second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.sort([1, 2], 5)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('list.zip with non-function third argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.zip([1, 2], [3, 4], 5)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('list.all with non-function second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.all([1, 2], 5)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('list.any with non-function second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.any([1, 2], 5)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('list.none with non-function second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.none([1, 2], 5)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });
    });
  });

  group('Map Type Mismatches', () {
    test('map.isNotEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = map.isNotEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.removeAt with non-map', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map.removeAt(5, "key")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.set with non-map', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map.set(5, "key", "val")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.isEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = map.isEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.at with non-map', () {
      final RuntimeFacade runtime = getRuntime('main() = map.at(5, "key")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.length with number', () {
      final RuntimeFacade runtime = getRuntime('main() = map.length(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.containsKey with non-map', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map.containsKey(5, "k")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    group('Key Type Mismatches', () {
      test('map.at with a non-hashable key', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = map.at({"a": 1}, num.abs)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('map.removeAt with a non-number key', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = map.removeAt({"a": 1}, num.abs)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('map.set with a non-hashable key', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = map.set({"a": 1}, num.abs, 2)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('map.containsKey with a non-hashable key', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = map.containsKey({"a": 1}, num.abs)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });
    });
  });

  group('Queue Type Mismatches', () {
    test('queue.new with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = queue.new(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.isEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = queue.isEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.isNotEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = queue.isNotEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.reverse with number', () {
      final RuntimeFacade runtime = getRuntime('main() = queue.reverse(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.enqueue with non-queue', () {
      final RuntimeFacade runtime = getRuntime('main() = queue.enqueue(5, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.dequeue with number', () {
      final RuntimeFacade runtime = getRuntime('main() = queue.dequeue(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.peek with number', () {
      final RuntimeFacade runtime = getRuntime('main() = queue.peek(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.length with number', () {
      final RuntimeFacade runtime = getRuntime('main() = queue.length(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Stack Type Mismatches', () {
    test('stack.new with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = stack.new(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = stack.isEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isNotEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = stack.isNotEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.reverse with number', () {
      final RuntimeFacade runtime = getRuntime('main() = stack.reverse(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.push with non-stack', () {
      final RuntimeFacade runtime = getRuntime('main() = stack.push(5, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.pop with number', () {
      final RuntimeFacade runtime = getRuntime('main() = stack.pop(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.peek with number', () {
      final RuntimeFacade runtime = getRuntime('main() = stack.peek(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.length with number', () {
      final RuntimeFacade runtime = getRuntime('main() = stack.length(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Set Type Mismatches', () {
    test('set.new with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = set.new(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.isEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = set.isEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.isNotEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = set.isNotEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.intersection with non-sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set.intersection(5, 5)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.add with non-set', () {
      final RuntimeFacade runtime = getRuntime('main() = set.add(5, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.contains with non-set', () {
      final RuntimeFacade runtime = getRuntime('main() = set.contains(5, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.union with non-sets', () {
      final RuntimeFacade runtime = getRuntime('main() = set.union(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.difference with non-sets', () {
      final RuntimeFacade runtime = getRuntime('main() = set.difference(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.length with number', () {
      final RuntimeFacade runtime = getRuntime('main() = set.length(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.remove with non-set', () {
      final RuntimeFacade runtime = getRuntime('main() = set.remove(5, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Timestamp Type Mismatches', () {
    test('time.day with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time.day(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('timestamp.toEpoch with number', () {
      final RuntimeFacade runtime = getRuntime('main() = timestamp.toEpoch(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.fromIso with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time.fromIso(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.hour with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time.hour(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.minute with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time.minute(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.month with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time.month(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.second with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time.second(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.toIso with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time.toIso(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.year with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time.year(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.millisecond with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time.millisecond(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.compare with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = time.compare(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Vector Type Mismatches', () {
    test('vector.new with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = vector.new(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector.new with non-numeric elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector.new(["hello"])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector.magnitude with non-vector', () {
      final RuntimeFacade runtime = getRuntime('main() = vector.magnitude(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector.normalize with non-vector', () {
      final RuntimeFacade runtime = getRuntime('main() = vector.normalize(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector.add with non-vectors', () {
      final RuntimeFacade runtime = getRuntime('main() = vector.add(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector.sub with non-vectors', () {
      final RuntimeFacade runtime = getRuntime('main() = vector.sub(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector.angle with non-vectors', () {
      final RuntimeFacade runtime = getRuntime('main() = vector.angle(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector.angle with different lengths', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector.angle(vector.new([1, 2]), vector.new([1, 2, 3]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });
  });

  group('Directory Type Mismatches', () {
    test('directory.name with number', () {
      final RuntimeFacade runtime = getRuntime('main() = directory.name(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.path with number', () {
      final RuntimeFacade runtime = getRuntime('main() = directory.path(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.parent with number', () {
      final RuntimeFacade runtime = getRuntime('main() = directory.parent(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.exists with number', () {
      final RuntimeFacade runtime = getRuntime('main() = directory.exists(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.create with number', () {
      final RuntimeFacade runtime = getRuntime('main() = directory.create(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.delete with number', () {
      final RuntimeFacade runtime = getRuntime('main() = directory.delete(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.list with number', () {
      final RuntimeFacade runtime = getRuntime('main() = directory.list(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.fromPath with number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = directory.fromPath(5)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.copy with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = directory.copy(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.move with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = directory.move(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.rename with numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = directory.rename(5, 5)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('File Type Mismatches', () {
    test('file.name with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file.name(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.path with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file.path(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.parent with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file.parent(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.exists with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file.exists(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.create with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file.create(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.delete with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file.delete(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.read with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file.read(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.extension with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file.extension(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.length with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file.length(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.fromPath with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file.fromPath(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.copy with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = file.copy(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.move with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = file.move(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.rename with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = file.rename(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.write with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = file.write(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Environment Type Mismatches', () {
    test('env.get with number', () {
      final RuntimeFacade runtime = getRuntime('main() = env.get(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Control Flow Type Mismatches', () {
    test('if with non-boolean condition', () {
      final RuntimeFacade runtime = getRuntime('main() = if (5) "a" else "b"');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Logic Short-Circuit Type Mismatches', () {
    test('true and non-boolean', () {
      final RuntimeFacade runtime = getRuntime('main() = true & 5');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('false or non-boolean', () {
      final RuntimeFacade runtime = getRuntime('main() = false | 5');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('JSON Type Mismatches', () {
    test('json.decode with number', () {
      final RuntimeFacade runtime = getRuntime('main() = json.decode(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('json.encode with number', () {
      final RuntimeFacade runtime = getRuntime('main() = json.encode(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('json.encode with string', () {
      final RuntimeFacade runtime = getRuntime('main() = json.encode("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('json.encode with boolean', () {
      final RuntimeFacade runtime = getRuntime('main() = json.encode(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Hash Type Mismatches', () {
    test('hash.md5 with number', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.md5(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('hash.sha1 with number', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha1(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('hash.sha256 with number', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha256(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('hash.sha512 with number', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha512(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Operator Sub Set Branches', () {
    test('set minus element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set.new([1, 2, 3]) - 2',
      );
      checkResult(runtime, '{1, 3}');
    });

    test('element minus set throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = 2 - set.new([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
