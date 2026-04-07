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
            contains('Cannot pop from an empty stack'),
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
            contains('Cannot peek from an empty stack'),
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
            contains('Cannot dequeue from an empty queue'),
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
            contains('Cannot peek from an empty queue'),
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
  });
}
