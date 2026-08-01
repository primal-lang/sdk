@Tags(['runtime'])
library;

import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/library/error/throw.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Division and Modulo Edge Cases', () {
    test('division by zero throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime('main() = 1 / 0');
      expect(
        runtime.executeMain,
        throwsA(
          isA<DivisionByZeroError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('Division by zero'), contains('/')),
          ),
        ),
      );
    });

    test('negative division by zero throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime('main() = -1 / 0');
      expect(
        runtime.executeMain,
        throwsA(
          isA<DivisionByZeroError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('Division by zero'), contains('/')),
          ),
        ),
      );
    });

    test('modulo by zero throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime('main() = 1 % 0');
      expect(
        runtime.executeMain,
        throwsA(
          isA<DivisionByZeroError>().having(
            (e) => e.toString(),
            'message',
            contains('Division by zero'),
          ),
        ),
      );
    });

    test('zero divided by zero throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime('main() = 0 / 0');
      expect(
        runtime.executeMain,
        throwsA(
          isA<DivisionByZeroError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('Division by zero'), contains('/')),
          ),
        ),
      );
    });
  });

  group('Empty Collection Errors', () {
    test('stack_pop on empty stack has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_pop(stack_new([]))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<RuntimeError>().having(
            (e) => e.toString(),
            'message',
            contains('Cannot get element from empty stack'),
          ),
        ),
      );
    });

    test('stack_peek on empty stack has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new([]))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<RuntimeError>().having(
            (e) => e.toString(),
            'message',
            contains('Cannot get element from empty stack'),
          ),
        ),
      );
    });

    test('queue_dequeue on empty queue has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_dequeue(queue_new([]))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<RuntimeError>().having(
            (e) => e.toString(),
            'message',
            contains('Cannot get element from empty queue'),
          ),
        ),
      );
    });

    test('queue_peek on empty queue has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new([]))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<RuntimeError>().having(
            (e) => e.toString(),
            'message',
            contains('Cannot get element from empty queue'),
          ),
        ),
      );
    });
  });

  group('Map Access Errors', () {
    test('map_at with non-existent key has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map_at({"a": 1, "b": 2}, "c")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidMapIndexError>().having(
            (e) => e.toString(),
            'message',
            contains('"c"'),
          ),
        ),
      );
    });
  });

  group('Vector Length Mismatch', () {
    test('vector_add with different lengths has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add(vector_new([1]), vector_new([1, 2, 3]))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<IterablesWithDifferentLengthError>().having(
            (e) => e.toString(),
            'message',
            contains('different length'),
          ),
        ),
      );
    });

    test('vector_sub with different lengths has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_sub(vector_new([1, 2, 3, 4]), vector_new([1]))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<IterablesWithDifferentLengthError>().having(
            (e) => e.toString(),
            'message',
            contains('different length'),
          ),
        ),
      );
    });
  });

  group('Type Conversion Errors', () {
    test('to_number throws ParseError for invalid input', () {
      final RuntimeFacade runtime = getRuntime('main() = to_number("abc")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<ParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('abc'),
              contains('number'),
            ),
          ),
        ),
      );
    });

    test('to_integer throws ParseError for invalid input', () {
      final RuntimeFacade runtime = getRuntime('main() = to_integer("abc")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<ParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('abc'),
              contains('integer'),
            ),
          ),
        ),
      );
    });

    test('to_decimal throws ParseError for invalid input', () {
      final RuntimeFacade runtime = getRuntime('main() = to_decimal("abc")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<ParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('abc'),
              contains('decimal'),
            ),
          ),
        ),
      );
    });
  });

  group('Custom Errors', () {
    test('error_throw raises CustomError with message', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = error_throw(42, "test error")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('test error'),
          ),
        ),
      );
    });

    test('try catches error and returns fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(error_throw(0, "oops"), "recovered")',
      );
      checkResult(runtime, '"recovered"');
    });

    test('try catches type error and returns fallback', () {
      final RuntimeFacade runtime = getRuntime('main() = try(1 + true, -1)');
      checkResult(runtime, -1);
    });

    test('error_throw evaluates message expression', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = error_throw(1, str_concat("hello", " world"))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('hello world'),
          ),
        ),
      );
    });

    test(
      'error_throw with non-string message throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime('main() = error_throw(1, 42)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(contains('error_throw'), contains('Number')),
            ),
          ),
        );
      },
    );
  });

  group('Invalid Argument Count', () {
    test('too few arguments throws InvalidArgumentCountError', () {
      final RuntimeFacade runtime = getRuntime(
        'apply(f, x) = f(x)\nadd(a, b) = a + b\nmain() = apply(add, 1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentCountError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('Expected: 2'),
              contains('Actual: 1'),
            ),
          ),
        ),
      );
    });

    test('too many arguments throws InvalidArgumentCountError', () {
      final RuntimeFacade runtime = getRuntime(
        'apply(f, x, y, z) = f(x, y, z)\nadd(a, b) = a + b\nmain() = apply(add, 1, 2, 3)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentCountError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('Expected: 2'),
              contains('Actual: 3'),
            ),
          ),
        ),
      );
    });
  });

  group('Runtime Format Errors', () {
    test('format with unsupported type throws InvalidValueError', () {
      final RuntimeFacade runtime = getRuntime('main() = 1');
      expect(
        () => runtime.format(Object()),
        throwsA(isA<InvalidValueError>()),
      );
    });
  });

  group('Cross-Type Comparison Errors', () {
    test('list equals string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = [1, 2] == "hello"');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('map equals list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = {"a": 1} == [1]');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Dynamic Callability Errors', () {
    test(
      'calling function result that is not callable throws InvalidFunctionError',
      () {
        final RuntimeFacade runtime = getRuntime('''
getVal(x) = x
main() = getVal(5)(1)
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidFunctionError>()),
        );
      },
    );

    test(
      'indexing non-indexable variable throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime('''
getVal(x) = x
main() = getVal(true)[0]
''');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );
  });

  group('Runtime.reduce() Semantic Validation', () {
    const Compiler compiler = Compiler();

    test('undefined function throws UndefinedFunctionError', () {
      final RuntimeFacade runtime = getRuntime('main() = 1');
      expect(
        () => runtime.evaluate(compiler.expression('foo()')),
        throwsA(
          isA<UndefinedFunctionError>().having(
            (e) => e.toString(),
            'message',
            contains('foo'),
          ),
        ),
      );
    });

    test('wrong arity throws InvalidNumberOfArgumentsError', () {
      final RuntimeFacade runtime = getRuntime('main() = 1');
      expect(
        () => runtime.evaluate(compiler.expression('num_add(1)')),
        throwsA(
          isA<InvalidNumberOfArgumentsError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('num_add'),
              contains('expected 2'),
              contains('got 1'),
            ),
          ),
        ),
      );
    });

    test('non-callable literal throws NotCallableError', () {
      final RuntimeFacade runtime = getRuntime('main() = 1');
      expect(
        () => runtime.evaluate(compiler.expression('5(1)')),
        throwsA(
          isA<NotCallableError>().having(
            (e) => e.toString(),
            'message',
            contains('number'),
          ),
        ),
      );
    });

    test('non-indexable literal throws NotIndexableError', () {
      final RuntimeFacade runtime = getRuntime('main() = 1');
      expect(
        () => runtime.evaluate(compiler.expression('5[0]')),
        throwsA(
          isA<NotIndexableError>().having(
            (e) => e.toString(),
            'message',
            contains('number'),
          ),
        ),
      );
    });
  });

  group('Empty Collection Errors (list/string)', () {
    test('list_first on empty list throws EmptyCollectionError', () {
      final RuntimeFacade runtime = getRuntime('main() = list_first([])');
      expect(
        runtime.executeMain,
        throwsA(
          isA<EmptyCollectionError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('empty'), contains('list')),
          ),
        ),
      );
    });

    test('list_last on empty list throws EmptyCollectionError', () {
      final RuntimeFacade runtime = getRuntime('main() = list_last([])');
      expect(
        runtime.executeMain,
        throwsA(
          isA<EmptyCollectionError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('empty'), contains('list')),
          ),
        ),
      );
    });

    test('str_first on empty string throws EmptyCollectionError', () {
      final RuntimeFacade runtime = getRuntime('main() = str_first("")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<EmptyCollectionError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('empty'), contains('string')),
          ),
        ),
      );
    });

    test('str_last on empty string throws EmptyCollectionError', () {
      final RuntimeFacade runtime = getRuntime('main() = str_last("")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<EmptyCollectionError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('empty'), contains('string')),
          ),
        ),
      );
    });
  });

  group('Index Out of Bounds Errors', () {
    test('list_at with index out of bounds throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_at([1, 2, 3], 5)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('5'), contains('out of bounds')),
          ),
        ),
      );
    });

    test('list indexing with out of bounds throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime('main() = [1, 2][10]');
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('str_at with index out of bounds throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime('main() = str_at("abc", 5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('5'), contains('out of bounds')),
          ),
        ),
      );
    });

    test('string indexing with out of bounds throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime('main() = "abc"[10]');
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('list_sublist with end > length throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3], 0, 10)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('str_substring with end > length throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("abc", 0, 10)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('list_set with index out of bounds throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2, 3], 10, 99)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test(
      'list_removeAt with index out of bounds throws IndexOutOfBoundsError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_removeAt([1, 2, 3], 10)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<IndexOutOfBoundsError>()),
        );
      },
    );

    test('list_swap with index out of bounds throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2, 3], 0, 10)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test(
      'str_removeAt with index out of bounds throws IndexOutOfBoundsError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_removeAt("abc", 10)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<IndexOutOfBoundsError>()),
        );
      },
    );
  });

  group('Negative Index Errors', () {
    test('list_at with negative index throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_at([1, 2, 3], -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('-1'), contains('Negative')),
          ),
        ),
      );
    });

    test('list indexing with negative index throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime('main() = [1, 2, 3][-1]');
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('str_at with negative index throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime('main() = str_at("abc", -1)');
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('string indexing with negative index throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime('main() = "abc"[-1]');
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('list_sublist with negative start throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3], -1, 2)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('str_substring with negative start throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("abc", -1, 2)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('list_take with negative count throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_take([1, 2, 3], -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('list_drop with negative count throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_drop([1, 2, 3], -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('str_take with negative count throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime('main() = str_take("abc", -1)');
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('str_drop with negative count throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime('main() = str_drop("abc", -1)');
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('list_set with negative index throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2, 3], -1, 99)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('list_removeAt with negative index throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt([1, 2, 3], -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('list_swap with negative first index throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2, 3], -1, 1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('list_swap with negative second index throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2, 3], 0, -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('str_removeAt with negative index throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_removeAt("abc", -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('list_filled with negative count throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime('main() = list_filled(-1, 0)');
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });
  });

  group('Recursion Limit Errors', () {
    test('infinite recursion throws RecursionLimitError', () {
      final RuntimeFacade runtime = getRuntime(
        'loop(x) = loop(x)\nmain() = loop(1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<RecursionLimitError>().having(
            (e) => e.toString(),
            'message',
            contains('recursion'),
          ),
        ),
      );
    });

    test('mutual recursion exceeding limit throws RecursionLimitError', () {
      final RuntimeFacade runtime = getRuntime(
        'ping(x) = pong(x)\npong(x) = ping(x)\nmain() = ping(1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<RecursionLimitError>()),
      );
    });
  });

  group('Invalid Numeric Operation Errors', () {
    test('num_log with zero throws InvalidNumericOperationError', () {
      final RuntimeFacade runtime = getRuntime('main() = num_log(0)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidNumericOperationError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('logarithm'), contains('non-positive')),
          ),
        ),
      );
    });

    test('num_log with negative throws InvalidNumericOperationError', () {
      final RuntimeFacade runtime = getRuntime('main() = num_log(-5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidNumericOperationError>().having(
            (e) => e.toString(),
            'message',
            contains('non-positive'),
          ),
        ),
      );
    });

    test('num_sqrt with negative throws InvalidNumericOperationError', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sqrt(-4)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidNumericOperationError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('square root'), contains('negative')),
          ),
        ),
      );
    });

    test(
      'num_pow with negative base and fractional exponent throws InvalidNumericOperationError',
      () {
        final RuntimeFacade runtime = getRuntime('main() = num_pow(-2, 0.5)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (e) => e.toString(),
              'message',
              allOf(contains('negative'), contains('fractional')),
            ),
          ),
        );
      },
    );

    test(
      'num_integerRandom with max < min throws InvalidNumericOperationError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = num_integerRandom(10, 5)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidNumericOperationError>().having(
              (e) => e.toString(),
              'message',
              contains('must be >='),
            ),
          ),
        );
      },
    );
  });

  group('JSON Parse Errors', () {
    test('json_decode with invalid JSON throws JsonParseError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = json_decode("{invalid}")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<JsonParseError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid JSON'),
          ),
        ),
      );
    });

    test('json_decode with null value throws RuntimeError', () {
      final RuntimeFacade runtime = getRuntime('main() = json_decode("null")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<RuntimeError>().having(
            (e) => e.toString(),
            'message',
            contains('null'),
          ),
        ),
      );
    });
  });

  group('Element Not Found Errors', () {
    test('map indexing with non-existent key throws ElementNotFoundError', () {
      final RuntimeFacade runtime = getRuntime('main() = {"a": 1}["missing"]');
      expect(
        runtime.executeMain,
        throwsA(
          isA<ElementNotFoundError>().having(
            (e) => e.toString(),
            'message',
            contains('missing'),
          ),
        ),
      );
    });

    test(
      'map indexing with non-existent numeric key throws ElementNotFoundError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = {1: "one", 2: "two"}[3]',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<ElementNotFoundError>().having(
              (e) => e.toString(),
              'message',
              contains('3'),
            ),
          ),
        );
      },
    );
  });

  group('Vector Operation Errors', () {
    test('vector_normalize with zero vector throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_normalize(vector_new([0, 0, 0]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<DivisionByZeroError>()),
      );
    });

    test('vector_angle with empty vectors throws RuntimeError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([]), vector_new([]))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<RuntimeError>().having(
            (e) => e.toString(),
            'message',
            contains('empty vectors'),
          ),
        ),
      );
    });

    test('vector_angle with zero vectors throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_angle(vector_new([0, 0]), vector_new([1, 1]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<DivisionByZeroError>()),
      );
    });

    test(
      'vector_angle with different lengths throws IterablesWithDifferentLengthError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = vector_angle(vector_new([1, 2]), vector_new([1, 2, 3]))',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<IterablesWithDifferentLengthError>()),
        );
      },
    );
  });

  group('Parse Errors for Other Functions', () {
    test('time_fromIso with invalid format throws ParseError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = time_fromIso("not-a-date")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<ParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('not-a-date'), contains('timestamp')),
          ),
        ),
      );
    });

    test('str_match with invalid regex throws ParseError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_match("test", "[invalid")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<ParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('[invalid'), contains('regex')),
          ),
        ),
      );
    });
  });

  group('Try Catches Various Runtime Errors', () {
    test('try catches division by zero and returns fallback', () {
      final RuntimeFacade runtime = getRuntime('main() = try(1 / 0, 999)');
      checkResult(runtime, 999);
    });

    test('try catches index out of bounds and returns fallback', () {
      final RuntimeFacade runtime = getRuntime('main() = try([1, 2][10], -1)');
      checkResult(runtime, -1);
    });

    test('try catches parse error and returns fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(to_integer("abc"), 0)',
      );
      checkResult(runtime, 0);
    });

    test('try catches empty collection error and returns fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(list_first([]), 0)',
      );
      checkResult(runtime, 0);
    });

    test('try catches recursion limit and returns fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'loop(x) = loop(x)\nmain() = try(loop(1), "caught")',
      );
      checkResult(runtime, '"caught"');
    });

    test('try catches invalid argument types and returns fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(vector_magnitude([1, 2, 3]), 0)',
      );
      checkResult(runtime, 0);
    });

    test('try catches map key not found and returns fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(map_at({"a": 1}, "b"), "default")',
      );
      checkResult(runtime, '"default"');
    });

    test('try catches negative index and returns fallback', () {
      final RuntimeFacade runtime = getRuntime('main() = try([1, 2][-1], 0)');
      checkResult(runtime, 0);
    });

    test('try catches json parse error and returns fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(json_decode("{broken}"), {})',
      );
      checkResult(runtime, '{}');
    });
  });

  group('Higher-Order Function Return Type Errors', () {
    test(
      'list_filter with non-boolean predicate throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'identity(x) = x\nmain() = list_filter([1, 2, 3], identity)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (RuntimeError error) => error.toString(),
              'message',
              allOf(contains('list_filter'), contains('Boolean')),
            ),
          ),
        );
      },
    );

    test(
      'list_all with non-boolean predicate throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'identity(x) = x\nmain() = list_all([1, 2, 3], identity)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (RuntimeError error) => error.toString(),
              'message',
              allOf(contains('list_all'), contains('Boolean')),
            ),
          ),
        );
      },
    );

    test(
      'list_any with non-boolean predicate throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'identity(x) = x\nmain() = list_any([1, 2, 3], identity)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (RuntimeError error) => error.toString(),
              'message',
              allOf(contains('list_any'), contains('Boolean')),
            ),
          ),
        );
      },
    );

    test(
      'list_none with non-boolean predicate throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'identity(x) = x\nmain() = list_none([1, 2, 3], identity)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (RuntimeError error) => error.toString(),
              'message',
              allOf(contains('list_none'), contains('Boolean')),
            ),
          ),
        );
      },
    );

    test(
      'list_sort with non-number comparator throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'compare(a, b) = "string"\nmain() = list_sort([3, 1, 2], compare)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (RuntimeError error) => error.toString(),
              'message',
              allOf(contains('list_sort'), contains('Number')),
            ),
          ),
        );
      },
    );

    test('list_filter with non-function throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filter([1, 2], 42)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('list_filter'),
          ),
        ),
      );
    });

    test('list_map with non-function throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([1, 2], "string")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('list_map'),
          ),
        ),
      );
    });

    test('list_reduce with non-function throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce([1, 2], 0, 42)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('list_reduce'),
          ),
        ),
      );
    });

    test('list_zip with non-function throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([1], [2], 42)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('list_zip'),
          ),
        ),
      );
    });
  });

  group('Division Function Call Errors', () {
    test('num_div by zero throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime('main() = num_div(10, 0)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<DivisionByZeroError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('num_div'),
          ),
        ),
      );
    });

    test('num_mod by zero throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mod(10, 0)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<DivisionByZeroError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('num_mod'),
          ),
        ),
      );
    });

    test('num_div with non-number throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = num_div(10, "two")');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('num_mod with non-number throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mod(10, true)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Type Conversion Edge Cases', () {
    test('to_boolean with list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = to_boolean([1, 2, 3])',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('to_boolean'),
          ),
        ),
      );
    });

    test('to_boolean with map throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = to_boolean({"a": 1})');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('to_list with string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = to_list("abc")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('to_list'),
          ),
        ),
      );
    });

    test('to_list with number throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = to_list(42)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('to_number with empty string throws ParseError', () {
      final RuntimeFacade runtime = getRuntime('main() = to_number("")');
      expect(
        runtime.executeMain,
        throwsA(isA<ParseError>()),
      );
    });

    test('to_integer with decimal string throws ParseError', () {
      final RuntimeFacade runtime = getRuntime('main() = to_integer("3.14")');
      expect(
        runtime.executeMain,
        throwsA(isA<ParseError>()),
      );
    });

    test('to_decimal with special characters throws ParseError', () {
      final RuntimeFacade runtime = getRuntime('main() = to_decimal("\$100")');
      expect(
        runtime.executeMain,
        throwsA(isA<ParseError>()),
      );
    });
  });

  group('Vector Type Errors', () {
    test(
      'vector_new with non-numeric list throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = vector_new(["a", "b", "c"])',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (RuntimeError error) => error.toString(),
              'message',
              contains('vector_new'),
            ),
          ),
        );
      },
    );

    test('vector_magnitude with list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude([1, 2])',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('vector_magnitude'),
          ),
        ),
      );
    });

    test('vector_add with list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_add([1, 2], vector_new([3, 4]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test(
      'vector_sub with different lengths throws IterablesWithDifferentLengthError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = vector_sub(vector_new([1, 2, 3]), vector_new([1, 2]))',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<IterablesWithDifferentLengthError>()),
        );
      },
    );

    test(
      'vector_normalize with empty vector returns empty vector without error',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_length(to_list(vector_normalize(vector_new([]))))',
        );
        checkResult(runtime, 0);
      },
    );
  });

  group('Sublist and Substring Range Errors', () {
    test('list_sublist with start > end throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3], 2, 1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('str_substring with start > end throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("abc", 2, 1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('list_sublist with negative end throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3], 0, -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('str_substring with negative end throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("abc", 0, -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });
  });

  group('String Operation Type Errors', () {
    test('str_concat with number throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_concat("hello", 42)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('str_concat'),
          ),
        ),
      );
    });

    test(
      'str_split with non-string delimiter throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str_split("a,b,c", 1)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test('str_replace with non-string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_replace("hello", "l", 1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('str_padLeft with non-string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padLeft(123, 5, " ")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('str_padRight with non-string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_padRight(123, 5, " ")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Map Operation Errors', () {
    test('map_set with non-map throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map_set([1, 2], "key", "value")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('map_set'),
          ),
        ),
      );
    });

    test('map_removeAt with non-map throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map_removeAt([1, 2], "key")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('map_keys with non-map throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = map_keys([1, 2, 3])');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('map_values with non-map throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = map_values("string")');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('map_containsKey with non-map throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map_containsKey(42, "key")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Set Operation Errors', () {
    test('set_add with non-set throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = set_add([1, 2], 3)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('set_add'),
          ),
        ),
      );
    });

    test('set_remove with non-set throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove([1, 2], 1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('set_union with non-sets throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union([1, 2], set_new([3, 4]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('set_intersection with non-sets throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([1, 2]), [3, 4])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('set_difference with non-sets throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([1, 2]), "abc")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Stack and Queue Type Errors', () {
    test('stack_push with non-stack throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push([1, 2], 3)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('stack_push'),
          ),
        ),
      );
    });

    test('stack_pop with non-stack throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_pop([1, 2])');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('stack_peek with non-stack throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_peek("string")');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('queue_enqueue with non-queue throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue([1, 2], 3)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('queue_enqueue'),
          ),
        ),
      );
    });

    test('queue_dequeue with non-queue throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_dequeue([1, 2])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('queue_peek with non-queue throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_peek(42)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('List Operation Type Errors', () {
    test('list_at with non-list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = list_at("abc", 0)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('list_at'),
          ),
        ),
      );
    });

    test('list_at with non-number index throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_at([1, 2], "zero")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('list_insertStart with non-list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_insertStart("abc", 1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('list_insertEnd with non-list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_insertEnd(42, 1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('list_concat with non-lists throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_concat([1, 2], "abc")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('list_join with non-list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_join("abc", ",")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('list_reverse with non-list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = list_reverse("abc")');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Arithmetic Operation Type Errors', () {
    test('num_add with non-numbers throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = num_add(1, "two")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('num_add'),
          ),
        ),
      );
    });

    test('num_sub with non-numbers throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sub("one", 2)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('num_mul with non-numbers throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = num_mul(true, 2)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('num_pow with non-numbers throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = num_pow(2, [3])');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('num_sqrt with non-number throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = num_sqrt("four")');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('num_log with non-number throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = num_log([10])');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('num_abs with non-number throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = num_abs("negative")');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Comparison and Logic Type Errors', () {
    test(
      'comparison with incompatible types throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime('main() = 1 < "two"');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'greater than with incompatible types throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime('main() = [1] > 2');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'less or equal with incompatible types throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime('main() = {"a": 1} <= 1');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'greater or equal with incompatible types throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime('main() = true >= 1');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test('not operator with non-boolean throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = !42');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('JSON Encoding Errors', () {
    test('json_encode with function throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'identity(x) = x\nmain() = json_encode(identity)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('json_encode'),
          ),
        ),
      );
    });
  });

  group('Timestamp Operation Errors', () {
    test('time_fromIso with empty string throws ParseError', () {
      final RuntimeFacade runtime = getRuntime('main() = time_fromIso("")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<ParseError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('timestamp'),
          ),
        ),
      );
    });

    test('time_fromIso with non-string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = time_fromIso(12345)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Edge Cases for Empty Collections', () {
    test('list_rest on empty list returns empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_rest([])');
      checkResult(runtime, '[]');
    });

    test('list_init on empty list returns empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_init([])');
      checkResult(runtime, '[]');
    });

    test('str_rest on empty string returns empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_rest("")');
      checkResult(runtime, '""');
    });

    test('str_init on empty string returns empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_init("")');
      checkResult(runtime, '""');
    });

    test('list_reduce on empty list returns initial value', () {
      final RuntimeFacade runtime = getRuntime(
        'add(a, b) = a + b\nmain() = list_reduce([], 0, add)',
      );
      checkResult(runtime, 0);
    });

    test('list_filter on empty list returns empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'isPositive(x) = x > 0\nmain() = list_filter([], isPositive)',
      );
      checkResult(runtime, '[]');
    });

    test('list_map on empty list returns empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'double(x) = x * 2\nmain() = list_map([], double)',
      );
      checkResult(runtime, '[]');
    });

    test('list_all on empty list returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'isPositive(x) = x > 0\nmain() = list_all([], isPositive)',
      );
      checkResult(runtime, true);
    });

    test('list_any on empty list returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'isPositive(x) = x > 0\nmain() = list_any([], isPositive)',
      );
      checkResult(runtime, false);
    });

    test('list_none on empty list returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'isPositive(x) = x > 0\nmain() = list_none([], isPositive)',
      );
      checkResult(runtime, true);
    });
  });

  group('Boundary Value Tests', () {
    test('list_at with index 0 on single element list succeeds', () {
      final RuntimeFacade runtime = getRuntime('main() = list_at([42], 0)');
      checkResult(runtime, 42);
    });

    test('list_at with index at last position succeeds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_at([1, 2, 3], 2)',
      );
      checkResult(runtime, 3);
    });

    test('list_sublist with start equals end returns empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3], 1, 1)',
      );
      checkResult(runtime, '[]');
    });

    test('str_substring with start equals end returns empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("abc", 1, 1)',
      );
      checkResult(runtime, '""');
    });

    test('list_take with count 0 returns empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_take([1, 2, 3], 0)',
      );
      checkResult(runtime, '[]');
    });

    test('list_drop with count 0 returns original list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_drop([1, 2, 3], 0)',
      );
      checkResult(runtime, '[1, 2, 3]');
    });

    test('str_take with count 0 returns empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_take("abc", 0)');
      checkResult(runtime, '""');
    });

    test('str_drop with count 0 returns original string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_drop("abc", 0)');
      checkResult(runtime, '"abc"');
    });

    test('list_filled with count 0 returns empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_filled(0, 42)');
      checkResult(runtime, '[]');
    });

    test('vector with single element operations work correctly', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = vector_magnitude(vector_new([5]))',
      );
      checkResult(runtime, 5.0);
    });
  });

  group('Operator Type Errors', () {
    test('addition of map and number throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = {"a": 1} + 2');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test(
      'subtraction with incompatible types throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime('main() = "abc" - 1');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'multiplication with incompatible types throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime('main() = true * 2');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'division with incompatible types throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime('main() = "abc" / 2');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test('modulo with incompatible types throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = [1, 2] % 3');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Hash Function Errors', () {
    test('hash_md5 with non-string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = hash_md5(12345)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('hash_sha256 with non-string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash_sha256([1, 2, 3])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('hash_sha512 with non-string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = hash_sha512(true)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Control Flow Errors', () {
    test('if with non-boolean condition throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (1) "yes" else "no"',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('if'),
          ),
        ),
      );
    });

    test('if with string condition throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = if ("true") 1 else 0');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('if with list condition throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if ([1, 2]) "yes" else "no"',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('if with map condition throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if ({"a": 1}) "yes" else "no"',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Variable Scope Errors', () {
    test('accessing undefined variable in expression throws error', () {
      const Compiler compiler = Compiler();
      final RuntimeFacade runtime = getRuntime('main() = 1');
      expect(
        () => runtime.evaluate(compiler.expression('undefinedVar')),
        throwsA(isA<UndefinedIdentifierError>()),
      );
    });
  });

  group('CustomError Properties', () {
    test('CustomError preserves numeric code value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = error_throw(42, "error message")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>()
              .having(
                (CustomError error) => error.toString(),
                'message',
                contains('error message'),
              )
              .having(
                (CustomError error) => error.code.native(),
                'code',
                equals(42),
              ),
        ),
      );
    });

    test('CustomError preserves string code value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = error_throw("ERROR_CODE", "details")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (CustomError error) => error.code.native(),
            'code',
            equals('ERROR_CODE'),
          ),
        ),
      );
    });

    test('CustomError preserves boolean code value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = error_throw(false, "failure")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (CustomError error) => error.code.native(),
            'code',
            equals(false),
          ),
        ),
      );
    });
  });

  group('Debug Function Errors', () {
    test('debug with non-string label throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main() = debug(123, "value")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            allOf(contains('debug'), contains('Number')),
          ),
        ),
      );
    });

    test(
      'debug with non-string label via indirect call throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = let f = debug in f(123, "value")',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (RuntimeError error) => error.toString(),
              'message',
              allOf(contains('debug'), contains('Number')),
            ),
          ),
        );
      },
    );

    test(
      'debug with wrong argument count via indirect call throws InvalidArgumentCountError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = let f = debug in f("only one")',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentCountError>().having(
              (RuntimeError error) => error.toString(),
              'message',
              allOf(
                contains('debug'),
                contains('Expected: 2'),
                contains('Actual: 1'),
              ),
            ),
          ),
        );
      },
    );

    test('debug propagates error from value expression', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = debug("label", num_div(1, 0))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<DivisionByZeroError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('Division by zero'),
          ),
        ),
      );
    });

    test('debug propagates error from label expression first', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = debug(error_throw(0, "label failed"), num_div(1, 0))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (CustomError error) => error.toString(),
            'message',
            contains('label failed'),
          ),
        ),
      );
    });

    test('debug propagates error from value after label succeeds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = debug("ok", error_throw(0, "value failed"))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (CustomError error) => error.toString(),
            'message',
            contains('value failed'),
          ),
        ),
      );
    });

    test('try catches debug type error and returns fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(debug(123, "value"), "caught")',
      );
      checkResult(runtime, '"caught"');
    });
  });
}
