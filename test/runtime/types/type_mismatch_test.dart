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

    test('num_abs with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num_abs("hello")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "num_abs"'),
              contains('Expected: (Number)'),
              contains('Actual: (String)'),
            ),
          ),
        ),
      );
    });

    test('str_length with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str_length(42)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "str_length"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('list_length with number', () {
      final RuntimeFacade runtime = getRuntime('main() = list_length(42)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "list_length"'),
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

    test('str_concat with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = str_concat(5, 5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "str_concat"'),
              contains('Actual: (Number, Number)'),
            ),
          ),
        ),
      );
    });

    test('str_uppercase with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str_uppercase(5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "str_uppercase"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('str_contains with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = str_contains(5, 5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "str_contains"'),
              contains('Actual: (Number, Number)'),
            ),
          ),
        ),
      );
    });

    test('list_first with number', () {
      final RuntimeFacade runtime = getRuntime('main() = list_first(5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "list_first"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('list_reverse with number', () {
      final RuntimeFacade runtime = getRuntime('main() = list_reverse(5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "list_reverse"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('list_map with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_map(5, num_abs)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('function "list_map"'),
          ),
        ),
      );
    });

    test('list_filter with non-list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filter("hello", num_abs)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('function "list_filter"'),
          ),
        ),
      );
    });

    test('map_keys with number', () {
      final RuntimeFacade runtime = getRuntime('main() = map_keys(5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "map_keys"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('map_values with number', () {
      final RuntimeFacade runtime = getRuntime('main() = map_values(5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "map_values"'),
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
    test('num_pow with strings', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_sqrt with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sqrt("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_floor with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num_floor("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_ceil with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num_ceil("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_round with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num_round("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_add with strings', () {
      final RuntimeFacade runtime = getRuntime('main() = num_add("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_sub with strings', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sub("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_mul with strings', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mul("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_div with strings', () {
      final RuntimeFacade runtime = getRuntime('main() = num_div("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_mod with strings', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mod("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_sin with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sin("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_cos with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num_cos("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_tan with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num_tan("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_log with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num_log("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_negative with string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_negative("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_sign with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sign("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_inc with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num_inc("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_dec with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num_dec("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_fraction with string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_fraction("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_asDegrees with string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_asDegrees("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_asRadians with string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_asRadians("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_isEven with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isEven("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_isOdd with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isOdd("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_isZero with string', () {
      final RuntimeFacade runtime = getRuntime('main() = num_isZero("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_isNegative with string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_isNegative("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_isPositive with string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_isPositive("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_max with strings', () {
      final RuntimeFacade runtime = getRuntime('main() = num_max("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_min with strings', () {
      final RuntimeFacade runtime = getRuntime('main() = num_min("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_sum with strings', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sum("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_compare with strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_compare("a", "b")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_integerRandom with strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_integerRandom("a", "b")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num_clamp with strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num_clamp("a", "b", "c")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test(
      'num_integerRandom throws InvalidNumericOperationError when max is less than min',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = num_integerRandom(5, 4)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('num_integerRandom'),
                contains('max (4) must be >= min (5)'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'num_clamp throws InvalidNumericOperationError when minimum bound exceeds maximum bound',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = num_clamp(5, 10, 4)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('num_clamp'),
                contains('min bound (10) must be <= max bound (4)'),
              ),
            ),
          ),
        );
      },
    );
  });

  group('Logic Function Type Mismatches', () {
    test('bool_and with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_and(1, 2)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_and first argument non-boolean', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_and(5, true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_and second argument non-boolean when first is true', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_and(true, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_or with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_or(1, 2)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_or first argument non-boolean', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_or(5, false)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_or second argument non-boolean when first is false', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_or(false, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_xor with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_xor(1, 2)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_not with number', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_not(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_andStrict with a non-boolean first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool_andStrict(1, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_andStrict with a non-boolean second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool_andStrict(true, 1)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_orStrict with a non-boolean first argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool_orStrict(1, false)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_orStrict with a non-boolean second argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool_orStrict(false, 1)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('String Type Mismatches', () {
    test('str_first with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str_first(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_last with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str_last(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_rest with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str_rest(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_init with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str_init(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_isEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_isNotEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isNotEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_bytes with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str_bytes(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_at with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = str_at(5, 0)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_compare with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = str_compare(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_drop with booleans', () {
      final RuntimeFacade runtime = getRuntime('main() = str_drop(true, true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_take with booleans', () {
      final RuntimeFacade runtime = getRuntime('main() = str_take(true, true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_startsWith with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = str_startsWith(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_endsWith with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = str_endsWith(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_match with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = str_match(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_padLeft with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padLeft(true, true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_padRight with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padRight(true, true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_removeAt with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_removeAt(true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_lowercase with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str_lowercase(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_trim with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str_trim(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_reverse with number', () {
      final RuntimeFacade runtime = getRuntime('main() = str_reverse(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_replace with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = str_replace(5, 5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_split with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = str_split(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_substring with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring(true, true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_indexOf with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = str_indexOf(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str_match throws ParseError for an invalid regular expression', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_match("hello", "(")',
      );
      expect(runtime.executeMain, throwsA(isA<ParseError>()));
    });
  });

  group('List Type Mismatches', () {
    test('list_isNotEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = list_isNotEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_rest with number', () {
      final RuntimeFacade runtime = getRuntime('main() = list_rest(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_init with number', () {
      final RuntimeFacade runtime = getRuntime('main() = list_init(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_at with booleans', () {
      final RuntimeFacade runtime = getRuntime('main() = list_at(true, true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_concat with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = list_concat(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_drop with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_drop(true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_filled with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filled(true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_insertEnd with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = list_insertEnd(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_insertStart with numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_insertStart(5, 5)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_join with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = list_join(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_take with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_take(true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_all with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_all(5, num_abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_any with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_any(5, num_abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_none with non-list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_none(5, num_abs)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_removeAt with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt(true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_sublist with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist(true, true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_indexOf with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_indexOf(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_set with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set(true, true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_remove with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_remove(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_swap with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap(true, true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_zip with non-list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip(5, 5, num_abs)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_isEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = list_isEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_last with number', () {
      final RuntimeFacade runtime = getRuntime('main() = list_last(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_contains with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_contains(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_reduce with non-list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce(5, 0, num_add)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_sort with non-list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort(5, num_compare)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    group('Higher Order Function Type Mismatches', () {
      test('list_map with non-function second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_map([1, 2], 5)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('list_filter with non-function second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_filter([1, 2], 5)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('list_reduce with non-function third argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_reduce([1, 2], 0, 5)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('list_sort with non-function second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_sort([1, 2], 5)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('list_zip with non-function third argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_zip([1, 2], [3, 4], 5)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('list_all with non-function second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_all([1, 2], 5)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('list_any with non-function second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_any([1, 2], 5)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('list_none with non-function second argument', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_none([1, 2], 5)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });
    });
  });

  group('Map Type Mismatches', () {
    test('map_isNotEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = map_isNotEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map_removeAt with non-map', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map_removeAt(5, "key")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map_set with non-map', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map_set(5, "key", "val")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map_isEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = map_isEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map_at with non-map', () {
      final RuntimeFacade runtime = getRuntime('main() = map_at(5, "key")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map_length with number', () {
      final RuntimeFacade runtime = getRuntime('main() = map_length(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map_containsKey with non-map', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map_containsKey(5, "k")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    group('Key Type Mismatches', () {
      test('map_at with a non-hashable key', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = map_at({"a": 1}, num_abs)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('map_removeAt with a non-number key', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = map_removeAt({"a": 1}, num_abs)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('map_set with a non-hashable key', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = map_set({"a": 1}, num_abs, 2)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('map_containsKey with a non-hashable key', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = map_containsKey({"a": 1}, num_abs)',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });
    });
  });

  group('Queue Type Mismatches', () {
    test('queue_new with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_new(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_isEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_isEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_isNotEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_isNotEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_reverse with number', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_reverse(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_enqueue with non-queue', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_enqueue(5, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_dequeue with number', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_dequeue(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_peek with number', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_peek(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_length with number', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_length(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Stack Type Mismatches', () {
    test('stack_new with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_new(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_isEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_isEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_isNotEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_isNotEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_reverse with number', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_reverse(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_push with non-stack', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_push(5, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_pop with number', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_pop(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_peek with number', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_peek(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_length with number', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_length(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Set Type Mismatches', () {
    test('set_new with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = set_new(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = set_isEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isNotEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main() = set_isNotEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_intersection with non-sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(5, 5)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_add with non-set', () {
      final RuntimeFacade runtime = getRuntime('main() = set_add(5, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_contains with non-set', () {
      final RuntimeFacade runtime = getRuntime('main() = set_contains(5, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_union with non-sets', () {
      final RuntimeFacade runtime = getRuntime('main() = set_union(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_difference with non-sets', () {
      final RuntimeFacade runtime = getRuntime('main() = set_difference(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_length with number', () {
      final RuntimeFacade runtime = getRuntime('main() = set_length(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_remove with non-set', () {
      final RuntimeFacade runtime = getRuntime('main() = set_remove(5, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Timestamp Type Mismatches', () {
    test('time_day with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time_day(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_toEpoch with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time_toEpoch(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_fromIso with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time_fromIso(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_hour with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time_hour(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_minute with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time_minute(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_month with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time_month(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_second with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time_second(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_toIso with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time_toIso(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_year with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time_year(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_millisecond with number', () {
      final RuntimeFacade runtime = getRuntime('main() = time_millisecond(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time_compare with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = time_compare(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Vector Type Mismatches', () {
    test('vector_new with non-list', () {
      final RuntimeFacade runtime = getRuntime('main() = vector_new(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector_new with non-numeric elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_new(["hello"])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector_magnitude with non-vector', () {
      final RuntimeFacade runtime = getRuntime('main() = vector_magnitude(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector_normalize with non-vector', () {
      final RuntimeFacade runtime = getRuntime('main() = vector_normalize(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector_add with non-vectors', () {
      final RuntimeFacade runtime = getRuntime('main() = vector_add(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector_sub with non-vectors', () {
      final RuntimeFacade runtime = getRuntime('main() = vector_sub(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector_angle with non-vectors', () {
      final RuntimeFacade runtime = getRuntime('main() = vector_angle(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector_angle with different lengths', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([1, 2]), vector_new([1, 2, 3]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });
  });

  group('Directory Type Mismatches', () {
    test('directory_name with number', () {
      final RuntimeFacade runtime = getRuntime('main() = directory_name(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory_path with number', () {
      final RuntimeFacade runtime = getRuntime('main() = directory_path(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory_parent with number', () {
      final RuntimeFacade runtime = getRuntime('main() = directory_parent(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory_exists with number', () {
      final RuntimeFacade runtime = getRuntime('main() = directory_exists(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory_create with number', () {
      final RuntimeFacade runtime = getRuntime('main() = directory_create(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory_delete with number', () {
      final RuntimeFacade runtime = getRuntime('main() = directory_delete(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory_list with number', () {
      final RuntimeFacade runtime = getRuntime('main() = directory_list(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory_fromPath with number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = directory_fromPath(5)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory_copy with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = directory_copy(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory_move with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = directory_move(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory_rename with numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = directory_rename(5, 5)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('File Type Mismatches', () {
    test('file_name with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file_name(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file_path with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file_path(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file_parent with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file_parent(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file_exists with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file_exists(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file_create with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file_create(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file_delete with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file_delete(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file_read with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file_read(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file_extension with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file_extension(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file_length with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file_length(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file_fromPath with number', () {
      final RuntimeFacade runtime = getRuntime('main() = file_fromPath(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file_copy with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = file_copy(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file_move with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = file_move(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file_rename with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = file_rename(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file_write with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = file_write(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Environment Type Mismatches', () {
    test('env_get with number', () {
      final RuntimeFacade runtime = getRuntime('main() = env_get(5)');
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
    test('json_decode with number', () {
      final RuntimeFacade runtime = getRuntime('main() = json_decode(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('json_encode with number', () {
      final RuntimeFacade runtime = getRuntime('main() = json_encode(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('json_encode with string', () {
      final RuntimeFacade runtime = getRuntime('main() = json_encode("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('json_encode with boolean', () {
      final RuntimeFacade runtime = getRuntime('main() = json_encode(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Hash Type Mismatches', () {
    test('hash_md5 with number', () {
      final RuntimeFacade runtime = getRuntime('main() = hash_md5(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('hash_sha1 with number', () {
      final RuntimeFacade runtime = getRuntime('main() = hash_sha1(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('hash_sha256 with number', () {
      final RuntimeFacade runtime = getRuntime('main() = hash_sha256(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('hash_sha512 with number', () {
      final RuntimeFacade runtime = getRuntime('main() = hash_sha512(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Operator Sub Set Branches', () {
    test('set minus element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2, 3]) - 2',
      );
      checkResult(runtime, '{1, 3}');
    });

    test('element minus set throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = 2 - set_new([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
