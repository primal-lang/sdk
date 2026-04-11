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
      final RuntimeFacade runtime = getRuntime('main = 1 / 0');
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
      final RuntimeFacade runtime = getRuntime('main = -1 / 0');
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
      final RuntimeFacade runtime = getRuntime('main = 1 % 0');
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
      final RuntimeFacade runtime = getRuntime('main = 0 / 0');
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
    test('stack.pop on empty stack has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.pop(stack.new([]))',
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

    test('stack.peek on empty stack has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new([]))',
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

    test('queue.dequeue on empty queue has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.dequeue(queue.new([]))',
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

    test('queue.peek on empty queue has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new([]))',
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
    test('map.at with non-existent key has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.at({"a": 1, "b": 2}, "c")',
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
    test('vector.add with different lengths has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add(vector.new([1]), vector.new([1, 2, 3]))',
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

    test('vector.sub with different lengths has descriptive message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.sub(vector.new([1, 2, 3, 4]), vector.new([1]))',
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
    test('to.number throws ParseError for invalid input', () {
      final RuntimeFacade runtime = getRuntime('main = to.number("abc")');
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

    test('to.integer throws ParseError for invalid input', () {
      final RuntimeFacade runtime = getRuntime('main = to.integer("abc")');
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

    test('to.decimal throws ParseError for invalid input', () {
      final RuntimeFacade runtime = getRuntime('main = to.decimal("abc")');
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
    test('error.throw raises CustomError with message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(42, "test error")',
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
        'main = try(error.throw(0, "oops"), "recovered")',
      );
      checkResult(runtime, '"recovered"');
    });

    test('try catches type error and returns fallback', () {
      final RuntimeFacade runtime = getRuntime('main = try(1 + true, -1)');
      checkResult(runtime, -1);
    });

    test('error.throw evaluates message expression', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(1, str.concat("hello", " world"))',
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
      'error.throw with non-string message throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime('main = error.throw(1, 42)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(contains('error.throw'), contains('Number')),
            ),
          ),
        );
      },
    );
  });

  group('Invalid Argument Count', () {
    test('too few arguments throws InvalidArgumentCountError', () {
      final RuntimeFacade runtime = getRuntime(
        'apply(f, x) = f(x)\nadd(a, b) = a + b\nmain = apply(add, 1)',
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
        'apply(f, x, y, z) = f(x, y, z)\nadd(a, b) = a + b\nmain = apply(add, 1, 2, 3)',
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
      final RuntimeFacade runtime = getRuntime('main = 1');
      expect(
        () => runtime.format(Object()),
        throwsA(isA<InvalidValueError>()),
      );
    });
  });

  group('Cross-Type Comparison Errors', () {
    test('list equals string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = [1, 2] == "hello"');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('map equals list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = {"a": 1} == [1]');
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
main = getVal(5)(1)
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
main = getVal(true)[0]
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
      final RuntimeFacade runtime = getRuntime('main = 1');
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
      final RuntimeFacade runtime = getRuntime('main = 1');
      expect(
        () => runtime.evaluate(compiler.expression('num.add(1)')),
        throwsA(
          isA<InvalidNumberOfArgumentsError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('num.add'),
              contains('expected 2'),
              contains('got 1'),
            ),
          ),
        ),
      );
    });

    test('non-callable literal throws NotCallableError', () {
      final RuntimeFacade runtime = getRuntime('main = 1');
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
      final RuntimeFacade runtime = getRuntime('main = 1');
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
    test('list.first on empty list throws EmptyCollectionError', () {
      final RuntimeFacade runtime = getRuntime('main = list.first([])');
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

    test('list.last on empty list throws EmptyCollectionError', () {
      final RuntimeFacade runtime = getRuntime('main = list.last([])');
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

    test('str.first on empty string throws EmptyCollectionError', () {
      final RuntimeFacade runtime = getRuntime('main = str.first("")');
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

    test('str.last on empty string throws EmptyCollectionError', () {
      final RuntimeFacade runtime = getRuntime('main = str.last("")');
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
    test('list.at with index out of bounds throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime('main = list.at([1, 2, 3], 5)');
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
      final RuntimeFacade runtime = getRuntime('main = [1, 2][10]');
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('str.at with index out of bounds throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime('main = str.at("abc", 5)');
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
      final RuntimeFacade runtime = getRuntime('main = "abc"[10]');
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('list.sublist with end > length throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3], 0, 10)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('str.substring with end > length throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.substring("abc", 0, 10)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('list.set with index out of bounds throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1, 2, 3], 10, 99)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test(
      'list.removeAt with index out of bounds throws IndexOutOfBoundsError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = list.removeAt([1, 2, 3], 10)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<IndexOutOfBoundsError>()),
        );
      },
    );

    test('list.swap with index out of bounds throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap([1, 2, 3], 0, 10)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test(
      'str.removeAt with index out of bounds throws IndexOutOfBoundsError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = str.removeAt("abc", 10)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<IndexOutOfBoundsError>()),
        );
      },
    );
  });

  group('Negative Index Errors', () {
    test('list.at with negative index throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime('main = list.at([1, 2, 3], -1)');
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
      final RuntimeFacade runtime = getRuntime('main = [1, 2, 3][-1]');
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('str.at with negative index throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime('main = str.at("abc", -1)');
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('string indexing with negative index throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime('main = "abc"[-1]');
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('list.sublist with negative start throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3], -1, 2)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('str.substring with negative start throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.substring("abc", -1, 2)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('list.take with negative count throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.take([1, 2, 3], -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('list.drop with negative count throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.drop([1, 2, 3], -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('str.take with negative count throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime('main = str.take("abc", -1)');
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('str.drop with negative count throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime('main = str.drop("abc", -1)');
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('list.set with negative index throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1, 2, 3], -1, 99)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('list.removeAt with negative index throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.removeAt([1, 2, 3], -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('list.swap with negative first index throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap([1, 2, 3], -1, 1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('list.swap with negative second index throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap([1, 2, 3], 0, -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('str.removeAt with negative index throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.removeAt("abc", -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('list.filled with negative count throws NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime('main = list.filled(-1, 0)');
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });
  });

  group('Recursion Limit Errors', () {
    test('infinite recursion throws RecursionLimitError', () {
      final RuntimeFacade runtime = getRuntime(
        'loop(x) = loop(x)\nmain = loop(1)',
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
        'ping(x) = pong(x)\npong(x) = ping(x)\nmain = ping(1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<RecursionLimitError>()),
      );
    });
  });

  group('Invalid Numeric Operation Errors', () {
    test('num.log with zero throws InvalidNumericOperationError', () {
      final RuntimeFacade runtime = getRuntime('main = num.log(0)');
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

    test('num.log with negative throws InvalidNumericOperationError', () {
      final RuntimeFacade runtime = getRuntime('main = num.log(-5)');
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

    test('num.sqrt with negative throws InvalidNumericOperationError', () {
      final RuntimeFacade runtime = getRuntime('main = num.sqrt(-4)');
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
      'num.pow with negative base and fractional exponent throws InvalidNumericOperationError',
      () {
        final RuntimeFacade runtime = getRuntime('main = num.pow(-2, 0.5)');
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
      'num.integerRandom with max < min throws InvalidNumericOperationError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = num.integerRandom(10, 5)',
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
    test('json.decode with invalid JSON throws JsonParseError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode("{invalid}")',
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

    test('json.decode with null value throws RuntimeError', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode("null")');
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
      final RuntimeFacade runtime = getRuntime('main = {"a": 1}["missing"]');
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
          'main = {1: "one", 2: "two"}[3]',
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
    test('vector.normalize with zero vector throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.normalize(vector.new([0, 0, 0]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<DivisionByZeroError>()),
      );
    });

    test('vector.angle with empty vectors throws RuntimeError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([]), vector.new([]))',
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

    test('vector.angle with zero vectors throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([0, 0]), vector.new([1, 1]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<DivisionByZeroError>()),
      );
    });

    test(
      'vector.angle with different lengths throws IterablesWithDifferentLengthError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = vector.angle(vector.new([1, 2]), vector.new([1, 2, 3]))',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<IterablesWithDifferentLengthError>()),
        );
      },
    );
  });

  group('Parse Errors for Other Functions', () {
    test('time.fromIso with invalid format throws ParseError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = time.fromIso("not-a-date")',
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

    test('str.match with invalid regex throws ParseError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.match("test", "[invalid")',
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
      final RuntimeFacade runtime = getRuntime('main = try(1 / 0, 999)');
      checkResult(runtime, 999);
    });

    test('try catches index out of bounds and returns fallback', () {
      final RuntimeFacade runtime = getRuntime('main = try([1, 2][10], -1)');
      checkResult(runtime, -1);
    });

    test('try catches parse error and returns fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(to.integer("abc"), 0)',
      );
      checkResult(runtime, 0);
    });

    test('try catches empty collection error and returns fallback', () {
      final RuntimeFacade runtime = getRuntime('main = try(list.first([]), 0)');
      checkResult(runtime, 0);
    });

    test('try catches recursion limit and returns fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'loop(x) = loop(x)\nmain = try(loop(1), "caught")',
      );
      checkResult(runtime, '"caught"');
    });

    test('try catches invalid argument types and returns fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(vector.magnitude([1, 2, 3]), 0)',
      );
      checkResult(runtime, 0);
    });

    test('try catches map key not found and returns fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(map.at({"a": 1}, "b"), "default")',
      );
      checkResult(runtime, '"default"');
    });

    test('try catches negative index and returns fallback', () {
      final RuntimeFacade runtime = getRuntime('main = try([1, 2][-1], 0)');
      checkResult(runtime, 0);
    });

    test('try catches json parse error and returns fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(json.decode("{broken}"), {})',
      );
      checkResult(runtime, '{}');
    });
  });

  group('Higher-Order Function Return Type Errors', () {
    test(
      'list.filter with non-boolean predicate throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'identity(x) = x\nmain = list.filter([1, 2, 3], identity)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (RuntimeError error) => error.toString(),
              'message',
              allOf(contains('list.filter'), contains('Boolean')),
            ),
          ),
        );
      },
    );

    test(
      'list.all with non-boolean predicate throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'identity(x) = x\nmain = list.all([1, 2, 3], identity)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (RuntimeError error) => error.toString(),
              'message',
              allOf(contains('list.all'), contains('Boolean')),
            ),
          ),
        );
      },
    );

    test(
      'list.any with non-boolean predicate throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'identity(x) = x\nmain = list.any([1, 2, 3], identity)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (RuntimeError error) => error.toString(),
              'message',
              allOf(contains('list.any'), contains('Boolean')),
            ),
          ),
        );
      },
    );

    test(
      'list.none with non-boolean predicate throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'identity(x) = x\nmain = list.none([1, 2, 3], identity)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (RuntimeError error) => error.toString(),
              'message',
              allOf(contains('list.none'), contains('Boolean')),
            ),
          ),
        );
      },
    );

    test(
      'list.sort with non-number comparator throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'compare(a, b) = "string"\nmain = list.sort([3, 1, 2], compare)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (RuntimeError error) => error.toString(),
              'message',
              allOf(contains('list.sort'), contains('Number')),
            ),
          ),
        );
      },
    );

    test('list.filter with non-function throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.filter([1, 2], 42)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('list.filter'),
          ),
        ),
      );
    });

    test('list.map with non-function throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.map([1, 2], "string")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('list.map'),
          ),
        ),
      );
    });

    test('list.reduce with non-function throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.reduce([1, 2], 0, 42)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('list.reduce'),
          ),
        ),
      );
    });

    test('list.zip with non-function throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = list.zip([1], [2], 42)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('list.zip'),
          ),
        ),
      );
    });
  });

  group('Division Function Call Errors', () {
    test('num.div by zero throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime('main = num.div(10, 0)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<DivisionByZeroError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('num.div'),
          ),
        ),
      );
    });

    test('num.mod by zero throws DivisionByZeroError', () {
      final RuntimeFacade runtime = getRuntime('main = num.mod(10, 0)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<DivisionByZeroError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('num.mod'),
          ),
        ),
      );
    });

    test('num.div with non-number throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = num.div(10, "two")');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('num.mod with non-number throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = num.mod(10, true)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Type Conversion Edge Cases', () {
    test('to.boolean with list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = to.boolean([1, 2, 3])');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('to.boolean'),
          ),
        ),
      );
    });

    test('to.boolean with map throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = to.boolean({"a": 1})');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('to.list with string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = to.list("abc")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('to.list'),
          ),
        ),
      );
    });

    test('to.list with number throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = to.list(42)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('to.number with empty string throws ParseError', () {
      final RuntimeFacade runtime = getRuntime('main = to.number("")');
      expect(
        runtime.executeMain,
        throwsA(isA<ParseError>()),
      );
    });

    test('to.integer with decimal string throws ParseError', () {
      final RuntimeFacade runtime = getRuntime('main = to.integer("3.14")');
      expect(
        runtime.executeMain,
        throwsA(isA<ParseError>()),
      );
    });

    test('to.decimal with special characters throws ParseError', () {
      final RuntimeFacade runtime = getRuntime('main = to.decimal("\$100")');
      expect(
        runtime.executeMain,
        throwsA(isA<ParseError>()),
      );
    });
  });

  group('Vector Type Errors', () {
    test(
      'vector.new with non-numeric list throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = vector.new(["a", "b", "c"])',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (RuntimeError error) => error.toString(),
              'message',
              contains('vector.new'),
            ),
          ),
        );
      },
    );

    test('vector.magnitude with list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude([1, 2])',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('vector.magnitude'),
          ),
        ),
      );
    });

    test('vector.add with list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.add([1, 2], vector.new([3, 4]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test(
      'vector.sub with different lengths throws IterablesWithDifferentLengthError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = vector.sub(vector.new([1, 2, 3]), vector.new([1, 2]))',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<IterablesWithDifferentLengthError>()),
        );
      },
    );

    test(
      'vector.normalize with empty vector returns empty vector without error',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = list.length(to.list(vector.normalize(vector.new([]))))',
        );
        checkResult(runtime, 0);
      },
    );
  });

  group('Sublist and Substring Range Errors', () {
    test('list.sublist with start > end throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3], 2, 1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('str.substring with start > end throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.substring("abc", 2, 1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('list.sublist with negative end throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3], 0, -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('str.substring with negative end throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.substring("abc", 0, -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });
  });

  group('String Operation Type Errors', () {
    test('str.concat with number throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.concat("hello", 42)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('str.concat'),
          ),
        ),
      );
    });

    test(
      'str.split with non-string delimiter throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = str.split("a,b,c", 1)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test('str.replace with non-string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.replace("hello", "l", 1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('str.padLeft with non-string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.padLeft(123, 5, " ")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('str.padRight with non-string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.padRight(123, 5, " ")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Map Operation Errors', () {
    test('map.set with non-map throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.set([1, 2], "key", "value")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('map.set'),
          ),
        ),
      );
    });

    test('map.removeAt with non-map throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.removeAt([1, 2], "key")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('map.keys with non-map throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = map.keys([1, 2, 3])');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('map.values with non-map throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = map.values("string")');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('map.containsKey with non-map throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.containsKey(42, "key")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Set Operation Errors', () {
    test('set.add with non-set throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = set.add([1, 2], 3)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('set.add'),
          ),
        ),
      );
    });

    test('set.remove with non-set throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = set.remove([1, 2], 1)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('set.union with non-sets throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union([1, 2], set.new([3, 4]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('set.intersection with non-sets throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(set.new([1, 2]), [3, 4])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('set.difference with non-sets throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference(set.new([1, 2]), "abc")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Stack and Queue Type Errors', () {
    test('stack.push with non-stack throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = stack.push([1, 2], 3)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('stack.push'),
          ),
        ),
      );
    });

    test('stack.pop with non-stack throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = stack.pop([1, 2])');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('stack.peek with non-stack throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = stack.peek("string")');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('queue.enqueue with non-queue throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.enqueue([1, 2], 3)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('queue.enqueue'),
          ),
        ),
      );
    });

    test('queue.dequeue with non-queue throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = queue.dequeue([1, 2])');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('queue.peek with non-queue throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = queue.peek(42)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('List Operation Type Errors', () {
    test('list.at with non-list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = list.at("abc", 0)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('list.at'),
          ),
        ),
      );
    });

    test('list.at with non-number index throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.at([1, 2], "zero")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('list.insertStart with non-list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.insertStart("abc", 1)',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('list.insertEnd with non-list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = list.insertEnd(42, 1)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('list.concat with non-lists throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.concat([1, 2], "abc")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('list.join with non-list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = list.join("abc", ",")');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('list.reverse with non-list throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = list.reverse("abc")');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Arithmetic Operation Type Errors', () {
    test('num.add with non-numbers throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = num.add(1, "two")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('num.add'),
          ),
        ),
      );
    });

    test('num.sub with non-numbers throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = num.sub("one", 2)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('num.mul with non-numbers throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = num.mul(true, 2)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('num.pow with non-numbers throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = num.pow(2, [3])');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('num.sqrt with non-number throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = num.sqrt("four")');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('num.log with non-number throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = num.log([10])');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('num.abs with non-number throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = num.abs("negative")');
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
        final RuntimeFacade runtime = getRuntime('main = 1 < "two"');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'greater than with incompatible types throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime('main = [1] > 2');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'less or equal with incompatible types throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime('main = {"a": 1} <= 1');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'greater or equal with incompatible types throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime('main = true >= 1');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test('not operator with non-boolean throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = !42');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('JSON Encoding Errors', () {
    test('json.encode with function throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'identity(x) = x\nmain = json.encode(identity)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (RuntimeError error) => error.toString(),
            'message',
            contains('json.encode'),
          ),
        ),
      );
    });
  });

  group('Timestamp Operation Errors', () {
    test('time.fromIso with empty string throws ParseError', () {
      final RuntimeFacade runtime = getRuntime('main = time.fromIso("")');
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

    test('time.fromIso with non-string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = time.fromIso(12345)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Edge Cases for Empty Collections', () {
    test('list.rest on empty list returns empty list', () {
      final RuntimeFacade runtime = getRuntime('main = list.rest([])');
      checkResult(runtime, '[]');
    });

    test('list.init on empty list returns empty list', () {
      final RuntimeFacade runtime = getRuntime('main = list.init([])');
      checkResult(runtime, '[]');
    });

    test('str.rest on empty string returns empty string', () {
      final RuntimeFacade runtime = getRuntime('main = str.rest("")');
      checkResult(runtime, '""');
    });

    test('str.init on empty string returns empty string', () {
      final RuntimeFacade runtime = getRuntime('main = str.init("")');
      checkResult(runtime, '""');
    });

    test('list.reduce on empty list returns initial value', () {
      final RuntimeFacade runtime = getRuntime(
        'add(a, b) = a + b\nmain = list.reduce([], 0, add)',
      );
      checkResult(runtime, 0);
    });

    test('list.filter on empty list returns empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'isPositive(x) = x > 0\nmain = list.filter([], isPositive)',
      );
      checkResult(runtime, '[]');
    });

    test('list.map on empty list returns empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'double(x) = x * 2\nmain = list.map([], double)',
      );
      checkResult(runtime, '[]');
    });

    test('list.all on empty list returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'isPositive(x) = x > 0\nmain = list.all([], isPositive)',
      );
      checkResult(runtime, true);
    });

    test('list.any on empty list returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'isPositive(x) = x > 0\nmain = list.any([], isPositive)',
      );
      checkResult(runtime, false);
    });

    test('list.none on empty list returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'isPositive(x) = x > 0\nmain = list.none([], isPositive)',
      );
      checkResult(runtime, true);
    });
  });

  group('Boundary Value Tests', () {
    test('list.at with index 0 on single element list succeeds', () {
      final RuntimeFacade runtime = getRuntime('main = list.at([42], 0)');
      checkResult(runtime, 42);
    });

    test('list.at with index at last position succeeds', () {
      final RuntimeFacade runtime = getRuntime('main = list.at([1, 2, 3], 2)');
      checkResult(runtime, 3);
    });

    test('list.sublist with start equals end returns empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3], 1, 1)',
      );
      checkResult(runtime, '[]');
    });

    test('str.substring with start equals end returns empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.substring("abc", 1, 1)',
      );
      checkResult(runtime, '""');
    });

    test('list.take with count 0 returns empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.take([1, 2, 3], 0)',
      );
      checkResult(runtime, '[]');
    });

    test('list.drop with count 0 returns original list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.drop([1, 2, 3], 0)',
      );
      checkResult(runtime, '[1, 2, 3]');
    });

    test('str.take with count 0 returns empty string', () {
      final RuntimeFacade runtime = getRuntime('main = str.take("abc", 0)');
      checkResult(runtime, '""');
    });

    test('str.drop with count 0 returns original string', () {
      final RuntimeFacade runtime = getRuntime('main = str.drop("abc", 0)');
      checkResult(runtime, '"abc"');
    });

    test('list.filled with count 0 returns empty list', () {
      final RuntimeFacade runtime = getRuntime('main = list.filled(0, 42)');
      checkResult(runtime, '[]');
    });

    test('vector with single element operations work correctly', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.magnitude(vector.new([5]))',
      );
      checkResult(runtime, 5.0);
    });
  });

  group('Operator Type Errors', () {
    test('addition of map and number throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = {"a": 1} + 2');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test(
      'subtraction with incompatible types throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime('main = "abc" - 1');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'multiplication with incompatible types throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime('main = true * 2');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'division with incompatible types throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime('main = "abc" / 2');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test('modulo with incompatible types throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = [1, 2] % 3');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Hash Function Errors', () {
    test('hash.md5 with non-string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = hash.md5(12345)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('hash.sha256 with non-string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha256([1, 2, 3])');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('hash.sha512 with non-string throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha512(true)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Control Flow Errors', () {
    test('if with non-boolean condition throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime('main = if (1) "yes" else "no"');
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
      final RuntimeFacade runtime = getRuntime('main = if ("true") 1 else 0');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('if with list condition throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if ([1, 2]) "yes" else "no"',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('if with map condition throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if ({"a": 1}) "yes" else "no"',
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
      final RuntimeFacade runtime = getRuntime('main = 1');
      expect(
        () => runtime.evaluate(compiler.expression('undefinedVar')),
        throwsA(isA<UndefinedIdentifierError>()),
      );
    });
  });

  group('CustomError Properties', () {
    test('CustomError preserves numeric code value', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(42, "error message")',
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
        'main = error.throw("ERROR_CODE", "details")',
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
        'main = error.throw(false, "failure")',
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
}
